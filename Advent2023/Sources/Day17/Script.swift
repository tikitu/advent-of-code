import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils
import Collections

enum Direction: CaseIterable, Equatable, Hashable {
    case up, down, left, right

    var withoutReverses: [Self] {
        Self.allCases.filter { $0 != self }
    }
}

extension Point {
    subscript(_ dir: Direction) -> Point {
        switch dir {
        case .up:
            self.north
        case .down:
            self.south
        case .left:
            self.west
        case .right:
            self.east
        }
    }
}

struct Node: Hashable {
    var point: Point
    var latestDirection: Direction?
    var countAtLatestDirection: Int
    var cost: Int
}

extension Grid {
    var points: Set<Point> {
        Set(
            rows.indices.flatMap { row in
                rows[0].indices.map { col in
                    Point(row: row, col: col)
                }
            }
        )
    }
    func mapPoints<T>(_ f: (Point) -> T) -> Grid<T> {
        Grid<T>(
            rows: rows.indices.map { row in
                rows[0].indices.map { col in
                    f(Point(row: row, col: col))
                }
            }
        )
    }
}

extension Grid where Cell == Int {
    func neighbours(of node: Node) -> [Node] {
        var result: [Node] = []
        for direction in (node.latestDirection?.withoutReverses ?? Direction.allCases) {
            guard let cost = self[node.point[direction]] else { continue }
            if direction == node.latestDirection {
                if node.countAtLatestDirection == 3 { continue }
                else {
                    result.append(
                        Node(point: node.point[direction],
                             countAtLatestDirection: node.countAtLatestDirection + 1, 
                             cost: node.cost + cost))
                }
            } else {
                result.append(
                    Node(point: node.point[direction], countAtLatestDirection: 1, cost: node.cost + cost))
            }
        }
        return result
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 17",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 17 part 1")
            var puzzle = Grid<Int>(rows: readLines().map { $0.map { Int("\($0)")! }})

            var tentative = puzzle.mapPoints { _ in Int.max }
            var visited = puzzle.mapPoints { _ in nil as Int? }
            var current = Node(point: .init(row: 0, col: 0), 
                               latestDirection: nil,
                               countAtLatestDirection: 0, 
                               cost: 0)
            while true {
                let unvisited = puzzle.neighbours(of: current)
                    .filter { visited[$0.point] == nil }

            }
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 17 part 2")
        }
    }
}
