import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 11",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 11 part 01")
            // let input = readLines()
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 11 part 02")
            // let input = readLines()
        }
    }
}
