import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

enum Direction: String, CaseIterable, Comparable, Hashable {
    static func < (lhs: Direction, rhs: Direction) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }
    
    case right = "R"
    case left = "L"
    case down = "D"
    case up = "U"

    var isVertical: Bool {
        switch self {
        case .right:
            false
        case .left:
            false
        case .down:
            true
        case .up:
            true
        }
    }
}

extension Point {
    func move(_ dir: Direction) -> Point {
        switch dir {
        case .right:
            self.east
        case .left:
            self.west
        case .down:
            self.south
        case .up:
            self.north
        }
    }
}
struct Cell: Comparable, Hashable, Equatable {
    static func < (lhs: Cell, rhs: Cell) -> Bool {
        if lhs.p < rhs.p { return true }
        if lhs.p > rhs.p { return false }
        return lhs.type < rhs.type
    }
    
    var p: Point
    var type: CellType
}
enum CellType: Comparable, Equatable, Hashable {
    static func < (lhs: CellType, rhs: CellType) -> Bool {
        switch (lhs, rhs) {
        case (let lhs, let rhs) where lhs == rhs:
            return false
        case (.hor, _), (_, .vert):
            return true
        case (.vert, _), (_, .hor):
            return false
        case (.corner(let lhs), .corner(let rhs)):
            return !lhs && rhs
        case (.corner, .inside):
            return true
        case (.inside, .corner):
            return false
        case (.inside, .inside):
            return false
        }
    }
    
    case hor, corner(Bool), inside, vert
}

struct Line {
    var dir: Direction
    var count: Int
    var color: String

    static func parser() -> some Parser<Substring, Line> {
        Parse(Line.init(dir:count:color:)) {
            Direction.parser()
            Whitespace()
            Int.parser()
            Whitespace()
            "(#"
            CharacterSet.alphanumerics.map { String($0) }
            ")"
        }
    }

    var decodingColor: Self {
        var new = self
        switch color.last {
        case "0":
            new.dir = .right
        case "1":
            new.dir = .down
        case "2":
            new.dir = .left
        case "3":
            new.dir = .up
        default:
            assertionFailure("expected [0123] got \(String(describing: color.last))")
        }
        new.count = Int(color.dropLast(), radix: 16)!
        return new
    }
}

struct GrowableGrid {
    var points: Set<Point>

    var pretty: String {
        let cols = points.reduce(0...0) { min($0.lowerBound, $1.col)...max($0.upperBound, $1.col) }
        let rows = points.grouped(by: { $0.row }).mapValues { Set($0) }
        // ASSUMING CONTIGUOUS! it's ok for THIS puzzle, not in general
        return rows.keys.sorted().map { rowIdx in
            let row = rows[rowIdx]!
            return cols.map { col -> String in
                if row.contains(Point(row: rowIdx, col: col)) {
                    "#"
                } else {
                    "."
                }
            }.joined()
        }.joined(separator: "\n")
    }
}

/// "ray casting" across the shape to fill it in (sort of)
enum RayState {
    case inside, outside, edge
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 18",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 18 part 1")
            var lines = readLines().map { try! Line.parser().parse($0) }
            lines.append(lines[0])

            var point = Point(row: 0, col: 0)
            var trace: Set<Cell> = []
            for pair in lines.adjacentPairs() {
                var isClockwise: Bool
                switch (pair.0.dir, pair.1.dir) {
                case (.left, .up), (.up, .right), (.right, .down), (.down, .left):
                    isClockwise = true
                case (.left, .down), (.up, .left), (.right, .up), (.down, .right):
                    isClockwise = false
                case (_, _): // THIS puzzle strictly alternates
                    continue
                }
                for i in 1...pair.0.count {
                    point = point.move(pair.0.dir)
                    if i < pair.0.count {
                        trace.insert(Cell(p: point, type: pair.0.dir.isVertical ? .vert : .hor))
                    }
                }
                trace.insert(Cell(p: point, type: .corner(isClockwise)))
            }

            print(GrowableGrid(points: Set(trace.map { $0.p })).pretty)
            print("")
            let first = trace.min()!
            print(first)
            print("")
            let rows = trace.grouped(by: { $0.p.row }).mapValues { $0.sorted() }

            guard case let CellType.corner(clockwise)? = trace.min()?.type else {
                preconditionFailure("should have a corner first! got \(trace.min()!)")
            }

            for row in rows.values {
                var state: RayState = .outside
                var latest: Point? = nil
                for cell in row {
                    switch cell.type {
                    case .inside:
                        assertionFailure("we haven't calculated any inside yet! \(cell)")
                    case .hor:
                        assert(state == .edge, "expected to be in edge at \(cell) but was \(state)")
                    case .corner(let isClockwise):
                        switch state {
                        case .outside:
                            assert(isClockwise == clockwise, "expected clockwise at \(cell)")
                            state = .edge
                        case .inside:
                            assert(isClockwise != clockwise, "expected anticlockwise at \(cell)")
                            state = .outside
                            if let latestInside = latest {
                                for col in (latestInside.col+1)..<cell.p.col {
                                    trace.insert(Cell(p: .init(row: cell.p.row, col: col), type: .inside))
                                }
                                latest = nil
                            }
                            state = .edge
                        case .edge:
                            if isClockwise == clockwise {
                                state = .outside
                            } else {
                                state = .inside
                                latest = cell.p
                            }
                        }
                    case .vert:
                        switch state {
                        case .inside:
                            state = .outside
                            if let latestInside = latest {
                                for col in (latestInside.col+1)..<cell.p.col {
                                    trace.insert(Cell(p: .init(row: cell.p.row, col: col), type: .inside))
                                }
                                latest = nil
                            }
                        case .outside:
                            state = .inside
                            latest = cell.p
                        case .edge:
                            assertionFailure("transition from edge via vert without corner! \(cell)")
                        }
                    }

                }
            }
            print("")
            print(GrowableGrid(points: Set(trace.map { $0.p })).pretty)
            print(trace.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 18 part 2")
            let lines = readLines().map { try! Line.parser().parse($0) }.map { $0.decodingColor }
            lines.forEach {
                print($0)
            }
        }
    }
}
