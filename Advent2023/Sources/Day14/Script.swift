import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 14",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 14 part 1")
            var grid = CharGrid(lines: readLines())
            while true {
                let newGrid = grid.convolve { (p: Point) in
                    if grid[p] == "." && grid[p.south] == "O" {
                        return "O"
                    }
                    if grid[p] == "O" && grid[p.north] == "." {
                        return "."
                    }
                    return grid[p]!
                }
                if newGrid == grid {
                    break
                }
                grid = newGrid
            }
            print(grid.pretty)
            let weights = grid.rows.reversed().enumerated().map { (idx, row) in
                (idx + 1) * row.filter { $0 == "O" }.count
            }
            print(weights)
            print(weights.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 14 part 2")

            print((1_000_000_000 - 109) % (131 - 109)) // -> 11

            var grid = CharGrid(lines: readLines())
            var past: [CharGrid: Int] = [:]
//            for i in 1...1000 {
            for i in 1...(109+11) {
                past[grid] = i-1
                let didChange = grid.cycle()
                print("\(i): \(didChange)")
                print(grid.pretty)
                if let previous = past[grid] {
                    print("cycle! \(previous)->\(i)") // after previous cycles, and again after i cycles
                    break // got one! at 109->131
                }
            }
            let weights = grid.rows.reversed().enumerated().map { (idx, row) in
                (idx + 1) * row.filter { $0 == "O" }.count
            }
            print(weights)
            print(weights.reduce(0, +))
        }
    }
}

extension CharGrid {
    mutating func roll(from: KeyPath<Point, Point>, to: KeyPath<Point, Point>) {
        while true {
            let newGrid = self.convolve { (p: Point) in
                if self[p] == "." && self[p[keyPath: from]] == "O" {
                    return "O"
                }
                if self[p] == "O" && self[p[keyPath: to]] == "." {
                    return "."
                }
                return self[p]!
            }
            if newGrid == self {
                break
            }
            self = newGrid
        }
    }

    /// returns whether there was a change
    mutating func cycle() -> Bool {
        let previous = self
        roll(from: \.south, to: \.north)
        roll(from: \.east, to: \.west)
        roll(from: \.north, to: \.south)
        roll(from: \.west, to: \.east)
        return self != previous
    }
}
