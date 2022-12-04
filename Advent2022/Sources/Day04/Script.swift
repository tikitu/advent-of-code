import ArgumentParser
import Parsing
import Utils

// swift run Advent2022 01

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 4",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 04 part 01")
            let input = readLines()
            let parser = Parse {
                Parse {
                    Int.parser()
                    "-"
                    Int.parser()
                }.map { ClosedRange(uncheckedBounds: ($0.0, $0.1)) }
                ","
                Parse {
                    Int.parser()
                    "-"
                    Int.parser()
                }.map { ClosedRange(uncheckedBounds: ($0.0, $0.1)) }
            }
            let parsed = try input.map(parser.parse)
            let filtered = parsed
                .filter {
                    ($0.0.contains($0.1.minimum) && $0.0.contains($0.1.maximum!))
                    ||
                    ($0.1.contains($0.0.minimum) && $0.1.contains($0.0.maximum!))
                }
            let answer = filtered
                .count
            print(answer)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 04 part 02")
            let input = readLines()
            let parser = Parse {
                Parse {
                    Int.parser()
                    "-"
                    Int.parser()
                }.map { ClosedRange(uncheckedBounds: ($0.0, $0.1)) }
                ","
                Parse {
                    Int.parser()
                    "-"
                    Int.parser()
                }.map { ClosedRange(uncheckedBounds: ($0.0, $0.1)) }
            }
            let parsed = try input.map(parser.parse)
            let filtered = parsed
                .filter { $0.0.overlaps($0.1) }
            let answer = filtered
                .count
            print(answer)
        }
    }
}

