import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 15",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 15 part 01")
            let input = try readLines()
                .map(parseLine(_:))
            print(input)

            let row = 2000000
            let candidates = input.filter {
                $0.manhattanDistance > abs(row - $0.at.y)
            }
            print(candidates)

            func overlap(_ sensor: Sensor) -> ClosedRange<Int> {
                let spill = sensor.manhattanDistance - abs(row - sensor.at.y)
                return (sensor.at.x - spill)...(sensor.at.x + spill)
            }

            let result: [Point] = candidates
                .map(overlap(_:))
                .reduce(into: Set<Int>()) { $0.formUnion($1) }
                .map { Point(x: $0, y: row) }
            let setResult = Set(result)
                .subtracting(input.map(\.closestBeacon))
            print(setResult.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 15 part 02")
            let sensors = try readLines()
                .map(parseLine(_:))
                .sorted(by: { $0.minY <= $1.minY })

            let totalRange = 0..<4_000_000
            for y in totalRange {
                if y.isMultiple(of: 100) {
                    print("\r\(y)", terminator: "")
                }
                let ranges: [Range<Int>] = sensors.filter { y >= $0.minY && y <= $0.maxY }
                    .map { $0.overlap(y: y) }
                    .filter { $0.overlaps(totalRange) }
                    .map { $0.clamped(to: totalRange) }
                var transitions: [(Int, Bool)] = ranges
                    .reduce(into: []) {
                        $0.append(($1.lowerBound, true))
                        if $1.upperBound < totalRange.upperBound {
                            $0.append(($1.upperBound, false))
                        }
                    }
                transitions.sort(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1) }) // tiebreaker: ins first!
                var inside = 0
                for transition in transitions {
                    if transition.1 {
                        inside += 1
                    } else {
                        inside -= 1
                    }
                    if inside == 0 {
                        print("\nFOUND IT \(transition.0),\(y)")
                        return
                    }
                }
            }
            print("done")
        }
    }
}

struct Sensor {
    init(at: Point, closestBeacon: Point) {
        self.at = at
        self.closestBeacon = closestBeacon
        self.manhattanDistance = abs(at.x - closestBeacon.x) + abs(at.y - closestBeacon.y)
        self.minY = at.y - manhattanDistance
        self.maxY = at.y + manhattanDistance
    }

    var at: Point
    var closestBeacon: Point
    var manhattanDistance: Int
    var minY: Int
    var maxY: Int

    func overlap(y: Int) -> Range<Int> {
        // we ASSUME this (check it elsewhere)
        // guard y >= minY, y <= maxY else { return nil }
        let dY = manhattanDistance - abs(y - at.y)
        return (at.x - dY)..<(at.x + dY + 1)
    }
}

func parseLine(_ line: String) throws -> Sensor {
    let parser = Parse(Sensor.init(at:closestBeacon:)) {
        "Sensor at x="
        Parse(Point.init(x:y:)) {
            Int.parser()
            ", y="
            Int.parser()
        }
        ": closest beacon is at x="
        Parse(Point.init(x:y:)) {
            Int.parser()
            ", y="
            Int.parser()
        }
    }
    return try parser.parse(line)
}

struct Point: Hashable {
  var x: Int
  var y: Int
}

extension Point: CustomStringConvertible {
    var description: String { "\(x),\(y)" }
}
