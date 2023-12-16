import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 15",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 15 part 1")
            let line = readLines()[0]
            let ops = line.split(separator: ",")
            print(
                ops.map {
                    $0.adventHash
                }.reduce(0, +)
            )
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 15 part 2")
            let line = readLines()[0]
            let instructions = line.split(separator: ",")
                .map { try! Instruction.parser().parse($0) }
            var boxes: [[(Substring, Int)]] = Array(repeating: [], count: 256)
            for instruction in instructions {
                let i = instruction.label.adventHash
                switch instruction.op {
                case .min:
                    boxes[i].removeAll(where: { $0.0 == instruction.label })
                case .eq:
                    let newLens = (instruction.label, instruction.length!)
                    switch boxes[i].firstIndex(where: { $0.0 == instruction.label }) {
                    case nil:
                        boxes[i].append(newLens)
                    case let lensIdx?:
                        boxes[i][lensIdx] = newLens
                    }
                }
            }
            let lensPower = boxes.enumerated().map { (boxIdx, box) in
                box.enumerated().map { (lensIdx, lens) in
                    return (boxIdx + 1) * (lensIdx + 1) * lens.1
                }.reduce(0, +)
            }.reduce(0, +)
            print(lensPower)
        }
    }
}

extension StringProtocol {
    var adventHash: Int {
        self.reduce(0 as Int) { partialResult, next in
            ((partialResult + Int(next.asciiValue!)) * 17) % 256
        }
    }
}

struct Instruction {
    var label: Substring
    var op: Op
    var length: Int?

    enum Op: String, CaseIterable {
        case eq = "="
        case min = "-"
    }

    static func parser() -> some Parser<Substring, Instruction> {
        Parse(Instruction.init(label:op:length:)) {
            Parsing.Prefix(while: { $0 != "=" && $0 != "-" })
            Op.parser()
            Optionally {
                Int.parser()
            }
        }
    }
}
