import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

enum Direction {
    case north, south, west, east
}
struct Step {
    var row: Int
    var col: Int
    var dir: Direction
}

extension Optional<Character> {
    var isInteresting: Bool {
        switch self {
        case nil, "."?:
             false
        default:
            true
        }
    }
}

struct Point: Hashable, Equatable {
    var row: Int
    var col: Int
}

extension CharGrid {
    func getLoopSteps() -> [Step] {
        let row = self.rows.firstIndex(where: { $0.contains("S") })!
        let col = self.rows[row].firstIndex(of: "S")!
        var step: Step
        if ["|", "F", "7"].contains(self[row: row-1, col: col]) {
            step = Step(row: row-1, col: col, dir: .north)
        } else if ["|", "J", "L"].contains(self[row: row+1, col: col]) {
            step = Step(row: row+1, col: col, dir: .south)
        } else if ["-", "F", "L"].contains(self[row: row, col: col-1]) {
            step = Step(row: row, col: col-1, dir: .west)
        } else if ["-", "J", "7"].contains(self[row: row, col: col+1]) {
            step = Step(row: row, col: col+1, dir: .east)
        } else {
            fatalError("Can't get started")
        }
        var steps = [step]
        while let pipe = self[row: step.row, col: step.col], pipe != "S" {
            switch (pipe, step.dir) {
            case ("|", .north):
                step.row -= 1
            case ("|", .south):
                step.row += 1
            case ("-", .west):
                step.col -= 1
            case ("-", .east):
                step.col += 1
            case ("L", .south):
                step.col += 1
                step.dir = .east
            case ("L", .west):
                step.row -= 1
                step.dir = .north
            case ("J", .south):
                step.col -= 1
                step.dir = .west
            case ("J", .east):
                step.row -= 1
                step.dir = .north
            case ("7", .north):
                step.col -= 1
                step.dir = .west
            case ("7", .east):
                step.row += 1
                step.dir = .south
            case ("F", .west):
                step.row += 1
                step.dir = .south
            case ("F", .north):
                step.col += 1
                step.dir = .east
            default:
                fatalError("Oops got \(pipe) after \(steps)")
            }
            steps.append(step)
        }
        return steps
    }
}

extension CharGrid {
    mutating func filter(replacement: Character = ".", predicate: (Point) -> Bool) {
        for rowIdx in rows.indices {
            for colIdx in rows[rowIdx].indices {
                if !predicate(Point(row: rowIdx, col: colIdx)) {
                    rows[rowIdx][colIdx] = "."
                }
            }
        }
    }

    subscript(_ step: Step) -> Character? {
        self[row: step.row, col: step.col]
    }

    subscript(_ step: Point) -> Character? {
        self[row: step.row, col: step.col]
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 10",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 10 part 1")
            let grid = CharGrid(lines: readLines())
            let steps = grid.getLoopSteps()
            print(steps)
            print(steps.count / 2)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 10 part 2")
            var grid = CharGrid(lines: readLines())
            let firstGrid = grid
            let steps = grid.getLoopSteps()
            var loop = Set(steps.map { Point(row: $0.row, col: $0.col) })

            let row = grid.rows.firstIndex(where: { $0.contains("S") })!
            let col = grid.rows[row].firstIndex(of: "S")!
            loop.insert(Point(row: row, col: col))

            switch (steps.first!.dir, steps.last!.dir) {
            case (.west, .west), (.east, .east):
                grid[row: row, col: col] = "-"
            case (.north, .north), (.south, .south):
                grid[row: row, col: col] = "|"
            case (.north, .west), (.east, .south):
                grid[row: row, col: col] = "L"
            case (.north, .east), (.west, .south):
                grid[row: row, col: col] = "J"
            case (.south, .west), (.east, .north):
                grid[row: row, col: col] = "F"
            case (.south, .east), (.west, .north):
                grid[row: row, col: col] = "7"
            default:
                fatalError("S was \((steps.first!.dir, steps.last!.dir))")
            }

