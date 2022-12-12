import ArgumentParser
import Parsing
import Utils
import DequeModule

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 12",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 12 part 01")
            let input = readLines()
                .map { $0.map { $0.asciiValue! } }
            var grid = Grid(from: input)

            let start = grid.point(
                index: grid.values.firstIndex(of: "S".first!.asciiValue!)!)
            let end = grid.point(
                index: grid.values.firstIndex(of: "E".first!.asciiValue!)!)
            grid[end] = "z".first!.asciiValue!

            var search = DijstraIsh(
                visited: [start],
                pending: [start],
                path: Grid(rows: grid.rows, cols: grid.cols,
                           values: Array(repeating: Int.max, count: grid.values.count)))
            search.path[start] = 0

            var counter = 1
            while true {
                counter += 1
                if counter.isMultiple(of: 100) {
                    print(search.pending.count)
                }
//                search.path.prettyPrint()
//                print("")

                let current = search.pending.popFirst()!
                let path = search.path[current]
                let neighbours = grid.neighbours(of: current, start: start, end: end)
                    .subtracting(search.visited)
                if neighbours.contains(end) {
                    print("\(path + 1)")
                    break
                }
                for next in neighbours {
                    search.path[next] = path + 1
                }
                search.pending.append(contentsOf: neighbours)
                search.visited.formUnion(neighbours)
            }
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 12 part 02")


        }
    }
}

struct DijstraIsh {
    var visited: Set<Point> = []
    var pending: Deque<Point> = []
    var path: Grid<Int>
}

struct Grid<Value> {
    let rows: Int
    let cols: Int
    var values: [Value]

    /// Does NOT validate input!
    func point(index i: Int) -> Point {
        Point(row: i / cols, col: i % cols)
    }

    /// NOT validated for range
    subscript(_ point: Point) -> Value {
        get {
            values[point.row * cols + point.col]
        }
        set {
            values[point.row * cols + point.col] = newValue
        }
    }
}

extension Grid {
    /// Preconditions: the rows all have the same length; grid would be nonempty
    init(from rows: [[Value]]) {
        self.rows = rows.count
        cols = rows[0].count
        values = Array(rows.joined())
    }
}

struct Point: Hashable {
    var row: Int
    var col: Int
}

extension Grid where Value == UInt8 {
    func neighbours(of point: Point, start: Point, end: Point) -> Set<Point> {
        let value = point == start ? "a".first!.asciiValue! : self[point]

        var result: Set<Point> = []
        for next in [
            point.row > 0 ? Point(row: point.row - 1, col: point.col) : nil,
            point.col > 0 ? Point(row: point.row, col: point.col - 1) : nil,
            point.row < rows - 1 ? Point(row: point.row + 1, col: point.col) : nil,
            point.col < cols - 1 ? Point(row: point.row, col: point.col + 1) : nil
        ].compactMap({ $0 }) {
            if self[next] <= value + 1 {
                result.insert(next)
            }
        }
        return result
    }
}

extension Grid where Value == Int {
    func prettyPrint() {
        let pretty = values.map { $0 == .max ? "-" : "\($0)" }
        let maxWidth = pretty.map(\.count).max()!
        for (i, v) in pretty.enumerated() {
            if i.isMultiple(of: cols) {
                print("")
            }
            print(v.padding(toLength: maxWidth, withPad: " ", startingAt: 0), terminator: " ")
        }
    }

}
