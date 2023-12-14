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
            let lines = readLines()
            let grids: [Grid<Bool>] = lines.split(whereSeparator: { $0.isEmpty })
                .map { $0.map { $0.map { $0 == "." } } }
                .map { Grid(rows: $0) }

            let example = grids[0]
            print(example.pretty(true: ".", false: "#"))
            print(example.rowDifferences().pretty())
            print(example.rowDifferences().southWestDiagonals())
            print()
            print(example.transposed().rowDifferences().pretty())
            print(example.transposed().rowDifferences().southWestDiagonals())

            let reflections = grids.map {
                print("\n\n\($0.pretty(true: ".", false: "#"))")
                if let horizontal = $0.rowDifferences().southWestDiagonals().firstIndex(of: 1) {
                    print($0.rowDifferences().pretty())
                    let countBefore = ((horizontal + 1) / 2)
                    print("1==> \(countBefore) * 100")
                    return countBefore * 100
                } else if let horizontal = $0.rowDifferences().southWestDiagonals().firstIndex(of: 2) {
                    print($0.rowDifferences().pretty())
                    let countBefore = ((horizontal + 1) / 2)
                    print("2==> \(countBefore) * 100")
                    return countBefore * 100
                } else if let vertical = $0.transposed().rowDifferences().southWestDiagonals().firstIndex(of: 1) {
                    print($0.transposed().rowDifferences().pretty())
                    let countBefore = ((vertical + 1) / 2)
                    print("3==> \(countBefore)")
                    return countBefore
                } else if let vertical = $0.transposed().rowDifferences().southWestDiagonals().firstIndex(of: 2) {
                    print($0.transposed().rowDifferences().pretty())
                    let countBefore = (vertical / 2) + 1
                    print("4==> \(countBefore)")
                    return countBefore
                } else {
                    let grid = $0
                    print("=====FAILURE=====")
                    print(grid.pretty(true: ".", false: "#"))
                    print(grid.rowDifferences().pretty())
                    print(grid.rowDifferences().southWestDiagonals())
                    print()
                    print(grid.transposed().rowDifferences().pretty())
                    print(grid.transposed().rowDifferences().southWestDiagonals())
                    assertionFailure()
                    return 0
                }
            }
            print(reflections.reduce(0, +))
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

    func rowDifferences() -> Grid<Int> {
        var diffs = Array(repeating: Array(repeating: 0, count: rows.count), count: rows.count)
        for (i1, row1) in rows.enumerated() {
            for (i2, row2) in rows.enumerated() {
                assert(diffs.indices.contains(i1), "i1: \(i1), diffs:\(diffs)")
                assert(diffs[i1].indices.contains(i2), "i2:\(i2), diffs:\(diffs)")
                diffs[i1][i2] = zip(row1, row2).map { if $0 == $1 { 0 } else { 1 } }.reduce(0, +)
            }
        }
        return Grid<Int>(rows: diffs)
    }
}

extension Grid where Cell == Bool {
    func pretty(true: Character, false: Character) -> String {
        Grid<Character>(rows: rows.map { $0.map { if $0 { `true` } else { `false` }}})
            .pretty(separator: "")
    }
}

extension Grid where Cell == Int {
    func southWestDiagonals() -> [Int] {
        (0..<rows.count * 2).map { i in
            (0...i).compactMap { j in
                guard rows.indices.contains(i-j),
                      rows[i-j].indices.contains(j)
                else { return nil }
                return rows[i-j][j]
            }.reduce(0, +)
        }.dropFirst() // skip the first one, it's always 0 (rows[0] == rows[0])
            .map { $0 }
    }
}
