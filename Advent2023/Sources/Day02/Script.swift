import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

enum Colour: String, CaseIterable {
    case red, green, blue
}
struct CubesParser: Parser {
    var body: some Parser<Substring, (Int, Colour)> {
        Int.parser()
        " "
        Colour.parser()
    }
}
struct Throw {
    var red: Int = 0
    var green: Int = 0
    var blue: Int = 0
}
struct ThrowParser: Parser {
    var body: some Parser<Substring, Throw> {
        Many {
            CubesParser()
        } separator: {
            ", "
        }
        .map { (record: [(Int, Colour)]) -> Throw in
            var thisThrow = Throw()
            for cubes in record {
                switch cubes.1 {
                case .red:
                    thisThrow.red = cubes.0
                case .green:
                    thisThrow.green = cubes.0
                case .blue:
                    thisThrow.blue = cubes.0
                }
            }
            return thisThrow
        }
    }
}
struct Game {
    var num: Int
    var records: [Throw]
}
struct GameParser: Parser {
    var body: some Parser<Substring, Game> {
        Parse {
            "Game "
            Int.parser()
            ": "
            Many {
                ThrowParser()
            } separator: {
                "; "
            }
        }.map {
            Game(num: $0, records: $1)
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 02",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let lines = readLines()
            let games = try lines.map {
                try GameParser().parse($0)
            }

            let possible = games
                .filter {
                    $0.records.allSatisfy {
                        $0.red <= 12 && $0.blue <= 14 && $0.green <= 13
                    }
                }
            let result = possible
                .map { $0.num }
                .reduce(0, +)

            print(result)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            let lines = readLines()
            let games = try lines.map {
                try GameParser().parse($0)
            }
            print(games.map { $0.min.power }.reduce(0, +))
        }
    }
}

extension Game {
    var min: Throw {
        Throw(
            red: records.map { $0.red }.max()!,
            green: records.map { $0.green }.max()!,
            blue: records.map { $0.blue }.max()!
        )
    }
}
extension Throw {
    var power: Int {
        red * green * blue
    }
}
