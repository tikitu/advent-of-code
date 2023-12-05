import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct MapRange {
    var to: Int
    var from: Int
    var length: Int
    var delta: Int { to - from }

    func apply(to n: Int) -> Int? {
        let delta = n - from
        return if delta >= 0 && delta < length {
            to + delta
        } else {
            nil
        }
    }

    func apply(to range: ClosedRange<Int>) -> ClosedRange<Int>? {
        if range.upperBound < from {
            return nil
        }
        if range.lowerBound >= from+length {
            return nil
        }
        return ClosedRange(uncheckedBounds: (
            max(range.lowerBound + delta, to),
            min(to+length-1, range.upperBound+delta)))
    }

    static func parser() -> some Parser<Substring, MapRange> {
        Parse(MapRange.init(to:from:length:)) {
            Int.parser()
            Whitespace()
            Int.parser()
            Whitespace()
            Int.parser()
        }
    }
}
extension ClosedRange<Int> {
    func split(at points: Set<Int>) -> [ClosedRange<Int>] {
        var latest = self.lowerBound
        var result: [ClosedRange<Int>] = []
        for point in points.sorted() {
            if self.contains(point) {
                result.append(ClosedRange(uncheckedBounds: (latest, point)))
                latest = point + 1
            }
        }
        if self.contains(latest) { // might be upperBound+1 (sigh)
            result.append(ClosedRange(uncheckedBounds: (latest, self.upperBound)))
        }
        return result
    }
}
struct Map {
    var from: String
    var to: String
    var ranges: [MapRange]

    func apply(to n: Int) -> Int {
        ranges.firstNonNil { $0.apply(to: n) } ?? n
    }

    func apply(to range: ClosedRange<Int>) -> [ClosedRange<Int>] {
        // split range into chunks aligned with my ranges
        let splitPoints = ranges
            .sorted(by: { $0.from < $1.from })
            .flatMap { [$0.from, $0.from + $0.length] }
        let deduplicatedSplitPoints = Set(splitPoints)
        let chunks = range.split(at: deduplicatedSplitPoints)

        // apply my ranges to the corresponding chunks
        return chunks.map { chunk in
            ranges.firstNonNil { $0.apply(to: chunk) } ?? chunk
        }
    }

    static func parser() -> some Parser<Substring, Map> {
        Parse(Map.init(from:to:ranges:)) {
            PrefixUpTo("-").map { String($0) }
            "-to-"
            PrefixUpTo(" ").map { String($0) }
            " map:\n"
            Many {
                MapRange.parser()
            } separator: {
                "\n"
            }
        }
    }
}
struct File {
    var seeds: [Int]
    var maps: [Map]
    var seedRanges: [ClosedRange<Int>] {
        seeds.chunks(ofCount: 2)
            .compactMap {
                guard $0.last! > 0 else { return nil }
                return ClosedRange(uncheckedBounds: (lower: $0.first!, upper: $0.first! + $0.last! - 1))
            }
    }

    func apply(to n: Int) -> Int {
        //print("")
        return maps.reduce(n, {
            //print($0, terminator: " ")
            return $1.apply(to: $0)
        })
    }

    func apply(to range: ClosedRange<Int>) -> [ClosedRange<Int>] {
        print("")
        // print("[\(range)]")
        return maps.reduce(
            [range],
            { (accum, map) in
                // print(accum, terminator: " ")
                // print("via \(map.from) to \(map.to): ", terminator: "")
                return accum.flatMap { map.apply(to: $0) }
            }
        )
    }

    static func parser() -> some Parser<Substring, File> {
        Parse(File.init(seeds:maps:)) {
            "seeds: "
            Many {
                Int.parser()
            } separator: {
                " "
            } terminator: {
                "\n\n"
            }
            Many {
                Map.parser()
            } separator: {
                "\n\n"
            } terminator: {
                End()
            }
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 05",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            let input = readLines().joined(separator: "\n")
            let parsed = try File.parser().parse(input)
            let all = parsed.seeds.map { parsed.apply(to: $0) }
            print(all)
            print(all.min()!)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            let input = readLines().joined(separator: "\n")
            let parsed = try File.parser().parse(input)
            let all = parsed.seedRanges.flatMap { parsed.apply(to: $0) }
            print("")
            print(all.map { $0.lowerBound }.min()!)
        }
    }
}
