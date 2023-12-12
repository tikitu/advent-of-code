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
        }
    }
}
