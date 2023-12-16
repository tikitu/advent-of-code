import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

enum Cell: String, CaseIterable {
    case empty = "."
    case vert = "|"
    case hori = "-"
    case nw = "\\"
    case ne = "/"
}

enum Direction: CaseIterable, Equatable, Hashable {
    case north, west, south, east
}

extension Grid {
    public init(rows: [String], f: (Character) -> Cell) {
        self.init(rows: rows.map { $0.map(f) })
    }
}

extension Grid where Cell: Equatable {
    public subscript(_ p: Point) -> Cell? {
        self[row: p.row, col: p.col]
    }

    public func map<NewCell>(_ f: (Cell) -> NewCell) -> Grid<NewCell> {
        Grid<NewCell>(rows: rows.map { $0.map(f) })
    }
}

struct Beam: Hashable {
    var p: Point
    var dir: Direction

    var next: Point {
        switch dir {
        case .north:
            p.north
        case .west:
            p.west
        case .south:
            p.south
        case .east:
            p.east
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 16",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 16 part 1")
            var puzzle = Grid(rows: readLines()) { Cell(rawValue: "\($0)")! }
            var beams: Set<Beam> = [.init(p: .init(row: 0, col: -1),
                                          dir: .east)]
            var trace: Set<Beam> = []
            while true {
                var nextBeams: [Beam] = beams.flatMap { beam -> [Beam] in
                    switch (puzzle[beam.next], beam.dir) {
                    case (nil, _):
                        return [] as [Beam]
                    case (.empty, _):
                        return [.init(p: beam.next, dir: beam.dir)]
                    case (.vert, .north), (.vert, .south), (.hori, .west), (.hori, .east):
                        return [.init(p: beam.next, dir: beam.dir)]
                    case (.vert, .west), (.vert, .east):
                        return [
                            Beam(p: beam.next, dir: .north),
                            Beam(p: beam.next, dir: .south)
                        ]
                    case (.hori, .north), (.hori, .south):
                        return [
                            Beam(p: beam.next, dir: .west),
                            Beam(p: beam.next, dir: .east)
                        ]
                    case (.nw, _):
                        let dir: Direction = switch beam.dir {
                        case .north:
                                .west
                        case .south:
                                .east
                        case .west:
                                .north
                        case .east:
                                .south
                        }
                        return [Beam(p: beam.next, dir: dir)]
                    case (.ne, _):
                        let dir: Direction = switch beam.dir {
                        case .north:
                                .east
                        case .south:
                                .west
                        case .west:
                                .south
                        case .east:
                                .north
                        }
                        return [Beam(p: beam.next, dir: dir)]
                    }
                }
                    .filter { puzzle[$0.p] != nil }
                if trace.isSuperset(of: nextBeams) {
                    break
                } else {
                    trace.formUnion(nextBeams)
                }
                beams = Set(nextBeams)
            }
            print(Set(trace.map { $0.p }).count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 16 part 2")
            var puzzle = Grid(rows: readLines()) { Cell(rawValue: "\($0)")! }
            func energized(from start: Beam) -> Int {
                var beams: Set<Beam> = [start]
                var trace: Set<Beam> = []
                while true {
                    var nextBeams: [Beam] = beams.flatMap { beam -> [Beam] in
                        switch (puzzle[beam.next], beam.dir) {
                        case (nil, _):
                            return [] as [Beam]
                        case (.empty, _):
                            return [.init(p: beam.next, dir: beam.dir)]
                        case (.vert, .north), (.vert, .south), (.hori, .west), (.hori, .east):
                            return [.init(p: beam.next, dir: beam.dir)]
                        case (.vert, .west), (.vert, .east):
                            return [
                                Beam(p: beam.next, dir: .north),
                                Beam(p: beam.next, dir: .south)
                            ]
                        case (.hori, .north), (.hori, .south):
                            return [
                                Beam(p: beam.next, dir: .west),
                                Beam(p: beam.next, dir: .east)
                            ]
                        case (.nw, _):
                            let dir: Direction = switch beam.dir {
                            case .north:
                                    .west
                            case .south:
                                    .east
                            case .west:
                                    .north
                            case .east:
                                    .south
                            }
                            return [Beam(p: beam.next, dir: dir)]
                        case (.ne, _):
                            let dir: Direction = switch beam.dir {
                            case .north:
                                    .east
                            case .south:
                                    .west
                            case .west:
                                    .south
                            case .east:
                                    .north
                            }
                            return [Beam(p: beam.next, dir: dir)]
                        }
                    }
                        .filter { puzzle[$0.p] != nil }
                    if trace.isSuperset(of: nextBeams) {
                        break
                    } else {
                        trace.formUnion(nextBeams)
                    }
                    beams = Set(nextBeams)
                }
                return Set(trace.map { $0.p }).count
            }
            let counts = (0..<puzzle.rows[0].count).flatMap { i in
                print("..\(i)..")
                return [
                    energized(from: .init(p: .init(row: -1, col: i), dir: .south)),
                    energized(from: .init(p: .init(row: puzzle.rows.count, col: i), dir: .north))
                ]
            } + (0..<puzzle.rows.count).flatMap { i in
                print("..\(i)..")
                return [
                    energized(from: .init(p: .init(row: i, col: -1), dir: .east)),
                    energized(from: .init(p: .init(row: i, col: puzzle.rows[0].count), dir: .west))
                ]
            }
            print(counts.max()!)
        }
    }
}
