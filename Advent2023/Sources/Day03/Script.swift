import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

extension CharGrid {
    func convolve(replacement: Character = " ", _ predicate: (Int, Int) -> Bool) -> CharGrid {
        var result = self
        for rowIdx in rows.indices {
            for colIdx in rows[rowIdx].indices {
                if !predicate(rowIdx, colIdx) {
                    result.rows[rowIdx][colIdx] = replacement
                }
            }
        }
        return result
    }

    func coordinates(where predicate: (Character) -> Bool) -> [(Int, Int)] {
        rows.indices.flatMap { row in
            rows[row].indices.compactMap { col in
                if predicate(self[row: row, col: col]!) {
                    (row, col)
                } else {
                    nil
                }
            }
        }
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
            let grid = CharGrid(lines: readLines())

            var numbersWithAdjacentSymbols: [[Character]] = []

            var reduced = CharGrid(lines: [])

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
                            row.append(contentsOf: number)
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
                    row.append(contentsOf: number)
                } else {
                    row.append(contentsOf: Array(repeating: " ", count: number.count))
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
            var grid = CharGrid(lines: readLines())
            let original = grid

            grid.filter(replacement: ".") { $0.isNumber || $0 == "." || $0 == "*" }

            print("ONLY * and numbers")
            print(grid.pretty)


            grid = grid.convolve(replacement: ".") { (row, col) in
                guard let cell = grid[row: row, col: col] else { return true }
                if cell != "*" { return true }
                return !grid.neighbours(row: row, col: col).filter { $0.isNumber }.isEmpty
            }

            print("\n\n\n")
            print("has numbers next to *")
            print(grid.pretty)

            grid.numbersWithAdjacentSymbols(replacement: ".")

            print("numbers with adjacent *")
            print(grid.pretty)

            func numbersOnRowAdjacentTo(row: Int, col: Int) -> [String] {
                guard let cell = grid[row: row, col: col] else { return [] }
                if cell.isNumber {
                    var start = col
                    var end = col
                    while grid[row: row, col: start]?.isNumber ?? false {
                        start -= 1
                    }
                    while grid[row: row, col: end]?.isNumber ?? false {
                        end += 1
                    }
                    return [String(grid.rows[row][start+1..<end])]
                } else {
                    var result: [String] = []
                    if grid[row: row, col: col-1]?.isNumber ?? false {
                        var start = col - 1
                        while grid[row: row, col: start]?.isNumber ?? false {
                            start -= 1
                        }
                        result.append(String(grid.rows[row][start+1..<col]))
                    }
                    if grid[row: row, col: col+1]?.isNumber ?? false {
                        var end = col + 1
                        while grid[row: row, col: end]?.isNumber ?? false {
                            end += 1
                        }
                        result.append(String(grid.rows[row][col+1..<end]))
                    }
                    return result
                }
            }

            print("\n\n\n")

            print(original.diff(grid))

            var pairs: [[String]] = []
            for (row, col) in grid.coordinates(where: { $0 == "*" }) {
                let numbers = numbersOnRowAdjacentTo(row: row, col: col)
                + numbersOnRowAdjacentTo(row: row - 1, col: col)
                + numbersOnRowAdjacentTo(row: row + 1, col: col)
                if numbers.count == 2 {
                    pairs.append(numbers)
                }
            }
            print(pairs)

            print(
                pairs.map {
                    $0.map { Int($0)! }
                        .reduce(1, *)
                }
                    .reduce(0, +)
            )
        }
    }
}

extension CharGrid {
    mutating func numbersWithAdjacentSymbols(replacement: Character = " ") {
        var reduced = CharGrid(lines: [])

        for rowIdx in self.rows.indices {
            var row: [Character] = []

            var number: [Character] = []
            var hasAdjacentSymbol = false
            for colIdx in self.rows[rowIdx].indices {
                let next = self.rows[rowIdx][colIdx]
                hasAdjacentSymbol = (
                    hasAdjacentSymbol
                    || self[row: rowIdx, col: colIdx].isSymbol
                    || self[row: rowIdx - 1, col: colIdx].isSymbol
                    || self[row: rowIdx + 1, col: colIdx].isSymbol)
                if next.isNumber {
                    // number
                    number.append(next)
                } else if next == "." {
                    // empty
                    if !number.isEmpty && hasAdjacentSymbol {
                        row.append(contentsOf: number)
                    } else {
                        row.append(contentsOf: Array(repeating: replacement, count: number.count))
                    }
                    number = []
                    hasAdjacentSymbol = (
                        self[row: rowIdx - 1, col: colIdx].isSymbol
                        || self[row: rowIdx + 1, col: colIdx].isSymbol)
                    row.append(next)
                } else {
                    // symbol
                    if !number.isEmpty && hasAdjacentSymbol {
                        row.append(contentsOf: number)
                    } else {
                        row.append(contentsOf: Array(repeating: replacement, count: number.count))
                    }
                    number = []
                    hasAdjacentSymbol = true
                    row.append(next)
                }
            }
            if !number.isEmpty && hasAdjacentSymbol {
                row.append(contentsOf: number)
            } else {
                row.append(contentsOf: Array(repeating: replacement, count: number.count))
            }
            reduced.rows.append(row)
        }
        self = reduced
    }
}
