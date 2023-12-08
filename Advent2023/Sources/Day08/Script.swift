import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Line {
    var from: Substring
    var left: Substring
    var right: Substring

    static func parser() -> some Parser<Substring, Line> {
        Parse(Line.init(from:left:right:)) {
            CharacterSet.alphanumerics
            " = ("
            CharacterSet.alphanumerics
            ", "
            CharacterSet.alphanumerics
            ")"
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 08",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 08 part 1")
            var lines = readLines()
            let turns = Array(lines.removeFirst())
            lines.removeFirst() // empty
            let maze: [Substring: Line] = try lines.reduce([:]) {
                var next = $0
                let line = try Line.parser().parse($1)
                next[line.from] = line
                return next
            }
            var here: Substring = "AAA"
            var count = 0
            while here != "ZZZ" {
                let turn = turns[count % turns.count]
                count += 1
                let choice = maze[here]!
                here = if turn == "L" { choice.left } else { choice.right }
            }
            print(count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func greatestCommonDenominator(_ a: Int, _ b: Int) -> Int {
            return b == 0 ? a : greatestCommonDenominator(b, a % b)
        }

        func leastCommonMultiple(range: [Int]) -> Int {
            return range.reduce(1) { (a, b) in a * (b / greatestCommonDenominator(a, b)) }
        }

        func run() throws {
            print("day 08 part 2")
            var lines = readLines()
            let turns = Array(lines.removeFirst())
            lines.removeFirst() // empty
            let maze: [Substring: Line] = try lines.reduce([:]) {
                var next = $0
                let line = try Line.parser().parse($1)
                next[line.from] = line
                return next
            }

            let pathLengths = maze.keys.filter({ $0.last == "A" }).map { start in
                var here = start
                var count = 0
                while here.last != "Z" {
                    let turn = turns[count % turns.count]
                    count += 1
                    let choice = maze[here]!
                    here = if turn == "L" { choice.left } else { choice.right }
                }
                print("\(start): \(count)")
                return count
            }
            print(leastCommonMultiple(range: pathLengths))
        }
    }
}