            grid.filter { loop.contains($0) }
            print(grid.diff(firstGrid, showSame: false))

            var left = Set<Point>()
            var right = Set<Point>()
            
            // first find points adjacent to the loop
            for step in steps {
                var leftCandidates = Set<Point>()
                var rightCandidates = Set<Point>()
                switch (grid[step], step.dir) {
                case ("|", .north):
                    leftCandidates.insert(step.point.west)
                    rightCandidates.insert(step.point.east)
                case ("|", .south):
                    leftCandidates.insert(step.point.east)
                    rightCandidates.insert(step.point.west)
                case ("-", .west):
                    leftCandidates.insert(step.point.south)
                    rightCandidates.insert(step.point.north)
                case ("-", .east):
                    leftCandidates.insert(step.point.north)
                    rightCandidates.insert(step.point.south)
                case ("L", .south):
                    rightCandidates.insert(step.point.west)
                    rightCandidates.insert(step.point.south)
                    rightCandidates.insert(step.point.south.west)
                case ("L", .west):
                    leftCandidates.insert(step.point.west)
                    leftCandidates.insert(step.point.south)
                    leftCandidates.insert(step.point.south.west)
                case ("J", .east):
                    rightCandidates.insert(step.point.south)
                    rightCandidates.insert(step.point.east)
                    rightCandidates.insert(step.point.south.east)
                case ("J", .south):
                    leftCandidates.insert(step.point.south)
                    leftCandidates.insert(step.point.east)
                    leftCandidates.insert(step.point.south.east)
                case ("F", .north):
                    leftCandidates.insert(step.point.west)
                    leftCandidates.insert(step.point.north)
                    leftCandidates.insert(step.point.north.west)
                case ("F", .west):
                    rightCandidates.insert(step.point.west)
                    rightCandidates.insert(step.point.north)
                    rightCandidates.insert(step.point.north.west)
                case ("7", .east):
                    leftCandidates.insert(step.point.north)
                    leftCandidates.insert(step.point.east)
                    leftCandidates.insert(step.point.north.east)
                case ("7", .north):
                    rightCandidates.insert(step.point.north)
                    rightCandidates.insert(step.point.east)
                    rightCandidates.insert(step.point.north.east)
                default:
                    fatalError("Missing option for \((grid[step], step.dir))")
                }
                left.formUnion(leftCandidates.filter { grid[$0] == "." })
                right.formUnion(rightCandidates.filter { grid[$0] == "." })
            }

            if left.isEmpty || right.isEmpty {
                print("EMPTY!!!")
                return
            }
            // didn't really expect to be so lucky

            // now expand the left/right sets by adjacency
            left = grid.spread(left) { $0 == "." }
            right = grid.spread(right) { $0 == "." }

            // now which is IN and which is OUT?!
            print("one set has \(left.count)")
            print("other set has \(right.count)")
            // (I'm'a guess the _smaller_ one. You can probably get it for sure by calculating
            // a winding number for the loop?)
        }
    }
}

extension CharGrid {
    func spread(_ points: Set<Point>, predicate: (Character?) -> Bool) -> Set<Point> {
        var new = points
        var found = points
        while !new.isEmpty {
            let p = new.removeFirst()
            found.insert(p)
            new.formUnion(self.neighbours(of: p).filter { !found.contains($0) && predicate(self[$0]) })
        }
        return found
    }

    /// This one *includes* points outside the grid!
    func neighbours(of point: Point) -> Set<Point> {
        Set(
            [-1, 0, 1].flatMap { dRow in
                [-1, 0, 1].map { dCol in
                    Point(row: point.row + dRow, col: point.col + dCol)
                }
            }.filter { $0 != point }
        )
    }
}

extension Step {
    var point: Point {
        .init(row: row, col: col)
    }
}
