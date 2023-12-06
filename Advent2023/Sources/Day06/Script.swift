import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Races {
    var times: [Int]
    var distances: [Int]

    static func parser() -> some Parser<Substring, Races> {
        Parse(Races.init(times:distances:)) {
            "Time:"
            Whitespace()
            Many {
                Int.parser()
            } separator: {
                Whitespace()
            } terminator: {
                Whitespace(1, .vertical)
            }
            "Distance:"
            Whitespace()
            Many {
                Int.parser()
            } separator: {
                Whitespace()
            } terminator: {
                End()
            }
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 06",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let races = try Races.parser().parse(readLines().joined(separator: "\n"))
            let result = zip(races.times, races.distances)
                .map { (time, distance) -> Int in
                    (1..<time).filter { hold in
                        (time-hold) * hold > distance
                    }
                    .count
                }
                .map {
                    print($0, terminator: " ")
                    return $0
                }
                .reduce(1, *)
            print("\n")
            print(result)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 06 part 2")
        }
    }
}
