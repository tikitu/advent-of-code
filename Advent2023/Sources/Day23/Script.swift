import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

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
        }
    }
}

struct Path: Hashable, Equatable {
    var point: Point
    var length: Int
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
