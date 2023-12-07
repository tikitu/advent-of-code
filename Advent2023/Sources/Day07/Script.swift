import Foundation
import ArgumentParser
import Algorithms
import Parsing
import Utils

struct Hand {
    var cards: [Character]
    var bid: Int
    var type: Int

    init(cards: Substring, bid: Substring) {
        self.cards = Array(cards)
        self.bid = Int(bid)!
        let groups = self.cards.grouped(by: { $0 })
        switch groups.count {
        case 1:
            type = 1 // five of a kind
        case 2: // either 2+3 or 4+1
            switch groups.first!.value.count {
            case 1, 4:
                type = 2 // 4+1
            case 2,3:
                type = 3 // 2+3
            default:
                preconditionFailure("failed to group \(cards) (case 2 \(groups))")
            }
        case 3: // either 2+2+1 or 3+1+1
            switch groups.values.map({ $0.count }).max()! {
            case 3:
                type = 4 // 3 of a kind
            case 2:
                type = 5 // two pair
            default:
                preconditionFailure("failed to group \(cards) (case 3 \(groups))")
            }
        case 4: // 2+1+1+1 = one pair
            type = 6
        case 5:
            type = 7 // high card
        default:
            preconditionFailure("failed to group \(cards) (\(groups))")
        }
    }

    struct ByStrength: SortComparator {
        var order = SortOrder.forward

        func compare(_ lhs: Hand, _ rhs: Hand) -> ComparisonResult {
            if lhs.type < rhs.type {
                switch order {
                case .forward:
                    return .orderedDescending
                case .reverse:
                    return .orderedAscending
                }
            }
            if lhs.type > rhs.type {
                switch order {
                case .forward:
                    return .orderedAscending
                case .reverse:
                    return .orderedDescending
                }
            }
            return .orderedSame
        }
    }

    struct Lexicographic: SortComparator {
        var order = SortOrder.forward

        func compare(_ lhs: Hand, _ rhs: Hand) -> ComparisonResult {
            for (lhs, rhs) in zip(lhs.cards.map { $0.rank }, rhs.cards.map { $0.rank }) {
                if lhs > rhs {
                    return switch order {
                    case .forward:
                            .orderedDescending
                    case .reverse:
                            .orderedAscending
                    }
                }
                if lhs < rhs {
                    return switch order {
                    case .forward:
                            .orderedAscending
                    case .reverse:
                            .orderedDescending
                    }
                }
            }
            return .orderedSame
        }
    }
}

extension Character {
    var rank: Int {
        switch self {
        case "A":
            14
        case "K":
            13
        case "Q":
            12
        case "J":
            11
        case "T":
            10
        case let n where n.isNumber:
            n.wholeNumberValue!
        default:
            preconditionFailure("unexpected card \(self)")
        }
    }
}

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2023 day 07",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "1")

        func run() throws {
            print("day 07 part 1")
            var hands = readLines().map {
                let parts = $0.split(separator: " ")
                return Hand(cards: parts[0], bid: parts[1])
            }
            hands.sort(using: Hand.Lexicographic(order: .reverse)) // sorts highest-first
            print(hands.prefix(5).map { String($0.cards) }.joined(separator: "\n"))
            print()
            hands.sort(using: Hand.ByStrength(order: .reverse)) // highest-first
            print(hands.prefix(5).map { String($0.cards) }.joined(separator: "\n"))
            print()
            let total = hands.reversed().enumerated().map {
                // print("\($0.offset + 1) \(String($0.element.cards)) \($0.element.bid)")
                return ($0.offset + 1) * $0.element.bid
            }.reduce(0, +)
            print(total)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2")

        func run() throws {
            print("day 07 part 2")
        }
    }
}
