import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 10",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    enum Instruction {
        case noop
        case addX(Int)
    }

    static func parse(input: [String]) throws -> [Instruction] {
        let parser = Parse {
            OneOf {
                "noop".map { Instruction.noop }
                Parse {
                    "addx"
                    " "
                    Int.parser()
                }.map(Instruction.addX)
            }
        }
        return try input.map { try parser.parse($0) }
    }

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 10 part 01")
            let input = try Script.parse(input: readLines())

            var x = 1
            var cycle = 1
            var strength = 0
            for instruction in input {
                if [20, 60, 100, 140, 180, 220].contains(cycle) {
                    strength += cycle * x
                    print("\(cycle) strength: \(cycle * x)")
                }
                cycle += 1
                if case .addX(let value) = instruction {
                    if [20, 60, 100, 140, 180, 220].contains(cycle) {
                        strength += cycle * x
                        print("  strength: \(cycle * x)")
                    }
                    cycle += 1
                    x += value
                }
            }
            if [20, 60, 100, 140, 180, 220].contains(cycle) {
                strength += cycle * x
                print("  strength: \(cycle * x)")
            }
            print(strength)
        }

        func runInParallel(input: [Instruction]) { // this is not what the rules say!
            var x = 1
            var strength = 0
            var pending: [Int: Instruction] = [:]
            for (i, instruction) in input.enumerated() {
                let cycle = i + 1
                // before
                switch instruction {
                case .noop:
                    break // do NOT clobber an add
                case .addX(_):
                    pending[cycle + 1] = instruction
                }

                // during
                print("\(cycle): \(x)")
                if [20, 60, 100, 140, 180].contains(cycle) {
                    strength += cycle * x
                    print("  strength: \(cycle * x)")
                }

                // after
                switch pending[cycle] {
                case nil, .noop: break
                case .addX(let value): x += value
                }
            }
            print(strength)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 10 part 02")
            let input = try Script.parse(input: readLines())
            var x = 1
            var cycle = 1

            var col = 0
            func crt() {
                print(abs(x-col) <= 1 ? "#" : ".", terminator: "")
                col += 1
                if col >= 40 {
                    col = 0
                    print("")
                }
            }

            for instruction in input {
                cycle += 1
                crt()
                if case .addX(let value) = instruction {
                    cycle += 1
                    crt()
                    x += value
                }
            }
        }
    }
}
