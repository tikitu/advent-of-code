import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 23",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 23 part 01")
            var state = State(lines: readLines())

            for round in 0..<10 {
                print("round \(round + 1)")
                state.prettyPrint()
                print("")
                state.perform(round: round)
            }
            print("round 10")
            state.prettyPrint()
            let xRange = state.elves.map { $0.x }.minAndMax()!
            let yRange = state.elves.map { $0.y }.minAndMax()!
            print(((xRange.max + 1 - xRange.min) * (yRange.max + 1 - yRange.min)) - state.elves.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 23 part 02")
            // let input = readLines()
        }
    }
}

struct State {
    var elves: Set<Point>

    mutating func perform(round: Int) {
        var propositions: [Point: Int] = [:]
        var moves: [Point: Point] = [:]
        func propose(_ elf: Point, to move: Point) {
            propositions[move, default: 0] += 1
            moves[elf] = move
        }
        let directions: [(Point) -> Bool] = [
            { [self] elf in
                guard emptyNorth(elf) else { return false }
                propose(elf, to: Point(x: elf.x, y: elf.y - 1))
                return true
            },
            { [self] elf in
                guard emptySouth(elf) else { return false }
                propose(elf, to: Point(x: elf.x, y: elf.y + 1))
                return true
            },
            { [self] elf in
                guard emptyWest(elf) else { return false }
                propose(elf, to: Point(x: elf.x - 1, y: elf.y))
                return true
            },
            { [self] elf in
                guard emptyEast(elf) else { return false }
                propose(elf, to: Point(x: elf.x + 1, y: elf.y))
                return true
            }
        ]
    ELF: for elf in elves {
            guard wantsToMove(elf) else { continue }
            for i in 0..<4 {
                if directions[(round + i) % 4](elf) {
                    continue ELF
                }
            }
        }
        for (elf, move) in moves {
            if propositions[move] == 1 {
                elves.remove(elf)
                elves.insert(move)
            }
        }
    }

    func emptyNorth(_ elf: Point) -> Bool {
        elves.intersection([-1, 0, 1].map { Point(x: elf.x + $0, y: elf.y - 1) }).isEmpty
    }

    func emptySouth(_ elf: Point) -> Bool {
        elves.intersection([-1, 0, 1].map { Point(x: elf.x + $0, y: elf.y + 1) }).isEmpty
    }

    func emptyWest(_ elf: Point) -> Bool {
        elves.intersection([-1, 0, 1].map { Point(x: elf.x - 1, y: elf.y + $0) }).isEmpty
    }

    func emptyEast(_ elf: Point) -> Bool {
        elves.intersection([-1, 0, 1].map { Point(x: elf.x + 1, y: elf.y + $0) }).isEmpty
    }

    func wantsToMove(_ elf: Point) -> Bool {
        for dx in [-1, 0, 1] {
            for dy in [-1, 0, 1] {
                if dx == 0 && dy == 0 { continue }
                if elves.contains(Point(x: elf.x + dx, y: elf.y + dy)) { return true }
            }
        }
        return false
    }
}

extension State {
    init(lines: [String]) {
        self.init(elves: [])
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                if char == "#" {
                    elves.insert(Point(x: x, y: y))
                }
            }
        }
    }
}

struct Point: Hashable {
  var x: Int
  var y: Int
}

extension Point: CustomStringConvertible {
    var description: String { "\(x),\(y)" }
}

extension State {
    func prettyPrint(space: String = "") {
        guard let xRange = elves.map(\.x).minAndMax() else { return }
        guard let yRange = elves.map(\.y).minAndMax() else { return }
        for y in yRange.min...yRange.max {
            for x in xRange.min...xRange.max {
                print(elves.contains(Point(x: x, y: y)) ? "#" : ".", terminator: space)
            }
            print("")
        }
        print("")
    }
}
