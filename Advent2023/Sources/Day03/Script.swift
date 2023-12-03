import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Grid {
    var rows: [[Character]]
    init(lines: [String]) {
        rows = lines.map { $0.map { $0} }
    }

    subscript(row row: Int, col col: Int) -> Character? {
        guard row >= 0, row < rows.count,
              col >= 0, col < rows[0].count
        else { return nil }
        return rows[row][col]
    }
}

extension Character {
    var isSymbol: Bool {
        self != "." && !isNumber
    }
}
extension Optional where Wrapped == Character {
    var isSymbol: Bool {
        self?.isSymbol ?? false
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 03",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let grid = Grid(lines: readLines())

            var numbersWithAdjacentSymbols: [[Character]] = []

            var reduced = Grid(lines: [])

            for rowIdx in grid.rows.indices {
                var row: [Character] = []

                var number: [Character] = []
                var hasAdjacentSymbol = false
                for colIdx in grid.rows[rowIdx].indices {
                    let next = grid.rows[rowIdx][colIdx]
                    hasAdjacentSymbol = (
                        hasAdjacentSymbol
                        || grid[row: rowIdx, col: colIdx].isSymbol
                        || grid[row: rowIdx - 1, col: colIdx].isSymbol
                        || grid[row: rowIdx + 1, col: colIdx].isSymbol)
                    if next.isNumber {
                        // number
                        number.append(next)
                    } else if next == "." {
                        // empty
                        if !number.isEmpty && hasAdjacentSymbol {
                            numbersWithAdjacentSymbols.append(number)
                            row.append(contentsOf: number)
                        } else {
                            row.append(contentsOf: Array(repeating: " ", count: number.count))
                        }
                        number = []
                        hasAdjacentSymbol = (
                            grid[row: rowIdx - 1, col: colIdx].isSymbol
                            || grid[row: rowIdx + 1, col: colIdx].isSymbol)
                        row.append(next)
                    } else {
                        // symbol
                        if !number.isEmpty && hasAdjacentSymbol {
                            numbersWithAdjacentSymbols.append(number)
                        } else {
                            row.append(contentsOf: Array(repeating: " ", count: number.count))
                        }
                        number = []
                        hasAdjacentSymbol = true
                        row.append(next)
                    }
                }
                if !number.isEmpty && hasAdjacentSymbol {
                    numbersWithAdjacentSymbols.append(number)
                }
                reduced.rows.append(row)
            }

            print(
                reduced.rows.map {
                    String($0)
                }.joined(separator: "\n")
            )

            let partNumbers = numbersWithAdjacentSymbols
                .map { Int(String($0))! }

            let total = partNumbers
                .reduce(0, +)
            print(total)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 03 part 2")
        }
    }
}
