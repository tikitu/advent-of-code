import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 5",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    static func parse() throws -> ([String], [Instruction]) {
        let input = readLines()
        let crates = input.prefix(while: { !$0.isEmpty })
            .map {
                $0.chunks(ofCount: 4)
                    .map { String($0) }
                    .map { var s = $0; s.removeAll(where: { !$0.isLetter }); return s }
            }
            .dropLast()
            .reductions {
                zip($0, $1).map { $0 + $1 }
            }
            .last!
        print(crates)
        let rawInstructions = input.drop(while: { !$0.isEmpty }).dropFirst()

        let parser = Parse(Instruction.init(howMany:from:to:)) {
            "move "
            Int.parser()
            " from "
            Int.parser()
            " to "
            Int.parser()
        }
        let instructions = try rawInstructions.map { try parser.parse($0) }

        return (crates, instructions)
    }

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 05 part 01")
            var (crates, instructions) = try Script.parse()

            for instruction in instructions {
                applyOneByOne(instruction, to: &crates)
            }
            print(crates)
            print(crates.map { $0.isEmpty ? "" : String($0.first!) }.joined(separator: ""))
        }
    }

    static func applyOneByOne(_ instruction: Instruction, to crates: inout [String]) {
        (0..<instruction.howMany).forEach { _ in
            moveOne(from: instruction.from, to: instruction.to, &crates)
        }
    }

    static func moveOne(from: Int, to: Int, _ crates: inout [String]) {
        guard let crate = crates[from - 1].first else { return }
        crates[from - 1] = String(crates[from - 1].dropFirst())
        var dest = crates[to - 1]
        dest.insert(crate, at: dest.startIndex)
        crates[to - 1] = dest
    }

    struct Instruction {
        let howMany: Int
        let from: Int
        let to: Int
    }

    static func applyGrouped(_ instruction: Instruction, to crates: inout [String]) {
        let source = crates[instruction.from - 1]
        var dest = crates[instruction.to - 1]
        let moving = source.prefix(instruction.howMany)
        dest.insert(contentsOf: moving, at: dest.startIndex)
        crates[instruction.from - 1] = String(source.dropFirst(moving.count))
        crates[instruction.to - 1] = dest
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 05 part 02")
            var (crates, instructions) = try Script.parse()

            for instruction in instructions {
                applyGrouped(instruction, to: &crates)
            }
            print(crates)
            print(crates.map { $0.isEmpty ? "" : String($0.first!) }.joined(separator: ""))
        }
    }
}
