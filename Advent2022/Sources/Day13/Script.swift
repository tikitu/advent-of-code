import ArgumentParser
import Parsing
import Utils
import Algorithms

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 13",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 13 part 01")
            let input = readLines()
                .filter { !$0.isEmpty }
                .map(parseLine(from:))
            let pairs = input.chunks(ofCount: 2).map { Array($0) }
            let result = pairs
                .map { pair in
                    // REALLY?! Swift (efficient) collection indexing is *wild*
                    pair.first! <= pair[pair.index(after: pair.startIndex)]
                }
                .enumerated()
                .filter { $0.element }
                .map { $0.offset + 1 }
                .reduce(0, +)
            print("")
            print(result)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 13 part 02")
            var input = readLines()
                .filter { !$0.isEmpty }
                .map(parseLine(from:))
            input.append(.list([.list([.num(2)])]))
            input.append(.list([.list([.num(6)])]))

            input.sort()

            let first = input.firstIndex(of: .list([.list([.num(2)])]))! + 1
            let second = input.firstIndex(of: .list([.list([.num(6)])]))! + 1
            print(first * second)
        }
    }
}

enum Packet: Equatable, Comparable {
    static func < (lhs: Packet, rhs: Packet) -> Bool {
        return lhs <= rhs && !(rhs <= lhs)
    }

    case num(Int)
    case list([Packet])

    static func <=(lhs: Packet, rhs: Packet) -> Bool {
        switch (lhs, rhs) {
        case (.num(let lhs), .num(let rhs)):
            return lhs <= rhs
        case (.list(let lhs), .list(let rhs)):
            for pair in zip(lhs, rhs) {
                let le = pair.0 <= pair.1
                let ge = pair.1 <= pair.0
                switch (le, ge) {
                case (true, false): return true
                case (false, true): return false
                case (true, true): continue
                case (false, false): fatalError("one of the two must be!")
                }
            }
            if lhs.count < rhs.count { return true }
            if lhs.count > rhs.count { return false }
            return true
        case (.num(let lhs), let rhs):
            return .list([.num(lhs)]) <= rhs
        case (let lhs, .num(let rhs)):
            return lhs <= .list([.num(rhs)])
        }
    }
}

extension Packet: CustomStringConvertible {
    var description: String {
        switch self {
        case .num(let v): return "\(v)"
        case .list(let v): return "[" + v.map { "\($0)" }.joined(separator: ",") + "]"
        }
    }
}

func parseLine(from input: String) -> Packet {
    var input = input[...]
    let result = parseManyPackets(from: &input)
    assert(input.isEmpty)
    return .list(result)
}

func parsePacket(from input: inout Substring) -> Packet {
    switch input.first {
    case "[":
        return .list(parseManyPackets(from: &input))
    case ",", "]":
        fatalError()
    default: // number
        let prefix = input.prefix(while: { $0.isWholeNumber })
        input = input.dropFirst(prefix.count)
        return .num(Int(prefix)!)
    }
}

func parseManyPackets(from input: inout Substring) -> [Packet] {
    assert(input.first == "[")
    input = input.dropFirst()
    var result: [Packet] = []
    while input.first != "]" {
        result.append(parsePacket(from: &input))
        if input.first == "," {
            input = input.dropFirst()
        }
    }
    assert(input.first == "]")
    input = input.dropFirst()
    return result
}
