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

    var pretty: String {
        rows.map {
            String($0)
        }.joined(separator: "\n")
    }

    subscript(row row: Int, col col: Int) -> Character? {
        guard row >= 0, row < rows.count,
              col >= 0, col < rows[0].count
        else { return nil }
        return rows[row][col]
    }

    func neighbours(row: Int, col: Int) -> [Character] {
        [-1, 0, 1].map { dX in
            [-1, 0, 1].map { dY in
                guard dX != 0 || dY != 0 else { return nil }
                return self[row: row + dX, col: col + dY]
            }.compactMap { $0 }
        }.flatMap { $0 }
    }

    mutating func filter(replacement: Character = " ", _ predicate: (Character) -> Bool) {
        rows = rows.map {
            $0.map {
                if predicate($0) { $0 } else { replacement }
            }
        }
    }

    func convolve(replacement: Character = " ", _ predicate: (Int, Int) -> Bool) -> Grid {
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

    func diff(_ other: Grid) -> String {
        guard rows.count == other.rows.count,
              rows[0].count == other.rows[0].count
        else { fatalError() }
        return rows.indices.map { row in
            rows[row].indices.map { col in
                let cell = rows[row][col]
                if cell == "." || rows[row][col] != other.rows[row][col] {
                    return String(cell)
                } else {
                    return "\u{1b}[31;1;4m\(rows[row][col])\u{1b}[0m"
                }
            }.joined(separator: "")
        }.joined(separator: "\n")
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
            var grid = Grid(lines: readLines())
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

extension Grid {
    mutating func numbersWithAdjacentSymbols(replacement: Character = " ") {
        var reduced = Grid(lines: [])

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
