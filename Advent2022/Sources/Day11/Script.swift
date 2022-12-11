import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 11",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 11 part 01")
            let input = readLines().joined(separator: "\n")
            var monkeys = try parseInput(input)

            for _ in 0..<20 {
                round(&monkeys)
            }
            print(monkeys.map(\.inspected).max(count: 2).reduce(1, *))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 11 part 02")
            let input = readLines().joined(separator: "\n")
            var monkeys = try parseInput(input)

            for i in 0..<10000 {
                round(&monkeys, reduceWorry: false)
                if i.isMultiple(of: 100) {
                    print(monkeys.flatMap(\.items))
                }
            }
            print(monkeys.map(\.inspected).max(count: 2).reduce(1, *))
        }
    }
}

func round(_ monkeys: inout [Monkey], reduceWorry: Bool = true) {
    let divisibility = monkeys.map(\.divisibleTest).reduce(1, *)
    for i in monkeys.indices {
        var monkey = monkeys[i]
        monkey.inspected += monkey.items.count
        while !monkey.items.isEmpty {
            var worry = monkey.items.removeFirst()
            worry = monkey.operation.applyTo(worry)
            if reduceWorry {
                worry = worry / 3
            } else {
                worry = worry % divisibility
            }
            if worry.isMultiple(of: monkey.divisibleTest) {
                monkeys[monkey.trueMonkey].items.append(worry)
            } else {
                monkeys[monkey.falseMonkey].items.append(worry)
            }
        }
        monkeys[i] = monkey
    }
}

func parseInput(_ allInput: String) throws -> [Monkey] {
    let monkey = Parse {
        Skip {
            "Monkey "
            PrefixThrough("\n")
        }
        Parse {
            "  Starting items: "
            Many { Int.parser() } separator: { ", " } terminator: { "\n" }
        }
        Parse {
            "  Operation: new = "
            OneOf {
                "old * old".map { Operation.square }
                Parse {
                    "old * "
                    Int.parser()
                }.map { Operation.times($0) }
                Parse {
                    "old + "
                    Int.parser()
                }.map { Operation.plus($0) }
            }
        }
        Parse {
            "\n  Test: divisible by "
            Int.parser()
        }
        Parse {
            "\n    If true: throw to monkey "
            Int.parser()
        }
        Parse {
            "\n    If false: throw to monkey "
            Int.parser()
        }
    }.map {
        Monkey(items: $0, operation: $1, divisibleTest: $2, trueMonkey: $3, falseMonkey: $4)
    }

    let parser = Many {
        monkey
    } separator: {
        "\n\n"
    } terminator: {
        End()
    }

    return try parser.parse(allInput)
}

struct Monkey {
    var items: [Int]
    let operation: Operation
    let divisibleTest: Int
    let trueMonkey: Int
    let falseMonkey: Int
    var inspected = 0
}

enum Operation {
    case times(Int)
    case plus(Int)
    case square

    func applyTo(_ value: Int) -> Int {
        switch self {
        case .plus(let c): return value + c
        case .times(let c): return value * c
        case .square: return value * value
        }
    }
}
