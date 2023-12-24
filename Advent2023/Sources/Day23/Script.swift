import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils
import Collections

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 23",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 23 part 1")
            var puzzle = CharGrid(lines: readLines())

            // First reduce the map to its choice points (from inspection of the input it's not many)
            let start = Point(row: 0, col: puzzle.rows[0].firstIndex(of: ".")!)
            var exploring: Set<Point> = [start]
            var visited: Set<Point> = []
            while let current = exploring.popFirst() {
                guard !visited.contains(current) else { continue }
                visited.insert(current)
                let options = puzzle.candidates(from: current)
                if options.count == 1 {
                    puzzle[current] = switch options.first! {
                    case current.north:
                        "^"
                    case current.west:
                        "<"
                    case current.east:
                        ">"
                    case current.south:
                        "v"
                    default:
                        preconditionFailure("should have been a cardinal of \(current) but got \(options.first!)")
                    }
                }
                exploring.formUnion(options)
            }
            print(puzzle.pretty)

            // now solve the search problem
            let target = Point(row: puzzle.rows.count - 1, col: puzzle.rows.last!.firstIndex(of: ".")!)
            var paths: Set<Path> = [Path(point: start, length: 0)]
            var solutions: Set<Path> = []
            while let current = paths.popFirst() {
                guard current.point != target else {
                    solutions.insert(current)
                    continue
                }
                for candidate in puzzle.candidates(from: current.point) {
                    var nextPath = Path(point: candidate, length: current.length + 1)
                    while puzzle[nextPath.point] != "." {
                        nextPath.length += 1
                        nextPath.point = switch puzzle[nextPath.point] {
                        case ">":
                            nextPath.point.east
                        case "<":
                            nextPath.point.west
                        case "^":
                            nextPath.point.north
                        case "v":
                            nextPath.point.south
                        default:
                            preconditionFailure("Unexpected value \(puzzle[nextPath.point] ?? "o")")
                        }
                    }
                    paths.insert(nextPath)
                }
            }
            print(solutions.map { $0.length }.max()!)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 23 part 2")
            let puzzle = CharGrid(lines: readLines())

            // First reduce the map to its choice points (from inspection of the input it's not many)
            // Ah. This doesn't work now. Because if A->C and B->C join up midway, that also gives
            // A->B which this method will never find. Sigh.
            // FIXME: that's the problem

            var interesting = Set(puzzle.points { p in
                puzzle[p] != "#" &&
                p.cardinals.compactMap { puzzle[$0] }.filter { $0 != "#" }.count > 2
            })
            let start = Point(row: 0, col: puzzle.rows[0].firstIndex(of: ".")!)
            let target = Point(row: puzzle.rows.count - 1, col: puzzle.rows.last!.firstIndex(of: ".")!)
            interesting.insert(start)
            interesting.insert(target)

            // next reduce that map to a graph representation of choices and costs
            var nodes: [Point] = [start]
            var edges: [Int: [(Int, Int)]] = [:]
            var exploring: Set<Point> = [start]
            var visited: Set<Point> = []
            while let current = exploring.popFirst() {
                visited.insert(current)
                let startIdx = nodes.firstIndex(of: current)!
            CANDIDATE: for candidate in puzzle.candidates(from: current) {
                    var token = candidate
                    var length = 1
                    while !interesting.contains(token) {
                        visited.insert(token)
                        length += 1
                        let next = token.cardinals
                            .filter { puzzle[$0] != "#" }
                            .filter { $0 != current }
                            .filter { !visited.contains($0) || interesting.contains($0) }
                        assert(next.count <= 1, "got \(next) but expected 1")
                        if next.isEmpty {
                            continue CANDIDATE
                        } else {
                            token = next.first!
                        }
                    }
                    let endIdx = nodes.firstIndex(of: token) ?? nodes.count
                    if endIdx == nodes.count {
                        nodes.append(token)
                    }
                    edges[startIdx, default: []].append((endIdx, length))
                    edges[endIdx, default: []].append((startIdx, length))
                    if !visited.contains(token) {
                        exploring.insert(token)
                    }
                }
            }
            assert(Set(nodes) == interesting, "\nexp: \(interesting.sorted())\ngot: \(nodes.sorted())")

            // if there are two paths between A and B, only ever consider the longest
            for idx in edges.keys {
                edges[idx] = Dictionary(edges[idx]!, uniquingKeysWith: max).map { ($0.key, $0.value) }
            }

            print("rows: \(puzzle.rows.count) cols: \(puzzle.rows[0].count)")
            assert(nodes.contains(Point(row: puzzle.rows.count - 1, col: puzzle.rows[0].count - 2)))
            print("\(nodes.count) nodes: \(nodes)")
            print("edges: \(edges.keys.sorted().map { "\($0) -> \(edges[$0]!)" }.joined(separator: "\n       "))")

            // finally search for a *longest* path through that graph
            let startIdx = nodes.firstIndex(of: start)!
            let targetIdx = nodes.firstIndex(of: Point(row: puzzle.rows.count - 1, col: puzzle.rows.last!.firstIndex(of: ".")!))!
            var bestSolution: Step? = nil

            var steps = Heap<Step>()
            steps.insert(Step(point: startIdx, visited: [], path: [], length: 0))
            while let current = steps.popMax() {
                //print("step")
                //print(current.pretty(nodes: nodes, edges: edges))

                if current.point == targetIdx {
                    //print("found solution")
                    //print()
                    if current.length > (bestSolution?.length ?? 0) {
                        bestSolution = current
                    }
                    continue
                }
                var visited = current.visited
                visited.insert(current.point)
                var path = current.path
                path.append(current.point)

                //print("trying \(edges[current.point]!)")
                //print()
                steps.insert(
                    contentsOf: edges[current.point]!
                        .filter { !current.visited.contains($0.0) }
                        .map {
                            let (idx, cost) = $0
                            return Step(point: idx, visited: visited, path: path, length: current.length + cost)
                        })

                print("best so far: \(bestSolution?.length ?? 0) queue: \(steps.count) exploring: \(current.length)", terminator: "\r")
                fflush(stdout)
            }

            //            print()
            //            print(solutions.map { $0.length }.sorted())
            //            print()

            let best = bestSolution!
            print()
            print("finally:")
            print(best.pretty(nodes: nodes, edges: edges))
            print("length is \(best.length)")
            // 2062 : too low
            // 5394 : too low
            // 5420 : not right (with length+1 anti-correction)
            // 5395 : not right (on the theory I had it right but an off-by-one error)
            // 6398 : was right, I tried it *long* before the script finished

        }
    }
}

