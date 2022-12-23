import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 22",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 22 part 01")
            let input = readLines()
            var map = Canvas(values: [:], initial: Bool?.none)
            for (y, line) in input.prefix(while: { !$0.isEmpty }).enumerated() {
                for (x, char) in line.enumerated() {
                    switch char {
                    case " ":
                        continue
                    case ".":
                        map[x: x, y: y] = true
                    case "#":
                        map[x: x, y: y] = false
                    default:
                        fatalError("didn't expect \(char)")
                    }
                }
            }
            map.computeMaxes()

            map.prettyPrint {
                switch $0 {
                case nil:
                    return " "
                case true?:
                    return "."
                case false?:
                    return "#"
                }
            }

            var state = State(map: map)
            let instructions = try path(input.last!)
            print(instructions)

            for (move, turn) in instructions {
                state.move(move)
                if let turn {
                    state.turn(turn)
                }
            }
            print(state.position)
            print(state.direction)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 22 part 02")
            // let input = readLines()
        }
    }
}

struct State {
    let map: Canvas<Bool?>
    var position: Point
    var direction: Direction

    init(map: Canvas<Bool?>) {
        self.map = map
        self.position = Point(x: map.rows[0].lowerBound, y: 0)
        self.direction = .e
    }

    mutating func turn(_ t: Turn) {
        switch (t, self.direction) {
        case (.l, .n), (.r, .s):
            self.direction = .w
        case (.l, .s), (.r, .n):
            self.direction = .e
        case (.l, .w), (.r, .e):
            self.direction = .s
        case (.l, .e), (.r, .w):
            self.direction = .n
        }
    }

    mutating func move(_ steps: Int) {
        for _ in 0..<steps {
            var next = self.position
            switch self.direction {
            case .n:
                next.y -= 1
                if next.y < map.cols[next.x].lowerBound {
                    next.y = map.cols[next.x].upperBound
                }
            case .s:
                next.y += 1
                if next.y > map.cols[next.x].upperBound {
                    next.y = map.cols[next.x].lowerBound
                }
            case .w:
                next.x -= 1
                if next.x < map.rows[next.y].lowerBound {
                    next.x = map.rows[next.y].upperBound
                }
            case .e:
                next.x += 1
                if next.x > map.rows[next.y].upperBound {
                    next.x = map.rows[next.y].lowerBound
                }
            }
            if map[next]! == true {
                self.position = next
            }
        }
    }
}

enum Direction: String, CaseIterable {
    case n, s, w, e
}

enum Turn: String, CaseIterable {
    case l = "L"
    case r = "R"
}

func path(_ line: String) throws -> [(Int, Turn?)] {
    let moves = try Parse {
        Many {
            Digits()
        } separator: {
            Turn.parser()
        }
    }.parse(line)
    let turns = try Parse {
        Skip { Digits() }
        Many {
            Turn.parser()
        } separator: {
            Digits()
        } terminator: {
            Digits()
        }
    }.parse(line)
    return zip(moves, turns.map { $0 }) + [(moves.last!, nil)]
}

struct Point: Hashable {
  var x: Int
  var y: Int
}

extension Point: CustomStringConvertible {
    var description: String { "\(x),\(y)" }
}


struct Canvas<Value> {
    var values: [Point: Value] = [:]
    let initial: Value
    var maxX: Int
    var maxY: Int
    var rows: [ClosedRange<Int>]
    var cols: [ClosedRange<Int>]

    init(values: [Point : Value], initial: Value) {
        self.values = values
        self.initial = initial
        self.maxX = 0
        self.maxY = 0
        self.rows = []
        self.cols = []
        computeMaxes()
    }

    mutating func computeMaxes() {
        maxX = values.keys.map(\.x).max() ?? -1
        maxY = values.keys.map(\.y).max() ?? -1
        var rows = Array<ClosedRange<Int>?>(repeating: nil, count: maxY + 1)
        var cols = Array<ClosedRange<Int>?>(repeating: nil, count: maxX + 1)
        for point in values.keys {
            if rows[point.y] == nil {
                rows[point.y] = ClosedRange(uncheckedBounds: (lower: point.x, upper: point.x))
            } else {
                rows[point.y]!.expandToInclude(point.x)
            }
            if cols[point.x] == nil {
                cols[point.x] = ClosedRange(uncheckedBounds: (lower: point.y, upper: point.y))
            } else {
                cols[point.x]!.expandToInclude(point.y)
            }
        }
        self.rows = rows.map { $0! }
        self.cols = cols.map { $0! }
    }

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

extension ClosedRange {
    mutating func expandToInclude(_ value: Bound) {
        if value < lowerBound {
            self = Self(uncheckedBounds: (lower: value, upper: upperBound))
        }
        if value > upperBound {
            self = Self(uncheckedBounds: (lower: lowerBound, upper: value))
        }
    }
}

extension Canvas where Value: Equatable {
    func prettyPrint(space: String = "", _ f: (Value) -> String) {
        guard let xRange = values.keys.map(\.x).minAndMax() else { return }
        guard let yRange = values.keys.map(\.y).minAndMax() else { return }
        for y in yRange.min...yRange.max {
            for x in xRange.min...xRange.max {
                if y == cols[x].lowerBound || y == cols[x].upperBound
                    || x == rows[y].lowerBound || x == rows[y].upperBound {
                    print("*", terminator: space)
                } else {
                    print(f(self[x: x, y: y]), terminator: space)
                }
            }
            print("")
        }
        print("")
    }
}
