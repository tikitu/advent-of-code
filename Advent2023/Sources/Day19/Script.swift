import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Part {
    var x: Int
    var m: Int
    var a: Int
    var s: Int

    var value: Int {
        x+m+a+s
    }

    static func parser() -> some Parser<Substring, Part> {
        Parse(Part.init(x:m:a:s:)) {
            "{x="
            Int.parser()
            ",m="
            Int.parser()
            ",a="
            Int.parser()
            ",s="
            Int.parser()
            "}"
        }
    }
}

struct DFA {
    var states: [Substring: State]

    static func parser() -> some Parser<Substring, DFA> {
        Parse(DFA.init(states:)) {
            Many {
                State.parser()
            } separator: {
                Whitespace(1, .vertical)
            } terminator: {
                Whitespace(2, .vertical)
            }.map { states in
                Dictionary(
                    uniqueKeysWithValues: states.map { (key: $0.name, value: $0) })
            }
        }
    }

    enum Var: String, CaseIterable { case x,m,a,s }
    enum Comparison: String, CaseIterable { case lt = "<", gt = ">" }
    struct Rule {
        var variable: Var
        var comparison: Comparison
        var value: Int
        var newState: Substring

        static func parser() -> some Parser<Substring, Rule> {
            Parse(Rule.init(variable:comparison:value:newState:)) {
                Var.parser()
                Comparison.parser()
                Int.parser()
                ":"
                PrefixUpTo(",")
            }
        }

        func accepts(_ part: Part) -> Bool {
            let partValue = switch variable {
            case .x:
                part.x
            case .m:
                part.m
            case .a:
                part.a
            case .s:
                part.s
            }
            switch comparison {
            case .lt:
                return partValue < value
            case .gt:
                return partValue > value
            }
        }
    }

    struct State {
        var name: Substring
        var rules: [Rule]
        var fallback: Substring

        static func parser() -> some Parser<Substring, State> {
            Parse(State.init(name:rules:fallback:)) {
                Not { "{" }
                Not { Whitespace(1, .all) }
                PrefixUpTo("{")
                "{"
                Many {
                    Rule.parser()
                } separator: {
                    ","
                } terminator: {
                    ","
                }
                PrefixUpTo("}")
                "}"
            }
        }

        func transition(_ part: Part) -> Substring {
            for rule in rules {
                if rule.accepts(part) {
                    return rule.newState
                }
            }
            return fallback
        }
    }
}

struct Puzzle {
    var dfa: DFA
    var input: [Part]

    static func parser() -> some Parser<Substring, Puzzle> {
        Parse(Puzzle.init(dfa:input:)) {
            DFA.parser()
            Many {
                Part.parser()
            } separator: {
                Whitespace(1, .vertical)
            } terminator: {
                End()
            }
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 19",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 19 part 1")
            let puzzle = try Puzzle.parser().parse(readLines().joined(separator: "\n"))

            let accepted = puzzle.input.compactMap { part -> Part? in
                var state: Substring = "in"
                while state != "A" && state != "R" {
                    guard let dfaState = puzzle.dfa.states[state] else {
                        preconditionFailure("expected state [\(state)] to exist")
                    }
                    state = dfaState.transition(part)
                    if state == "A" {
                        return part
                    } else if state == "R" {
                        return nil
                    }
                }
                assertionFailure("we should not be able to exit this loop")
                return nil
            }
            let values = accepted.map { $0.value }
            print(values.reduce(0, +))
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 19 part 2")
            let dfa = try Puzzle.parser().parse(readLines().joined(separator: "\n")).dfa

            var states: Set<SearchState> = []
            var pending: [SearchState] = [.init(state: "in", parts: .init())]
            while true {
                states.formUnion(pending)
                let next = pending.flatMap { state in
                    dfa.transitions(from: state)
                        .filter { !$0.parts.isEmpty }
                        .filter { !states.contains($0) }
                }
                guard !pending.isEmpty else { break }
                print("total: \(states.count), next: \(next.count)")
                pending = next
            }
            let accepted = states.filter { $0.state == "A" }
            print(accepted.map { $0.parts.count }.reduce(0, +))
        }
    }
}

extension DFA {
    func transitions(from searchState: SearchState) -> [SearchState] {
        guard let state = states[searchState.state] else { return [] }
        return state.transitions(from: searchState.parts)
    }
}

extension DFA.State {
    func transitions(from parts: PartRange) -> [SearchState] {
        var result: [SearchState] = []
        var parts = parts
        for rule in rules {
            result.append(rule.accepting(parts))
            parts = rule.rejecting(parts)
        }
        result.append(SearchState(state: fallback, parts: parts))
        return result
    }
}

extension DFA.Rule {
    func accepting(_ parts: PartRange) -> SearchState {
        var parts = parts
        let variable: WritableKeyPath<PartRange, Range<Int>> = switch self.variable {
        case .x:
            \.x
        case .m:
            \.m
        case .a:
            \.a
        case .s:
            \.s
        }
        switch comparison {
        case .lt:
            parts[keyPath: variable] = parts[keyPath: variable].clamped(to: 1..<value)
        case .gt:
            parts[keyPath: variable] = parts[keyPath: variable].clamped(to: value+1..<4001)
        }
        return SearchState(state: newState, parts: parts)
    }
    func rejecting(_ parts: PartRange) -> PartRange {
        var parts = parts
        let variable: WritableKeyPath<PartRange, Range<Int>> = switch self.variable {
        case .x:
            \.x
        case .m:
            \.m
        case .a:
            \.a
        case .s:
            \.s
        }
        switch comparison {
        case .lt:
            parts[keyPath: variable] = parts[keyPath: variable].clamped(to: value..<4001)
        case .gt:
            parts[keyPath: variable] = parts[keyPath: variable].clamped(to: 1..<value+1)
        }
        return parts
    }
}

struct PartRange: Hashable {
    var x: Range<Int>
    var m: Range<Int>
    var a: Range<Int>
    var s: Range<Int>

    var count: Int {
        x.count * m.count * a.count * s.count
    }
    var isEmpty: Bool { // could also be self.count == 0
        [x.isEmpty, m.isEmpty, a.isEmpty, s.isEmpty].first { $0 } ?? false
    }
}
extension PartRange {
    init() {
        self.init(x: 1..<4001, m: 1..<4001, a: 1..<4001, s: 1..<4001)
    }
}
struct SearchState: Hashable {
    var state: Substring
    var parts: PartRange
}