struct Path: Hashable, Equatable {
    var point: Point
    var length: Int
}

struct Step: Hashable, Equatable, Comparable {
    static func < (lhs: Step, rhs: Step) -> Bool {
        if lhs.length < rhs.length { return true }
        if lhs.length > rhs.length { return false }
        if lhs.point < rhs.point { return true }
        if lhs.point > rhs.point { return false }
        if lhs.visited.count < rhs.visited.count { return true }
        if lhs.visited.count > rhs.visited.count { return false }
        for pair in zip(Array(lhs.visited.sorted(by: { $0 < $1 })),
                        Array(rhs.visited.sorted(by: { $0 < $1 }))) {
            if pair.0 < pair.1 { return true }
            if pair.0 > pair.1 { return false }
        }
        return false
    }
    
    var point: Int
    var visited: Set<Int>
    var path: [Int]
    var length: Int

    func pretty(nodes: [Point], edges: [Int: [(Int, Int)]]) -> String {
        var path = self.path
        path.append(point)

        var result = "solution with \(path.count) nodes and length \(length)\n"

        for pair in path.adjacentPairs() {
            result.append("\(pair.0) -(\(edges[pair.0]!.first { $0.0 == pair.1 }!.1))-> ")
        }
        result.append("\(path.last!)\n")
        for pair in path.adjacentPairs() {
            result.append("\(nodes[pair.0]) -(\(edges[pair.0]!.first { $0.0 == pair.1 }!.1))-> ")
        }
        result.append("\(nodes[path.last!])\n")
        result.append("calculated length: \(path.adjacentPairs().map { pair in edges[pair.0]!.first { $0.0 == pair.1 }!.1 }.reduce(0, +))")
        return result

    }
}

extension CharGrid {
    func candidates(from point: Point) -> Set<Point> {
        var options: Set<Point> = []
        for (option, notAllowed) in [
            (point.north, "v" as Character),
            (point.west, ">"),
            (point.east, "<"),
            (point.south, "^")
        ] {
            switch self[option] {
            case nil, "#"?:
                continue
            case notAllowed?:
                continue
            case "."?:
                options.insert(option)
            default: // other arrow
                options.insert(option)
            }
        }
        return options
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        "<\(row),\(col)>"
    }
}
