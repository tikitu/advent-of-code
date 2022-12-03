import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 3",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() {
            let lines = readLines()
            let pairs = lines
                .map { ($0[..<$0.index($0.startIndex, offsetBy: $0.count / 2)],
                        $0[$0.index($0.startIndex, offsetBy: ($0.count/2))...]) }
            let sets = pairs
                .map { (Set($0.0), Set($0.1)) }
            let misplaced = sets
                .map { $0.0.intersection($0.1) }
            let values = misplaced
                .map { priorities[$0.first!]! }
            let answer = values
                .reduce(0, +)
            print(answer)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() {
            let lines = readLines()
            let groups = lines
                .chunks(ofCount: 3)
            let sets = groups
                .map { $0.map { Set($0) } }
            let shared = sets
                .map { (group: [Set<Character>]) in group[0].intersection(group[1]).intersection(group[2]) }
            let values = shared
                .map { priorities[$0.first!]! }
            let answer = values
                .reduce(0, +)
            print(answer)
        }
    }
    static let priorities = {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let lowerPriorities = Dictionary(
            uniqueKeysWithValues: alphabet.enumerated().map { (i, c) in
                (c, i+1)
            })
        let upperPriorities = Dictionary(
            uniqueKeysWithValues: alphabet.enumerated().map { (i, c) in
                (c.uppercased().first!, i+27)
            }
        )
        return lowerPriorities.merging(upperPriorities, uniquingKeysWith: { a, _ in a })
    }()

}
