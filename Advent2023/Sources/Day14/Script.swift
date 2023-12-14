import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 14",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 14 part 1")
            var grid = CharGrid(lines: readLines())
            while true {
                let newGrid = grid.convolve { (p: Point) in
                    if grid[p] == "." && grid[p.south] == "O" {
                        return "O"
                    }
                    if grid[p] == "O" && grid[p.north] == "." {
                        return "."
                    }
                    return grid[p]!
                }
                if newGrid == grid {
                    break
                }
                grid = newGrid
            }
            print(grid.pretty)
            let weights = grid.rows.reversed().enumerated().map { (idx, row) in
                (idx + 1) * row.filter { $0 == "O" }.count
            }
            print(weights)
            print(weights.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 14 part 2")
        }
    }
}
