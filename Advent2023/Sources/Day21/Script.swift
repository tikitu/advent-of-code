import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 21",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 21 part 1")
            let puzzle = CharGrid(lines: readLines())
            var cells = Set(puzzle.points(where: { $0 != "." && $0 != "#" }))
            assert(cells.count == 1)
            for i in 1...64 {
                cells = Set(
                    cells.flatMap { puzzle.neighbours(of: $0) }
                        .filter { puzzle[$0] != "#" }
                )
                print("\(i): \(cells.count)")
            }
            print(cells.count)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 21 part 2")
            let lines = readLines()
            let garden = CharGrid(lines: lines)
            assert(garden.points(where: { $0 == "S" }).count == 1)
            let start = garden.points(where: { $0 == "S" }).first!

            var periphery: Set<Point> = [start]
            var evenCount = 1
            var oddCount = 0
            for i in 1...5000 {
                var next: Set<Point> = []
                for p in periphery {
                    /*
                     This doesn't work because of the hash-rocks: sometimes you would need to
                     move back *towards* the source to get around them, which this doesn't allow.
                     If we made a two-rank periphery to allow that, when there's an isolated hash-
                     rock cluster we could get the periphery chasing around it forever: that's no
                     good either. Humph.
                     */
                    if p.row <= start.row {
                        next.insert(p.north)
                    }
                    if p.row >= start.row {
                        next.insert(p.south)
                    }
                    if p.col <= start.col {
                        next.insert(p.west)
                    }
                    if p.col >= start.col {
                        next.insert(p.east)
                    }
                }
                periphery = next.filter { garden[wrapping: $0] != "#" }
                if i % 2 == 0 {
                    evenCount += periphery.count
                } else {
                    oddCount += periphery.count
                }
                if [1, 2, 3, 4, 5, 6, 10, 50, 100, 500, 1000, 5000].contains(i) {
                    var display = garden
                    for point in periphery {
                        display[wrapping: point] = "O"
                    }
                    print(display.pretty)
                    print("step \(i): \(periphery.count) accum \(evenCount) / \(oddCount)")
                }
            }
        }
    }
}
