import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 21",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 21 part 01")
            let input = try readLines()
                .map { try parseLine($0) }
            let monkeys = Dictionary(uniqueKeysWithValues: input)
            print(monkeys.value(of: "root"))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 21 part 02")
            // let input = readLines()
        }
    }
}

extension Dictionary where Key == String, Value == Monkey {
    func value(of name: String) -> Int {
        switch self[name] {
        case .num(let value):
            return value
        case .op(let left, let op, let right):
            let left = value(of: left)
            let right = value(of: right)
            return op.apply(left, right)
        default:
            fatalError("missing monkey \(name)")
        }
    }
}

enum Operation: String, CaseIterable {
    case div = "/"
    case mul = "*"
    case add = "+"
    case sub = "-"

    func apply(_ left: Int, _ right: Int) -> Int {
        switch self {
        case .add:
            return left + right
        case .div:
            return left / right
        case .mul:
            return left * right
        case .sub:
            return left - right
        }
    }
}

enum Monkey {
    case num(Int)
    case op(String, Operation, String)
}

func parseLine(_ line: String) throws -> (String, Monkey) {
    let parser = Parse {
        PrefixUpTo(":").map(String.init)
        ": "
        OneOf {
            Digits().map { Monkey.num($0) }
            Parse {
                PrefixUpTo(" ")
                " "
                Operation.parser()
                " "
                Rest()
            }.map {
                Monkey.op(String($0.0), $0.1, String($0.2))
            }
        }
    }
    return try parser.parse(line)
}
