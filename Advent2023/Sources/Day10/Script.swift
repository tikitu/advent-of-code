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
            let row = grid.rows.firstIndex(where: { $0.contains("S") })!
            let col = grid.rows[row].firstIndex(of: "S")!
            var step: Step
            if ["|", "F", "7"].contains(grid[row: row-1, col: col]) {
                step = Step(row: row-1, col: col, dir: .north)
            } else if ["|", "J", "L"].contains(grid[row: row+1, col: col]) {
                step = Step(row: row+1, col: col, dir: .south)
            } else if ["-", "F", "L"].contains(grid[row: row, col: col-1]) {
                step = Step(row: row, col: col-1, dir: .west)
            } else if ["-", "J", "7"].contains(grid[row: row, col: col+1]) {
                step = Step(row: row, col: col+1, dir: .east)
            } else {
                fatalError("Can't get started")
            }
            var steps = [step]
            while let pipe = grid[row: step.row, col: step.col], pipe != "S" {
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
            print(steps)
            print(steps.count / 2)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 10 part 2")
        }
    }
}
