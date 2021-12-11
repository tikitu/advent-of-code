import ArgumentParser

struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2021 programs",
        version: "0.0.1",
        subcommands: [Day1_1.self, Day1_2.self, Day2_1.self, Day2_2.self,
                      Day3_1.self, Day3_2.self, Day4_1.self, Day4_2.self,
                      Day5_1.self, Day5_2.self]
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

    struct Day2_2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "2_2")

        func run() {
            var commands: [Command] = []
            while let line = readLine() {
                commands.append(Command(from: line))
            }
            let position = commands.reduce(Position(h: 0, depth: 0, aim: 0)) { (old, command) in
                var new = old
                switch command.direction {
                case .forward:
                    new.h += command.distance
                    new.depth += old.aim * command.distance
                case .down:
                    new.aim += command.distance
                case .up:
                    new.aim -= command.distance
                }
                return new
            }
            print(position)
        }

        struct Position {
            var h: Int
            var depth: Int
            var aim: Int
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

func getLines() -> [String] {
    // there *must* be a better way than this?!
    var lines: [String] = []
    while let line = readLine() {
        lines.append(line)
    }
    return lines
}

extension Script {
    struct Day3_1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "3_1")

        func run() {
            let lines = getLines()
                .map { $0.reversed() } // these are numbers: align the least-significant bits
            var ones: [Int: Int] = [:]
            var zeros: [Int: Int] = [:]
            for line in lines {
                for (i, c) in line.enumerated() {
                    switch c {
                    case "0":
                        zeros[i, default: 0] += 1
                    case "1":
                        ones[i, default: 0] += 1
                    default:
                        fatalError()
                    }
                }
            }
            print("ones: \(ones)")
            print("zeros: \(zeros)")

            var gamma = 0
            var epsilon = 0
            for i in (Set(ones.keys).union(Set(zeros.keys)).sorted()) {
                if ones[i, default: 0] > zeros[i, default: 0] {
                    gamma += 2 << (i - 1)
                } else { // specs don't say what happens if they're equal, shrug
                    epsilon += 2 << (i - 1)
                }
            }
            print("gamma: \(gamma)")
            print("epsilon: \(epsilon)")
        }
    }
}

extension Script {
    struct Day3_2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "3_2")

        func count(_ lines: [String]) -> ([Int: Int], [Int: Int]) {
            var ones: [Int: Int] = [:]
            var zeros: [Int: Int] = [:]
            for line in lines.map({ $0.reversed() }) {
                for (i, c) in line.enumerated() {
                    switch c {
                    case "0":
                        zeros[i, default: 0] += 1
                    case "1":
                        ones[i, default: 0] += 1
                    default:
                        fatalError()
                    }
                }
            }
            return (ones, zeros)
        }

        func run() {
            let lines = getLines()

            var oxygon = lines
            var bitIndex = 0
            while oxygon.count > 1 {
                let (ones, zeros) = count(oxygon)
                let maxBitIndex = max(ones.keys.max()!, zeros.keys.max()!)
                let shouldBe: String = ones[maxBitIndex - bitIndex, default: 0] >= zeros[maxBitIndex - bitIndex, default: 0] ? "1" : "0"
                oxygon.removeAll(where: { s in
                    s.count >= bitIndex &&
                    s.dropFirst(bitIndex).first.map(String.init) != shouldBe
                })
                bitIndex += 1
                print("partial: ", oxygon)
            }
            print(oxygon, " -> ", binary(oxygon.first!))

            var co2 = lines
            bitIndex = 0
            while co2.count > 1 {
                let (ones, zeros) = count(co2)
                let maxBitIndex = max(ones.keys.max()!, zeros.keys.max()!)
                let shouldBe: String = ones[maxBitIndex - bitIndex, default: 0] < zeros[maxBitIndex - bitIndex, default: 0] ? "1" : "0"
                co2.removeAll(where: { s in
                    s.count >= bitIndex &&
                    s.dropFirst(bitIndex).first.map(String.init) != shouldBe
                })
                bitIndex += 1
                print("partial: ", co2)
            }
            print(co2, " -> ", binary(co2.first!))
        }
    }
}

func binary(_ s: String) -> Int {
    s.reversed().enumerated().reduce(0) { (accum, pos) in
        let (i, bit) = pos
        switch bit {
        case "1":
            return accum + (2 << (i - 1))
        default:
            return accum
        }
    }
}

extension Script {
    struct Board {
        let numbers: [[Int]] // 5x5
        var marks: [[Bool]] = [[false, false, false, false, false],
                               [false, false, false, false, false],
                               [false, false, false, false, false],
                               [false, false, false, false, false],
                               [false, false, false, false, false]]

