import ArgumentParser
import Parsing
import Utils
import Foundation

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 25",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 25 part 01")
            let input = readLines()
                .map { Array($0) }
                .map { $0.fromSnafu() }
            let sum = input.reduce(0, +)
            print(sum)
            print(sum.toSnafu())
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 25 part 02")
            // let input = readLines()
        }
    }
}

extension Int {
    func toSnafu() -> String {
        self.toPowersOfFive().toSnafu().map {
            switch $0 {
            case -2:
                return "="
            case -1:
                return "-"
            case 0:
                return "0"
            case 1:
                return "1"
            case 2:
                return "2"
            default:
                fatalError("unexpected digit \($0) oh yes")
            }
        }.joined()
    }

    func toPowersOfFive() -> [Int] {
        var result: [Int] = []
        var remaining = self
        while remaining > 0 {
            result.insert(remaining % 5, at: 0)
            remaining = remaining / 5
        }
        return result
    }
}

extension Array where Element == Int {
    func toSnafu() -> [Int] {
        var result = self
        result.insert(0, at: 0)
        for i in result.indices.reversed() {
            if result[i] == 5 {
                result[i-1] += 1
                result[i] = 0
            }
            if result[i] == 4 {
                result[i-1] += 1
                result[i] = -1
            } else if result[i] == 3 {
                result[i-1] += 1
                result[i] = -2
            }
        }
        return result
    }
}

extension Character {
    var fromSnafu: Int {
        switch self {
        case "1":
            return 1
        case "2":
            return 2
        case "0":
            return 0
        case "-":
            return -1
        case "=":
            return -2
        default: fatalError()
        }
    }
}

extension Array where Element == Character {
    func fromSnafu() -> Int {
        var place = 1
        return self.reversed().map { value in
            defer { place *= 5 }
            return place * value.fromSnafu
        }.reduce(0, +)
    }
}
