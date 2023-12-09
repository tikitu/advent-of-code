import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 09",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 09 part 1")
            let predictions = readLines().map { line in
                var  nums = line.split(separator: " ").map { Int($0)! }
                var trailing: [Int] = []
                while !nums.allSatisfy({ $0 == 0 }) {
                    trailing.append(nums.last!)
                    nums = nums.adjacentPairs().map { $0.1 - $0.0 }
                }
                return trailing.reduce(0, +)
            }
            print(predictions.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 09 part 2")
            let predictions = readLines().map { line in
                var  nums = line.split(separator: " ").map { Int($0)! }
                var leading: [Int] = []
                while !nums.allSatisfy({ $0 == 0 }) {
                    leading.insert(nums.first!, at: 0) // order matters now
                    nums = nums.adjacentPairs().map { $0.1 - $0.0 }
                }
                return leading.reduce(0) { $1 - $0 }
            }
            print(predictions.reduce(0, +))
        }
    }
}
