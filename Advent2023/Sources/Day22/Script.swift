import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Brick: Equatable {
    var x: ClosedRange<Int>
    var y: ClosedRange<Int>
    var z: ClosedRange<Int>

    static func parser() -> some Parser<Substring, Brick> {
        Parse {
            Int.parser()
            ","
            Int.parser()
            ","
            Int.parser()
            "~"
            Int.parser()
            ","
            Int.parser()
            ","
            Int.parser()
        }.map {
            .init(x: .init(unordered: ($0.0, $0.3)),
                  y: .init(unordered: ($0.1, $0.4)),
                  z: .init(unordered: ($0.2, $0.5)))
        }
    }

    func isAbove(_ other: Brick) -> Bool {
        if self == other { return false }
        if !self.x.overlaps(other.x) { return false }
        if !self.y.overlaps(other.y) { return false }
        return self.z.lowerBound > other.z.upperBound
    }

    func isOn(_ other: Brick) -> Bool {
        if self == other { return false }
        if !self.x.overlaps(other.x) { return false }
        if !self.y.overlaps(other.y) { return false }
        return self.z.lowerBound == other.z.upperBound + 1
    }
}

extension ClosedRange<Int> {
    init(unordered ends: (Int, Int)) {
        self.init(uncheckedBounds: (lower: Swift.min(ends.0, ends.1),
                                    upper: Swift.max(ends.0, ends.1)))
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 22",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 22 part 1")
            var bricks = try readLines().map { try Brick.parser().parse($0) }
            bricks.sort(by: { $0.z.upperBound < $1.z.lowerBound })
            bricks.sort(by: { $0.z.lowerBound < $1.z.lowerBound })

            let overlaps: [Set<Int>] = bricks.map { brick in
                Set(
                    bricks.enumerated().filter { (idx, other) in
                        if brick == other { return false }
                        if !brick.x.overlaps(other.x) { return false }
                        if !brick.y.overlaps(other.y) { return false }
                        return true
                    }.map { $0.offset }
                )
            }

            // compact the bricks by falling: only with direct contact are heights reliable
            for (idx, brick) in bricks.enumerated() { // by ascending height
                let support = overlaps[idx].filter { $0 < idx }.map { bricks[$0] }
                let supportLevel = support.map { $0.z.upperBound }.max() ?? -1
                assert(
                    brick.z.lowerBound > supportLevel,
                    "brick \(brick) with support \(support)")
                let drop = brick.z.lowerBound - (supportLevel + 1)
                assert(supportLevel < brick.z.upperBound - drop,
                       "drop \(drop) to \(supportLevel) from \(brick): require \(supportLevel) < \(brick.z.upperBound - drop)")
                assert(supportLevel < brick.z.lowerBound - drop,
                       "drop \(drop) to \(supportLevel) from \(brick): require \(supportLevel) < \(brick.z.lowerBound - drop)")
                bricks[idx].z = .init(uncheckedBounds: (lower: brick.z.lowerBound - drop,
                                                        upper: brick.z.upperBound - drop))
            }

            let supports = Grid<Int>(
                 rows: bricks.map { brick in
                     bricks.map { if $0.isOn(brick) { 1 } else { 0 } }
                 }
             )
            print(supports.pretty(separator: ""))
            let supportedBy = supports.transposed()
            let supportedByCounts = supportedBy.rows.map { $0.reduce(0, +) }
            let safe = supports.rows.filter { others in
                others.enumerated().allSatisfy { (idx, above) in
                    if above > 0 {
                        return supportedByCounts[idx] > 1
                    } else {
                        return true
                    }
                }
            }
            print(safe.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 22 part 2")
        }
    }
}
