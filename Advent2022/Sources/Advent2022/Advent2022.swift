import ArgumentParser

// swift run Advent2022 01

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 programs",
        version: "0.0.1",
        subcommands: [Day01.self]
    )
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
