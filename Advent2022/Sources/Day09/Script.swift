import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 9",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    enum Direction: String, CaseIterable {
        case l = "L", r = "R", u = "U", d = "D"
    }

    struct Move {
        var dir: Direction
        var steps: Int
    }

    static let parser = Parse(Move.init(dir:steps:)) {
        Direction.parser()
        " "
        Digits()
    }

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 09 part 01")
            let input = try readLines().map { try parser.parse($0) }

            var head = Pair(x: 0, y: 0)
            var tail = Pair(x: 0, y: 0)
            var visited: Set<Pair> = [tail]

            for move in input {
                for _ in 0..<move.steps {
                    updateOnce(head: &head, tail: &tail, direction: move.dir)
                    visited.insert(tail)
                }
            }
            print(visited.count)
        }

    }

    static func updateOnce(head: inout Pair, tail: inout Pair, direction: Direction) {
        move(head: &head, direction: direction)
        drag(head: head, tail: &tail)
    }

    static func move(head: inout Pair, direction: Direction) {
        switch direction {
        case .l:
            head.x -= 1
        case .r:
            head.x += 1
        case .u:
            head.y += 1
        case .d:
            head.y -= 1
        }
    }

    static func drag(head: Pair, tail: inout Pair) {
        if abs(head.x - tail.x) > 1 || abs(head.y - tail.y) > 1 {
            tail.x += (head.x - tail.x).signum()
            tail.y += (head.y - tail.y).signum()
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 09 part 02")
            let input = try readLines().map { try parser.parse($0) }

            var knots = Array(repeating: Pair(x: 0, y: 0), count: 10)
            var visited: Set<Pair> = [knots.last!]

            for move in input {
                for _ in 0..<move.steps {
                    Script.move(head: &knots[0], direction: move.dir)
                    for (i,j) in zip(knots.indices, knots.indices.dropFirst()) {
                        drag(head: knots[i], tail: &knots[j])
                    }
                    visited.insert(knots.last!)
                }
            }
            print(visited.count)
        }
    }
}

struct Pair: Hashable, Equatable {
    var x: Int
    var y: Int
}