        /// Mark the number, and return true if it won (else false)
        mutating func mark(number: Int) -> Bool {
            for row in (0..<5) {
                for col in (0..<5) {
                    if numbers[row][col] == number {
                        marks[row][col] = true
                        if marks[row].allSatisfy({ $0 })
                            || marks.map({ $0[col] }).allSatisfy({ $0 }) {
                            return true
                        }
                    }
                }
            }
            return false
        }

        func unmarked() -> Int {
            return zip(numbers.flatMap { $0 }, marks.flatMap { $0 })
                .filter { !$0.1 }
                .map { $0.0 }
                .reduce(0, +)
        }
    }

    static func readBoard() -> Board? {
        guard readLine() != nil else { return nil }
        return Board(numbers: [
            readLine()!.split(separator: " ").map { Int($0)! },
            readLine()!.split(separator: " ").map { Int($0)! },
            readLine()!.split(separator: " ").map { Int($0)! },
            readLine()!.split(separator: " ").map { Int($0)! },
            readLine()!.split(separator: " ").map { Int($0)! },
        ])
    }

    struct Day4_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "4_1"
        )

        func run() {
            let numbers = readLine()!.split(separator: ",").map { Int($0)! }
            var boards: [Board] = []
            while let board = readBoard() {
                boards.append(board)
            }

            for number in numbers {
                for i in (0..<boards.count) {
                    if boards[i].mark(number: number) {
                        print("board won! with \(number)")
                        print(boards[i])
                        let score = boards[i].unmarked()
                        print("score \(score) * \(number) = \(score * number)")
                        return
                    }
                }
            }
        }
    }

    struct Day4_2: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "4_2"
        )

        func run() {
            let numbers = readLine()!.split(separator: ",").map { Int($0)! }
            var boards: [Board] = []
            while let board = readBoard() {
                boards.append(board)
            }

            for number in numbers {
                for i in (0..<boards.count).reversed() {
                    if boards[i].mark(number: number) {
                        print("board won! with \(number)")
                        if boards.count == 1 {
                            let score = boards[i].unmarked()
                            print("score \(score) * \(number) = \(score * number)")
                            return
                        } else {
                            boards.remove(at: i)
                        }
                    }
                }
            }
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

extension Script {
    struct LineSegment {
        var start: (Int, Int)
        var end: (Int, Int)

        init(from string: String) {
            let ends = string.split(whereSeparator: { " ->".contains($0) })
            let start = ends[0].split(separator: ",").map { Int($0)! }
            let end = ends[1].split(separator: ",").map { Int($0)! }
            self.start = (start[0], start[1])
            self.end = (end[0], end[1])
        }
    }

    struct Day5_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "5_1"
        )

        func run() {
            let lines = readLines().map(LineSegment.init(from:))

            let horizontalAndVertical = lines.filter { $0.start.0 == $0.end.0 || $0.start.1 == $0.end.1 }

            let maxX = horizontalAndVertical.map { max($0.start.0, $0.end.0 ) }.max()!
            let maxY = horizontalAndVertical.map { max($0.start.1, $0.end.1) }.max()!

            var seabed = Array(repeating: 0, count: (maxX + 1) * (maxY + 1))
            for line in horizontalAndVertical {
                var p = line.start
                seabed[p.0 + maxX * p.1] += 1
                while p != line.end {
                    if p.0 < line.end.0 { p.0 += 1 }
                    if p.0 > line.end.0 { p.0 -= 1 }
                    if p.1 < line.end.1 { p.1 += 1 }
                    if p.1 > line.end.1 { p.1 -= 1 }
                    seabed[p.0 + maxX * p.1] += 1
                }
            }
            let dangerous = seabed.filter { $0 > 1 }
            for row in (0...maxY) {
                print(seabed[row * maxX ..< (row + 1) * maxX])
            }
            print("counted to \(dangerous.count)")
        }
    }

    struct Day5_2: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "5_2"
        )

        func run() {
            let lines = readLines().map(LineSegment.init(from:))

            let maxX = lines.map { max($0.start.0, $0.end.0 ) }.max()!
            let maxY = lines.map { max($0.start.1, $0.end.1) }.max()!

            var seabed = Array(repeating: 0, count: (maxX + 1) * (maxY + 1))
            for line in lines {
                var p = line.start
                seabed[p.0 + maxX * p.1] += 1
                while p != line.end {
                    if p.0 < line.end.0 { p.0 += 1 }
                    if p.0 > line.end.0 { p.0 -= 1 }
                    if p.1 < line.end.1 { p.1 += 1 }
                    if p.1 > line.end.1 { p.1 -= 1 }
                    seabed[p.0 + maxX * p.1] += 1
                }
            }
            let dangerous = seabed.filter { $0 > 1 }
            for row in (0...maxY) {
                print(seabed[row * maxX ..< (row + 1) * maxX])
            }
            print("counted to \(dangerous.count)")
        }
    }
}

Script.main()

