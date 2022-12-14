import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 14",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 14 part 01")
            let input = readLines()
            let lines = try input.map { try parseLine($0) }

            var cave = Canvas(initial: false)
            for line in lines {
                cave.trace(line: line, setting: true)
            }
            cave.prettyPrint { $0 ? "#" : "." }

            let bottom = cave.maxY

            var count = 0
            while true {
                var point = Point(x: 500, y: 0)
                var moved = true
                while moved && point.y <= bottom {
                    moved = false
                    if !cave[x: point.x, y: point.y + 1] {
                        point.y += 1
                        moved = true
                    } else if !cave[x: point.x - 1, y: point.y + 1] {
                        point.x -= 1
                        point.y += 1
                        moved = true
                    } else if !cave[x: point.x + 1, y: point.y + 1] {
                        point.x += 1
                        point.y += 1
                        moved = true
                    } else {
                        cave[point] = true
                    }
                }
                //cave.prettyPrint { $0 ? "#" : "." }
                if point.y < bottom { // "came to rest"
                    count += 1
                } else {
                    break
                }
            }
            print(count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 14 part 02")
            // let input = readLines()
        }
    }
}

extension Canvas {
    mutating func trace(line: [Point], setting value: Value) {
        guard !line.isEmpty else { return }
        self[line.first!] = value // in case there's only one point
        for (start, end) in line.adjacentPairs() {
            for x in min(start.x, end.x)...max(start.x, end.x) {
                for y in min(start.y, end.y)...max(start.y, end.y) {
                    self[x: x, y: y] = value
                }
            }
        }
    }
}

func parseLine(_ line: String) throws -> [Point] {
    let point = Parse(Point.init(x:y:)) {
        Digits()
        ","
        Digits()
    }
    let parser = Many {
        point
    } separator: {
        " -> "
    } terminator: {
        End()
    }
    return try parser.parse(line)
}

struct Canvas<Value> {
    var values: [Point: Value] = [:]
    let initial: Value
    var maxX: Int { values.keys.map(\.x).max() ?? 0 }
    var maxY: Int { values.keys.map(\.y).max() ?? 0 }

    subscript(_ point: Point) -> Value {
        get {
            values[point] ?? initial
        }
        set {
            values[point] = newValue
        }
    }

    subscript(x x: Int, y y: Int) -> Value {
        get {
            self[Point(x: x, y: y)]
        }
        set {
            self[Point(x: x, y: y)] = newValue
        }
    }

}

struct Point: Hashable {
    var x: Int
    var y: Int
}

extension Canvas where Value: Equatable {
    func prettyPrint(space: String = "", _ f: (Value) -> String) {
        guard let xRange = values.keys.map(\.x).minAndMax() else { return }
        guard let yRange = values.keys.map(\.y).minAndMax() else { return }
        for y in yRange.min...yRange.max {
            for x in xRange.min...xRange.max {
                print(f(self[x: x, y: y]), terminator: space)
            }
            print("")
        }
        print("")
    }
}
