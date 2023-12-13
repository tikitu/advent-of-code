import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils


@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 13",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 13 part 1")
            let lines = readLines()
            let grids: [Grid<Bool>] = lines.split(whereSeparator: { $0.isEmpty })
                .map { $0.map { $0.map { $0 == "." } } }
                .map { Grid(rows: $0) }

            let reflections = grids.map {
                if let h = $0.horizontalReflection() {
                    return h * 100
                }
                if let v = $0.transposed().horizontalReflection() {
                    return v
                }
                assertionFailure("no reflection found for\n\($0.pretty())\n\n\($0.transposed().pretty())")
                return 0
            }
            print(reflections.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 13 part 2")
        }
    }
}

extension Grid where Cell: Equatable {
    func horizontalReflection() -> Int? {
        var head: [[Cell]] = [rows[0]]
        var tail = rows.dropFirst()
        while tail.count >= 1 {
            if tail.prefix(head.count) == head.prefix(tail.count) {
                return head.count
            }
            head.insert(tail.popFirst()!, at: 0)
        }
        return nil
    }
}
