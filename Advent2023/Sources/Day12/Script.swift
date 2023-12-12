import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Line {
    let input: String
    let dfa: DFA

    static func parser() -> some Parser<Substring, Line> {
        Parse(Line.init(input:dfa:)) {
            PrefixUpTo(" ").map(String.init)
            " "
            Many {
                Int.parser()
            } separator: {
                ","
            }.map(DFA.init(damaged:))
        }
    }
}

struct DFA {
    let damaged: [Int]

    struct MatchState {
        var match: String
        var damaged: [Int]
        var state: State

        enum State {
            case inOperational(nextDamaged: Int)
            case inDamaged(index: Int, count: Int)
        }
        
        func extensions(with next: Character) -> [Self] {
            var match = match
            switch next {
            case ".":
                match.append(contentsOf: "\(next)")
                switch state {
                case .inOperational(nextDamaged: _):
                    return [.init(match: match, damaged: damaged, state: state)]
                case .inDamaged(index: let idx, count: _):
                    return [.init(match: match, damaged: damaged, state: .inOperational(nextDamaged: idx+1))]
                }
            case "#":
                match.append(contentsOf: "\(next)")
                switch state {
                case .inDamaged(index: let idx, count: let count):
                    var damaged = damaged
                    damaged[damaged.count - 1] += 1
                    return [.init(match: match, damaged: damaged, state: .inDamaged(index: idx, count: count+1))]
                case .inOperational(nextDamaged: let idx):
                    return [.init(match: match, damaged: damaged + [1], state: .inDamaged(index: idx, count: 1))]
                }
            case "?":
                var matchDot = match
                matchDot.append(contentsOf: ".")
                var matchHash = match
                matchHash.append(contentsOf: "#")
                switch state {
                case .inDamaged(index: let idx, count: let count):
                    var damagedWithHash = damaged
                    damagedWithHash[damagedWithHash.count - 1] += 1
                    return [
                        .init(match: matchHash, damaged: damagedWithHash, state: .inDamaged(index: idx, count: count+1)),
                        .init(match: matchDot, damaged: damaged, state: .inOperational(nextDamaged: idx+1))
                    ]
                case .inOperational(nextDamaged: let idx):
                    return [
                        .init(match: matchHash, damaged: damaged + [1], state: .inDamaged(index: idx, count: 1)),
                        .init(match: matchDot, damaged: damaged, state: .inOperational(nextDamaged: idx))
                    ]
                }
            default:
                fatalError("got unexpected token \(next)")
            }
        }
    }

    func isConsistent(_ match: MatchState) -> Bool {
        switch match.state {
        case .inOperational(nextDamaged: let idx):
            return idx <= damaged.count // can be *after* the last one!
                && damaged.starts(with: match.damaged)
        case .inDamaged(index: let idx, count: let count):
            return idx < damaged.count && count <= damaged[idx]
            && damaged.starts(with: match.damaged.prefix(upTo: match.damaged.count - 1))
        }
    }

    func isComplete(_ match: MatchState) -> Bool {
        switch match.state {
        case .inOperational(nextDamaged: let idx):
            return idx == damaged.count
        case .inDamaged(index: let idx, count: let count):
            return idx == damaged.count-1 && count == damaged[idx]
        }
    }

    func matches(to input: String) -> [MatchState] {
        var matches: [MatchState] = [.init(match: "", damaged: [], state: .inOperational(nextDamaged: 0))]

        for next in input {
            matches = matches.flatMap { match in
                match.extensions(with: next)
                    .filter { isConsistent($0) }
            }
        }

        let complete = matches.filter { isComplete($0) }
        return complete
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 12",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 12 part 1")
            let lines = try readLines().map { try Line.parser().parse($0) }
            let counts = lines.map { $0.dfa.matches(to: $0.input).count }
            print(counts.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 12 part 2")
            let lines = try readLines().map { try Line2.parser().parse($0).fiveTimes }
            let counts = lines.map { $0.nfa.match(input: $0.input) }
            print(counts.reduce(0, +))
        }
    }
}

struct Line2 {
    let input: String
    let nfa: NFA

    static func parser() -> some Parser<Substring, Line2> {
        Parse(Line2.init(input:nfa:)) {
            PrefixUpTo(" ").map(String.init)
            " "
            Many {
                Int.parser()
            } separator: {
                ","
            }.map(NFA.init(damaged:))
        }
    }

    var fiveTimes: Self {
        .init(
            input: Array(repeating: input, count: 5).joined(separator: "?"),
            nfa: NFA(damaged: Array(Array(repeating: self.nfa.damaged, count: 5).joined())))
    }
}

struct NFA {
    let stateLabels: [String] // the states are *indices* into this array
    let transitions: [Character: [Set<Int>]]
    let emptyTransitions: [Set<Int>]

    let damaged: [Int]

    init(damaged: [Int]) {
        self.damaged = damaged

        var stateLabels = [".*"]
        var first = true
        for hashCount in damaged {
            if first {
                first = false
            } else {
                stateLabels.append(".")
                stateLabels.append(".*")
            }
            stateLabels.append(contentsOf: Array(repeating: "#", count: hashCount))
        }
        stateLabels.append(".*")
        self.stateLabels = stateLabels

        var emptyTransitions: [Set<Int>] = stateLabels.enumerated().map { (idx, label) in
            if label == ".*" {
                [idx, idx+1]
            } else {
                [idx]
            }
        }
        // don't leave via empty transition!
        emptyTransitions[emptyTransitions.count - 1] = [emptyTransitions.count - 1]

        var dotTransitions: [Set<Int>] = stateLabels.map { _ in Set<Int>() }
        for i in dotTransitions.indices {
            if stateLabels[i] == ".*" {
                dotTransitions[i].insert(i) // self-transition: consume a dot and stay
            }
            if stateLabels[i] == "." {
                dotTransitions[i].insert(i+1) // leave-transition: consume dot and move on
            }
        }

        var hashTransitions: [Set<Int>] = stateLabels.enumerated().map { (idx, label) in
            if label == "#" {
                [idx+1]
            } else {
                []
            }
        }

        var queryTransitions: [Set<Int>] = stateLabels.map { _ in [] }
        for i in queryTransitions.indices {
            if stateLabels[i] == ".*" {
                queryTransitions[i].insert(i)
            } else if stateLabels[i] == "." || stateLabels[i] == "#" {
                queryTransitions[i].insert(i+1)
            }
        }

        transitions = [
            ".": dotTransitions,
            "#": hashTransitions,
            "?": queryTransitions
        ]
        self.emptyTransitions = emptyTransitions
    }

    func match(input: String) -> Int {
//        print("λ \(emptyTransitions)")
//        print(". \(transitions["."]!)")
//        print("# \(transitions["#"]!)")
//        print("? \(transitions["?"]!)")
//        print("\(input) \(stateLabels.joined())")

        var counts = stateLabels.map { _ in 0 }
        counts[0] = 1 // start state: .*

//        print("  -> \(counts)")

        for next in input {
            assert(transitions.keys.contains(next), "unexpected char \(next)")
            apply(transitions: emptyTransitions, to: &counts)
//            print("λ -> \(counts)")
            apply(transitions: transitions[next]!, to: &counts)
//            print("\(next) -> \(counts)")
        }

        return counts.last!
    }

    func apply(transitions: [Set<Int>], to counts: inout [Int]) {
        var newCounts = counts.map { _ in 0 }
        for oldState in transitions.indices {
            for newState in transitions[oldState] {
                newCounts[newState] += counts[oldState]
            }
        }
        counts = newCounts
    }
}
