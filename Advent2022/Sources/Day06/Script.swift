import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 6",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 06 part 01")
            let input = readLine(strippingNewline: true)!
            let result = input
                .windows(ofCount: 4)
                .map { Set($0) }
                .enumerated()
                .first { $0.1.count == 4 }
            print(result!.0 + 4)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 06 part 02")
            let input = readLine(strippingNewline: true)!
            let result = input
                .windows(ofCount: 14)
                .map { Set($0) }
                .enumerated()
                .first { $0.1.count == 14 }
            print(result!.0 + 14)
        }
    }
}
