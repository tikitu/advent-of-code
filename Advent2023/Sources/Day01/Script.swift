import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils


@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 01",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let lines = readLines()

            let characters = lines
                .map { $0.filter { $0.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) } } }
            let firstLast = characters
                .map { [$0.first!, $0.last!] }
            let strings = firstLast
                .map { String($0) }
            let ints = strings
                .map { Int($0)! }
            let sum = ints
                .reduce(0 as Int, +)
            print(sum)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            let lines = readLines()

            let regex = try! Regex("[0-9]|(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)")
            let matches = lines.map {
                ($0, $0.matches(of: regex))
            }
            let firsts = matches.map { $0.0[$0.1.first!.range] }
            let lasts = matches.map { $0.0[$0.1.last!.range] }
            func digit(_ d: Substring) -> String {
                ["one": "1", "two": "2", "three": "3", "four": "4", "five": "5", "six": "6", "seven": "7", "eight": "8", "nine": "9",
                 "0": "0", "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9"][d]!
            }
            let firstLasts = zip(firsts, lasts)
            let strings = firstLasts
                .map { "\(digit($0.0))\(digit($0.1))" }
            let ints = strings
                .map { Int($0)! }

            zip(lines, zip(matches, zip(firsts, zip(lasts, ints)))).forEach {
                var (line, (matches, (first, (last, int)))) = $0
                if matches.1.count == 1 {
                    line.insert("]", at: matches.1.last!.range.upperBound)
                    line.insert("]", at: matches.1.first!.range.upperBound)
                    line.insert("[", at: matches.1.last!.range.lowerBound)
                    line.insert("[", at: matches.1.first!.range.lowerBound)
                } else {
                    line.insert("]", at: matches.1.last!.range.upperBound)
                    line.insert("[", at: matches.1.last!.range.lowerBound)
                    line.insert("]", at: matches.1.first!.range.upperBound)
                    line.insert("[", at: matches.1.first!.range.lowerBound)
                }
                print("\(line) \(first) \(last) \(int)")
            }

            let sum = ints
                .reduce(0 as Int, +)
            print(sum)
        }
    }
}
