import ArgumentParser

struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2021 programs",
        version: "0.0.1",
        subcommands: [Day1_1.self, Day1_2.self, Day2_1.self]
    )
}

extension Script {
    struct Day1_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "1_1"
        )

        func run() {
            var previous: Int? = nil
            var increases = 0
            while let line = readLine() {
                guard let next = Int(line) else { continue } // puzzle should not have non-ints
                if let previous = previous,
                   next > previous {
                    increases += 1
                }
                previous = next
            }
            print(increases)
        }
    }

    struct Day1_2: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "1_2"
        )

        func countIncreases(_ depths: [Int]) -> Int {
            zip(depths, depths.dropFirst()).map { $1 > $0 }.filter { $0 }.count
        }

        func run() {
            var depths: [Int] = []
            while let line = readLine() {
                depths.append(Int(line)!)
            }
            let smoothed = zip(zip(depths, depths.dropFirst()), depths.dropFirst().dropFirst())
                .map { $0.0 + $0.1 + $1 }
            print(countIncreases(smoothed))
        }
    }
}

extension Script {
    struct Day2_1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2_1")

        func run() {
            var commands: [Command] = []
            while let line = readLine() {
                commands.append(Command(from: line))
            }
            let position = commands.reduce((0,0)) { (pos, command) in
                var (h, depth) = pos
                switch command.direction {
                case .forward:
                    h += command.distance
                case .down:
                    depth += command.distance
                case .up:
                    depth -= command.distance
                }
                return (h, depth)
            }
            print(position)
        }

        struct Command {
            let direction: Direction
            let distance: Int

            init(from line: String) {
                let split = line.split(separator: " ")
                switch split[0] {
                case "forward":
                    direction = .forward
                case "up":
                    direction = .up
                case "down":
                    direction = .down
                default:
                    fatalError()
                }
                distance = Int(split[1])!
            }
        }

        enum Direction: String {
            case forward, down, up
        }
    }
}

Script.main()

