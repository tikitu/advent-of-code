import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 8",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func calculateVisible(_ trees: [Int]) -> Set<Int> {
            var highest = -1
            var visibleIndices = Set<Int>()
            for (i, tree) in trees.enumerated() {
                if tree > highest {
                    highest = tree
                    visibleIndices.insert(i)
                }
            }
            return visibleIndices
        }

        func visibleFromSides(input: [[Int]], visible: inout Set<Pair>) {
            for (x, row) in input.enumerated() {
                let visibleRowIndices = calculateVisible(row)
                for y in visibleRowIndices {
                    visible.insert(Pair(a: x, b: y))
                }
            }
            for (x, row) in input.map({ $0.reversed() }).enumerated() {
                let visibleRowIndices = calculateVisible(Array(row))
                for y in visibleRowIndices {
                    visible.insert(Pair(a: x, b: row.count - y - 1))
                }
            }
        }

        func run() throws {
            print("day 08 part 01")
            let input = readLines().map { $0.map { Int("\($0)")! } }

            var visible = Set<Pair>()
            visibleFromSides(input: input, visible: &visible)
            var visibleTransposed = Set<Pair>()
            let transposed = input.transposed()
            visibleFromSides(input: transposed, visible: &visibleTransposed)

            visible.formUnion(visibleTransposed.map { Pair(a: $0.b, b: $0.a) })
            print(visible.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 08 part 02")
            let rows = readLines().map { $0.map { Int("\($0)")! } }
            calculate(rows: rows)
        }

        func calculate(rows: [[Int]]) {
            let cols = rows.transposed()

            let horizontalViews = rows[1..<rows.count - 1].map { row in
                horizontal(row: row)
            }
            let verticalViews = cols[1..<cols.count - 1].map { col in
                horizontal(row: col)
            }.transposed()
            print(horizontalViews)
            print(verticalViews)
            let totalViews = horizontalViews.pointWiseMultiply(other: verticalViews)
            print(totalViews)
            print(totalViews.map { $0.max()! }.max()!)
        }

        func horizontal(row: [Int]) -> [Int] {
            zip(lookingLeft(row: row), lookingLeft(row: row.reversed()).reversed()).map { $0 * $1 }
        }
        func lookingLeft(row: [Int]) -> [Int] {
            let row = Array(row[1..<row.count - 1])
            return row.enumerated().map { (i, tree) in
                var cursor = i - 1
                var left = 1
                while cursor >= 0 {
                    if row[cursor] >= row[i] {
                        return left
                    }
                    cursor -= 1
                    left += 1
                }
                return left
            }
        }
    }
}

struct Pair: Hashable, Equatable {
    var a: Int
    var b: Int
}

extension Array where Element == Array<Int> {
    func transposed() -> Self {
        self[0].indices.map { index in
            self.map { $0[index] }
        }
    }
    func pointWiseMultiply(other: [[Int]]) -> [[Int]] {
        zip(self, other).map { (rowSelf, rowOther) in
            zip(rowSelf, rowOther).map { $0 * $1 }
        }
    }
}
