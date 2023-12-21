import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 21",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 21 part 1")
            let puzzle = CharGrid(lines: readLines())
            var cells = Set(puzzle.points(where: { $0 != "." && $0 != "#" }))
            assert(cells.count == 1)
            for i in 1...64 {
                cells = Set(
                    cells.flatMap { puzzle.neighbours(of: $0) }
                        .filter { puzzle[$0] != "#" }
                )
                print("\(i): \(cells.count)")
            }
            print(cells.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 21 part 2")
        }
    }
}
