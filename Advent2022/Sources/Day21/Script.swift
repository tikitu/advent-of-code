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
            let input = try readLines()
                .map { try parseLine($0) }
            var monkeys = Dictionary(uniqueKeysWithValues: input)
            monkeys["humn"] = nil
            let root = monkeys.removeValue(forKey: "root")!

            var constants: [String: Int] = Dictionary(
                uniqueKeysWithValues:
                    monkeys.compactMap {
                        if case .num(let value) = $1 { return ($0, value) }
                        return nil
                    }
            )
            while monkeys.reduce(with: &constants) {
                print("\(monkeys.count)")
            }
            print(root)
            print(monkeys.count)
            print(monkeys)

            let tree = monkeys.tree(from: root)
            print(tree.count)
            print(tree)

            guard case let .op(left, _, right) = root else { fatalError("???") }
            tree.prettyPrint(name: left, monkey: tree[left], constants: constants)
            print("\n=")
            tree.prettyPrint(name: right, monkey: tree[right], constants: constants)
            print("\n")

            print(
                tree.equation(name: left, constants: constants)
                    .equality(value: constants[right]!)
                )
        }
    }
}

enum Equation {
    case num(Int)
    case unknown
    indirect case op(Equation, Operation, Equation)

    func equality(value: Int) {
        switch self {
        case .unknown:
            print("x = \(value)")
        case .num(let mine):
            print("\(mine) = \(value)")
        case let .op(left, op, .num(right)): // left ? right = value => left = value ¿ right
            self.prettyPrint()
            print(" = \(value)")
            left.equality(value: op.rightInvert(value, right))
        case let .op(.num(left), op, right): // left ? right = value => right = left ¿ value
            self.prettyPrint()
            print(" = \(value)")
            right.equality(value: op.leftInvert(value, left))
        case .op(_, _, _):
            fatalError("don't know how to do this one yet \(self)")
        }
    }

    func prettyPrint() {
        switch self {
        case .unknown:
            print("x", terminator: "")
        case .num(let x):
            print(x, terminator: "")
        case let .op(left, op, right):
            print("(", terminator: "")
            left.prettyPrint()
            print(op.rawValue, terminator: "")
            right.prettyPrint()
            print(")", terminator: "")
        }
    }
}

extension Operation {
    func rightInvert(_ value: Int, _ right: Int) -> Int {
        switch self {
        case .add:
            return value - right
        case .sub:
            return value + right
        case .mul:
            return value / right
        case .div:
            return value * right
        }
    }

    func leftInvert(_ value: Int, _ left: Int) -> Int {
        // left ? self = value
        switch self {
        case .add:
            return value - left
        case .sub:
            return -(value - left)
        case .mul:
            return value / left
        case .div:
            // left / self = value
            return left / value
        }
    }
}

extension Dictionary where Key == String, Value == Monkey {
    func equation(name: String, constants: [String: Int]) -> Equation {
        if let val = constants[name] {
            return .num(val)
        }
        if case let .op(left, op, right) = self[name] {
            return .op(equation(name: left, constants: constants), op, equation(name: right, constants: constants))
        }
        return .unknown
    }

    func prettyPrint(name: String, monkey: Monkey?, constants: [String: Int]) {
        guard case let .op(left, op, right) = monkey else {
            if let value = constants[name] {
                print(value, terminator: "")
            } else {
                print(name, terminator: "")
            }
            return
        }
        if let left = constants[left] {
            print(left, terminator: "")
        } else {
            print("(", terminator: "")
            prettyPrint(name: left, monkey: self[left], constants: constants)
            print(")", terminator: "")
        }
        print(op.rawValue, terminator: "")
        if let right = constants[right] {
            print(right, terminator: "")
        } else {
            print("(", terminator: "")
            prettyPrint(name: right, monkey: self[right], constants: constants)
            print(")", terminator: "")
        }
    }

    mutating func reduce(with constants: inout [String: Int]) -> Bool {
        var change = false
        var result: [String: Monkey] = [:]
        for (name, monkey) in self {
            switch monkey {
            case .num(let value):
                constants[name] = value
                change = true
            case let .op(left, op, right):
                if let leftVal = constants[left],
                   let rightVal = constants[right] {
                    constants[name] = op.apply(leftVal, rightVal)
                    change = true
                } else {
                    result[name] = monkey
                }
            }
        }
        self = result
        return change
    }

    func tree(from monkey: Monkey) -> [String: Monkey] {
        guard case let .op(left, _, right) = monkey else { return [:] }
        var result = [String: Monkey]()
        var queue = [left, right]
        while !queue.isEmpty {
            let next = queue.popLast()!
            if let nextMonkey = self[next] {
                result[next] = nextMonkey
                if case let .op(left, _, right) = nextMonkey {
                    queue.append(left)
                    queue.append(right)
                }
            }
        }
        return result
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
