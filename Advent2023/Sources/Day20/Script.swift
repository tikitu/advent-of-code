import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils
import Collections

struct Node {
    var name: Substring
    var destinations: [Substring]
    var type: NodeType

    enum NodeType {
        case flipFlop(Bool)
        case conjunct([Substring: Bool])
        case broadcaster
    }

    mutating func record(input source: Node) {
        guard case var .conjunct(state) = type else {
            return
        }
        state[source.name] = false
        type = .conjunct(state)
    }

    mutating func handle(_ pulse: Pulse) -> [Pulse] {
        switch type {
        case .broadcaster:
            return destinations.map { Pulse(from: name, to: $0, isHigh: pulse.isHigh) }
        case .flipFlop(let wasOn):
            if pulse.isHigh { return [] }
            self.type = .flipFlop(!wasOn)
            return destinations.map { Pulse(from: name, to: $0, isHigh: !wasOn) }
        case .conjunct(var memory):
            memory[pulse.from] = pulse.isHigh
            self.type = .conjunct(memory)
            let allHigh = memory.values.allSatisfy { $0 }
            return destinations.map { Pulse(from: name, to: $0, isHigh: !allHigh) }
        }
    }

    static func parser() -> some Parser<Substring, Node> {
        Parse {
            OneOf {
                "%".map { _ in NodeType.flipFlop(false) }
                "&".map { _ in NodeType.conjunct([:]) }
                "".map { _ in NodeType.broadcaster }
            }
            PrefixUpTo(" ")
            " -> "
            Many {
                CharacterSet.alphanumerics
            } separator: {
                ", "
            }
        }.map { Node(name: $1, destinations: $2, type: $0) }
    }
}

struct Network {
    var nodes: [Substring: Node]

    init(nodes: [Node]) {
        var network = Dictionary(uniqueKeysWithValues: nodes.map { ($0.name, $0) })
        for node in nodes {
            for dest in node.destinations {
                network[dest]?.record(input: node)
            }
        }
        self.nodes = network
    }

    mutating func pushButton() -> [Pulse] {
        var pulses = Deque<Pulse>()
        var trace: [Pulse] = []
        pulses.append(.init(from: "button", to: "broadcaster", isHigh: false))
        while let pulse = pulses.popFirst() {
            trace.append(pulse)
            if nodes.keys.contains(pulse.to) {
                pulses.append(contentsOf: nodes[pulse.to]!.handle(pulse))
            } 
//            else { // This ain't true! My input sends pulses to nonexistent node "rx"
//                assert(pulse.to == "output", "expected output but got \(pulse.pretty)")
//            }
        }
        return trace
    }
}

struct Pulse {
    var from: Substring
    var to: Substring
    var isHigh: Bool

    var pretty: String {
        let highString = if isHigh { "high" } else { "low" }
        return "\(from) -\(highString)-> \(to)"
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 20",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 20 part 1")
            var network = try Network(nodes: readLines().map { try Node.parser().parse($0) })
            var counts = (high: 0, low: 0)
            for i in 1...1000 {
                let pulses = network.pushButton()
                counts.high += pulses.filter { $0.isHigh }.count
                counts.low += pulses.filter { !$0.isHigh }.count
                print("\(i): \(counts) multiplied: \(counts.high * counts.low)")
            }
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 20 part 2")
            var network = try Network(nodes: readLines().map { try Node.parser().parse($0) })
            for i in 1...10_000_000 {
                let pulses = network.pushButton()
                if pulses.contains(where: { $0.to == "rx" && !$0.isHigh }) {
                    print("got it! \(i)")
                    break
                }
                if i % 1000 == 0 {
                    print(i)
                }
            }

        }
    }
}
