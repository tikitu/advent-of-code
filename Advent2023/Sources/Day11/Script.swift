import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

extension CharGrid { // just these puzzles
    mutating func expandRows() {
        var newRows: [[Character]] = []
        for row in rows {
            if row.allSatisfy({ $0 == "." }) {
                newRows.append(row)
            }
            newRows.append(row)
        }
        self.rows = newRows
    }

    mutating func expandCols() {
        var grid = self
        grid.transpose()
        grid.expandRows()
        grid.transpose()
        self = grid
    }

    func emptyRows() -> [Int] {
        rows.indices.filter {
            rows[$0].allSatisfy { $0 == "." }
        }
    }
    func emptyCols() -> [Int] {
        var grid = self
        grid.transpose()
        return grid.emptyRows()
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 11",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 11 part 1")
            var grid = CharGrid(lines: readLines())
            grid.expandRows()
            grid.expandCols()

            let galaxies: [Point] = grid.points { $0 == "#" }
            let pairs = galaxies.combinations(ofCount: 2)
            let distances = pairs
                .map {
                    $0[0].manhattan($0[1])
                }
            print(distances)
            print(distances.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 11 part 2")
            let grid = CharGrid(lines: readLines())
            let emptyRows = grid.emptyRows()
            let emptyCols = grid.emptyCols()

            let galaxies: [Point] = grid.points { $0 == "#" }
            let pairs = galaxies.combinations(ofCount: 2)
            let distances = pairs
                .map {
                    var distance = $0[0].manhattan($0[1])
                    let rowRange = $0[0].rows(to: $0[1])
                    distance += emptyRows.filter { rowRange.contains($0) }.count * 999_999
                    let colRange = $0[0].cols(to: $0[1])
                    distance += emptyCols.filter { colRange.contains($0) }.count * 999_999
                    return distance
                }
            print(distances.reduce(0, +))
        }
    }
}
