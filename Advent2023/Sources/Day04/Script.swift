import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Row {
    var gameNum: Int
    var before: [Int]
    var after: [Int]

    var score: Int {
        let winning = Set(before)
        let wins = after.filter { winning.contains($0) }
        return if wins.isEmpty { 0 } else {
            wins.reduce(1, { (acc, _) in acc * 2 }) / 2
        }
    }

    struct P: Parser {
        var body: some Parser<Substring, Row> {
            Parse {
                "Card"
                Whitespace()
                Int.parser()
                ":"
                Whitespace()
                Many {
                    Int.parser()
                } separator: {
                    Whitespace()
                } terminator: {
                    Whitespace()
                    "|"
                    Whitespace()
                }
                Many {
                    Int.parser()
                } separator: {
                    Whitespace()
                }
            }.map {
                Row(gameNum: $0, before: $1, after: $2)
            }
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 04",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let games = try readLines().map { try Row.P().parse($0) }
            print(games.map { $0.score }.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 04 part 2")
        }
    }
}
