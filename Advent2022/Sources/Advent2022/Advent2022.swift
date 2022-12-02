import ArgumentParser
import Parsing

// swift run Advent2022 01

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 programs",
        version: "0.0.1",
        subcommands: [Day01.self, Day02.self, Day02Parsing.self]
    )
}

extension Script {
    struct Day02Parsing: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02b")

        func run() {
            let input = readLines()

            let parser = Parse(Game.init) {
                Theirs.parser()
                " "
                Mine.parser()
            }

            let score = input
                .map { try! parser.parse($0) }
                .map { $0.score }
                .reduce(0, +)
            print("score: \(score)")

            let parser2 = Parse {
                Theirs.parser()
                " "
                Outcome.parser()
            }.map { (theirs, outcome) in Game(theirs: theirs, mine: outcome.choice(for: theirs)) }

            let score_2 = input
                .map { try! parser2.parse($0) }
                .map { $0.score }
                .reduce(0, +)
            print("score: \(score_2)")
        }

        struct Game {
            let theirs: Theirs
            let mine: Mine

            var score: Int {
                switch (mine, theirs) {
                case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
                    return 3 + mine.score
                case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
                    return mine.score
                case (.paper, .rock), (.rock, .scissors), (.scissors, .paper):
                    return 6 + mine.score
                }
            }
        }
        enum Theirs: String, CaseIterable {
            case rock = "A"
            case paper = "B"
            case scissors = "C"
        }
        enum Mine: String, CaseIterable {
            case rock = "X"
            case paper = "Y"
            case scissors = "Z"

            var score: Int {
                switch self {
                case .rock: return 1
                case .paper: return 2
                case .scissors: return 3
                }
            }
        }
        enum Outcome: String, CaseIterable {
            case lose = "X"
            case draw = "Y"
            case win = "Z"

            func choice(for theirs: Theirs) -> Mine {
                switch (self, theirs) {
                case (.win, .rock), (.draw, .paper), (.lose, .scissors): return .paper
                case (.win, .paper), (.draw, .scissors), (.lose, .rock): return .scissors
                case (.win, .scissors), (.draw, .rock), (.lose, .paper): return .rock
                }
            }
        }
    }
}

extension Script {
    struct Day02: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        @Flag(help: "do part 2")
        var next = false

        func run() {
            let input = readLines()

            guard next else {
                let scores = input.map { line in
                    let them = Play(line.first!)
                    let us = Play(line.last!)
                    return score(us: us, them: them)
                }
                print("rounds: \(scores.count) score \(scores.reduce(0, +))")
                return
            }

            print("doing next part")
            // part 2
            let scores = input.map { line in
                let them = Play(line.first!)
                let outcome = Outcome(rawValue: "\(line.last!)")!
                let us = play(to: outcome, if: them)
                return score(us: us, them: them)
            }
            print("rounds: \(scores.count) score \(scores.reduce(0, +))")
        }
    }

    static func score(us: Play, them: Play) -> Int {
        var score = 0
        switch us {
        case .rock:
            score += 1
        case .paper:
            score += 2
        case .scissors:
            score += 3
        }
        switch (us, them) {
        case (let us, let them) where us == them:
            score += 3
        case (.rock, .scissors), (.scissors, .paper), (.paper, .rock):
            score += 6
        default:
            score += 0
        }
        return score
    }

    static func play(to outcome: Outcome, if them: Play) -> Play {
        switch (outcome, them) {
        case (.draw, let them):
            return them
        case (.win, .rock), (.lose, .scissors):
            return .paper
        case (.win, .paper), (.lose, .rock):
            return .scissors
        case (.win, .scissors), (.lose, .paper):
            return .rock
        }
    }

    enum Play: Equatable {
        case rock, paper, scissors

        init(_ c: Character) {
            switch c {
            case "A", "X":
                self = .rock
            case "B", "Y":
                self = .paper
            case "C", "Z":
                self = .scissors
            default:
                fatalError("got [\(c)]")
            }
        }
    }

    enum Outcome: String, Equatable {
        case win = "Z", lose = "X", draw = "Y"
    }
}

extension Script {
    struct Day01: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() {
            let input = readLines()
            var counts = Set<Int>()
            var calorieCount = 0
            for line in input {
                if line.isEmpty {
                    counts.insert(calorieCount)
                    calorieCount = 0
                } else {
                    calorieCount += Int(line)!
                }
            }
            print(Array(counts).sorted().reversed()[..<3])
            print(Array(counts).sorted().reversed()[..<3].reduce(0, +))
        }
    }
}

func readLines() -> [String] {
    var lines: [String] = []
    while let line = readLine() {
        lines.append(line)
    }
    return lines
}
