import ArgumentParser
import Collections

struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2021 programs",
        version: "0.0.1",
        subcommands: [Day1_1.self, Day1_2.self, Day2_1.self, Day2_2.self,
                      Day3_1.self, Day3_2.self, Day4_1.self, Day4_2.self,
                      Day5_1.self, Day5_2.self, Day6_1.self, Day7_1.self,
                      Day8_1.self, Day8_2.self, Day9_1.self, Day10.self,
                      Day11.self, Day12.self, Day13.self, Day14.self, Day15.self]
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

extension Script {
    struct Day6_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "6_1"
        )

        // *must* have exactly 9 elements (indices 0...8)
        func iterate(counts: inout [Int]) {
            let reproducing = counts.first!
            counts.remove(at: 0)
            counts[6] += reproducing
            counts.append(reproducing)
        }

        func run() {
            let fish = [1,1,3,1,3,2,1,3,1,1,3,1,1,2,1,3,1,1,3,5,1,1,1,3,1,2,1,1,1,1,4,4,1,2,1,2,1,1,1,5,3,2,1,5,2,5,3,3,2,2,5,4,1,1,4,4,1,1,1,1,1,1,5,1,2,4,3,2,2,2,2,1,4,1,1,5,1,3,4,4,1,1,3,3,5,5,3,1,3,3,3,1,4,2,2,1,3,4,1,4,3,3,2,3,1,1,1,5,3,1,4,2,2,3,1,3,1,2,3,3,1,4,2,2,4,1,3,1,1,1,1,1,2,1,3,3,1,2,1,1,3,4,1,1,1,1,5,1,1,5,1,1,1,4,1,5,3,1,1,3,2,1,1,3,1,1,1,5,4,3,3,5,1,3,4,3,3,1,4,4,1,2,1,1,2,1,1,1,2,1,1,1,1,1,5,1,1,2,1,5,2,1,1,2,3,2,3,1,3,1,1,1,5,1,1,2,1,1,1,1,3,4,5,3,1,4,1,1,4,1,4,1,1,1,4,5,1,1,1,4,1,3,2,2,1,1,2,3,1,4,3,5,1,5,1,1,4,5,5,1,1,3,3,1,1,1,1,5,5,3,3,2,4,1,1,1,1,1,5,1,1,2,5,5,4,2,4,4,1,1,3,3,1,5,1,1,1,1,1,1]
            //            let fish = [3,4,3,1,2]
            var counts = Array(repeating: 0, count: 9)
            for f in fish {
                counts[f] += 1
            }
            for i in (1...256) {
                iterate(counts: &counts)
                if i < 20 {
                    print("\(i): \(counts)")
                }
            }
            print("total:", counts.reduce(0, +))
        }
    }
}

extension Script {
    struct Day7_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "7_1"
        )

        func brute_force(positions: [Int]) {
            let min = positions.min()!
            let max = positions.max()!
            var best = min
            var bestCost = Int.max
            for position in (min...max) {
                let cost = positions.map { triangle(abs($0 - position)) }.reduce(0, +)
                if cost < bestCost {
                    best = position
                    bestCost = cost
                }
            }
            print(best, " with cost ", bestCost)
        }

        func triangle(_ i: Int) -> Int {
            (i * (i + 1)) / 2
        }

        func run() {
            //let positions: [Int] = [16,1,2,0,4,2,7,1,2,14]
            let positions = [1101,1,29,67,1102,0,1,65,1008,65,35,66,1005,66,28,1,67,65,20,4,0,1001,65,1,65,1106,0,8,99,35,67,101,99,105,32,110,39,101,115,116,32,112,97,115,32,117,110,101,32,105,110,116,99,111,100,101,32,112,114,111,103,114,97,109,10,62,461,1087,183,1096,431,412,200,486,1543,25,580,1030,15,65,1186,9,226,173,77,119,691,855,451,88,741,221,1465,190,779,327,179,627,366,288,174,1147,49,773,3,5,65,20,172,601,307,611,699,1168,933,1295,832,242,62,8,4,226,768,33,566,21,10,937,15,760,100,574,181,89,72,1054,225,28,0,685,661,131,281,933,90,233,109,1345,81,106,636,1262,193,172,1056,709,1176,447,536,1054,929,171,226,127,274,710,917,218,192,25,128,321,1816,515,181,759,20,258,134,281,151,99,479,623,534,72,576,534,337,54,293,450,230,963,14,357,446,1244,964,16,865,52,1,1171,77,7,275,313,894,577,305,1119,393,285,354,136,1147,241,441,166,1024,650,101,178,1514,186,902,367,5,431,374,56,507,857,1316,0,186,63,118,1062,62,446,266,47,354,168,65,1036,447,689,160,749,728,791,1066,99,675,194,891,153,737,801,254,905,1046,21,413,386,204,603,373,218,440,137,1340,1616,121,903,722,841,731,213,219,405,336,1345,144,329,285,213,272,717,47,126,1137,548,32,21,755,219,595,187,143,636,476,397,185,70,345,89,319,80,867,26,1166,509,24,16,151,605,1415,893,814,473,289,377,407,44,184,290,447,1669,116,319,455,294,145,513,58,247,186,1565,31,297,1,226,1051,1561,1233,254,1274,422,547,1638,354,1855,419,71,1003,626,519,109,96,996,117,32,226,424,184,181,720,1311,1162,11,86,438,408,1269,887,612,327,133,1117,1390,345,10,370,175,37,1154,659,707,193,665,65,359,758,1253,498,219,601,59,919,1371,289,9,437,392,626,981,2,51,733,780,101,541,770,464,28,616,81,1708,1515,719,780,1214,673,268,246,25,252,301,205,27,160,0,298,69,285,58,809,1369,812,628,353,47,632,123,168,135,277,303,614,365,330,1385,1117,1346,737,744,1403,385,215,437,276,726,673,668,494,164,1,763,696,487,252,375,1253,42,1111,963,58,63,11,1648,1080,964,526,454,1349,1098,95,59,78,36,42,654,1441,1129,464,740,355,370,44,4,154,986,439,828,287,969,765,565,836,196,387,556,34,586,438,1205,760,798,6,61,260,25,418,1628,566,3,530,753,758,16,92,30,1388,109,240,513,1048,1056,588,1634,418,297,195,447,1145,198,466,0,607,180,57,58,72,319,221,869,744,339,195,1295,268,1336,1310,38,714,326,393,445,422,102,389,188,147,21,805,381,520,561,282,438,115,431,156,482,50,890,470,22,60,46,1588,971,1219,82,380,1061,948,455,99,255,400,1832,91,225,280,520,279,91,172,92,946,434,182,164,142,83,91,281,538,962,77,1104,1522,310,4,961,62,9,1257,596,464,733,338,1166,334,380,509,773,90,498,480,1523,1632,530,543,413,589,748,4,861,11,233,192,699,33,615,1853,205,270,624,1132,1100,227,1402,349,183,179,645,4,1120,962,317,326,128,422,281,302,701,53,179,34,802,272,1254,375,764,418,16,160,943,479,416,717,644,1029,372,140,114,449,351,159,305,1299,749,488,502,180,210,17,533,258,120,333,1097,185,1911,451,360,66,1329,1260,209,1611,454,809,336,783,1438,20,26,609,720,155,578,367,231,1715,64,610,465,752,81,108,389,995,244,1291,1144,159,161,1630,561,813,261,67,1604,124,231,833,14,15,1245,1309,1165,103,1270,228,1,133,644,581,218,481,716,237,155,360,110,1408,931,99,216,5,21,67,348,927,325,759,1127,557,584,696,428,653,548,247,1519,1682,132,3,1648,230,229,136,253,543,1153,204,669,58,81,357,85,82,749,503,139,32,1170,1352,151,653,1441,51,392,474,2,114,64,418,125,514,838,473,794,331,13,327,1476,836,37,3,0,115,18,1784,300,190,99,997,1164,31,1255,96,64,1101,354,698,372,852,1508,100,289,32,704,292,504,191,1342,231,692,12,369,1182,62,809,566,688,218,2,539,234,996,444,228,456,369,115,23,29,226,940,95,404,349,1254,171,69,711,2,1405,1181,34,8,92,173,533,20,181,921,201,1236,185,457,526,2,106,12,601,58,339,457,590,15,1583,473,451,1124,1569,401,72,154,9,1331,471,165,516,463,543,298,197,43,1294,101,1058,1025,1099,4,634,90,104,870,480,412,290,11,924,338,30,281,83,268,20,848,1722,1060,987,9,196,266,28,402,267,199,814,986,440,906,796,1403,1394,62,136,442,412,1729,571,459,91,730,269,172,202,772,305]
            brute_force(positions: positions)
        }
    }
}

extension Script {
    struct Day8_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "8_1"
        )

        func run() {
            let trialInput = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"""

            print(count1478(input: trialInput.split(separator: "\n").map(String.init)))

            print(count1478(input: readLines()))
        }

        func count1478(input: [String]) -> Int {
            input
                .map { $0.split(separator: "|")[1] }
                .flatMap { $0.split(separator: " ") }
                .filter {
                    switch $0.count {
                    case 2, 4, 3, 7:
                        return true
                    default:
                        return false
                    }
                }
                .count
        }
    }

    struct Day8_2: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "8_2"
        )

        func decode(allDigits: [Set<Character>], output: [String]) -> Int {
            // 1 = cf (unique 2-segment)
            // 7 = acf (unique 3-segment)
                // segment a = Set(7) - Set(1)
            // Set(4) - Set(1) = bd

            // Set(4)
            // Set(7)
            // Set(1)
            // Set(8) (useless)

            // a is used 8 times
            // b is used 6 times
            // c is used 8 times
            // d is used 7 times
            // e is used 4 times <--
            // f is used 9 times <--
            // g is used 7 times

            // a = Set(7) - Set(1)
            // b = unique 6x
            // c = Set(7) - a - f
            // d = Set(4) - Set(1) - b
            // e = unique 4x
            // f = unique 9x
            // g = ... whatever is left ...

            let digit4 = allDigits.first(where: { $0.count == 4 })!
            let digit7 = allDigits.first(where: { $0.count == 3 })!
            let digit1 = allDigits.first(where: { $0.count == 2 })!

            var counts = [Character: Int]()
            for digit in allDigits {
                for segment in digit {
                    counts[segment, default: 0] += 1
                }
            }

            let everything = allDigits.reduce(Set(), { $0.union($1) })

            print(digit4, digit7, digit1, everything, counts)

            let a = digit7.subtracting(digit1).first!
            let b = counts.first(where: { (_, value) in value == 6 })!.key
            let e = counts.first(where: { (_, value) in value == 4 })!.key
            let f = counts.first(where: { (_, value) in value == 9 })!.key
            let c = digit7.subtracting([a]).subtracting([f]).first!
            let d = digit4.subtracting(digit1).subtracting([b]).first!
            let g = everything.subtracting([a, b, c, d, e, f]).first!
            print(a, b, c, d, e, f, g)

            let lookupSegment: [Character: Character] = [
                a: "a",
                b: "b",
                c: "c",
                d: "d",
                e: "e",
                f: "f",
                g: "g"
            ]

            let lookupDigit = [
                "abcefg": 0,
                "cf": 1,
                "acdeg": 2,
                "acdfg": 3,
                "bcdf": 4,
                "abdfg": 5,
                "abdefg": 6,
                "acf": 7,
                "abcdefg": 8,
                "abcdfg": 9
            ]

            var total = 0
            for digit in output {
                let unscrambled: String = String(
                    digit
                        .map { lookupSegment[$0]! }
                        .sorted(by: { $0 < $1 }))
                let value = lookupDigit[unscrambled]!
                total = 10 * total + value
            }
            return total
        }

        func run() {
            let allValues: [Int] = readLines().map {
                let split = $0.split(separator: "|")
                let digits: [Set<Character>] = split[0]
                    .split(separator: " ")
                    .filter { !$0.isEmpty }
                    .map(Set.init)
                let outputs = split[1].split(separator: " ").filter { !$0.isEmpty }.map(String.init)
                return decode(allDigits: digits, output: outputs)
            }
            print(allValues.reduce(0, +))
        }
    }

}

extension Script {
    struct Day9_1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "9_1"
        )

        struct CaveMap {
            let x: Int
            let y: Int
            let heights: [Int] // heights.count = x * y

            init(x: Int, y: Int, heights: [Int]) {
                precondition(heights.count == x * y)
                self.x = x
                self.y = y
                self.heights = heights
            }

            func height(x: Int, y: Int) -> Int {
                if x < 0 || x >= self.x { return Int.max }
                if y < 0 || y >= self.y { return Int.max }
                return heights[x + self.x * y]
            }

            func risk() -> Int {
                var risk = 0
                for x in (0..<self.x) {
                    for y in (0..<self.y) {
                        let h = height(x: x, y: y)
                        if height(x: x - 1, y: y) <= h { continue }
                        if height(x: x + 1, y: y) <= h { continue }
                        if height(x: x, y: y - 1) <= h { continue }
                        if height(x: x, y: y + 1) <= h { continue }
                        risk += h + 1
                    }
                }
                return risk
            }

            func basins() -> [Int] {
                var basins = heights.map { _ in 0 }
                var count = 0
                for x in (0..<self.x) {
                    for y in (0..<self.y) {
                        let h = height(x: x, y: y)
                        if height(x: x - 1, y: y) <= h { continue }
                        if height(x: x + 1, y: y) <= h { continue }
                        if height(x: x, y: y - 1) <= h { continue }
                        if height(x: x, y: y + 1) <= h { continue }
                        count += 1
                        basins[x + self.x * y] = count
                    }
                }

                var changed = true
                while changed {
                    changed = false
                    for x in (0..<self.x) {
                        for y in (0..<self.y) {
                            if height(x: x, y: y) == 9 { continue }
                            if basins[x + y * self.x] != 0 { continue }
                            for delta in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                                if height(x: x + delta.0, y: y + delta.1) == Int.max { continue }
                                let adjacent = basins[x + delta.0 + self.x * (y + delta.1)]
                                if adjacent != 0 {
                                    changed = true
                                    basins[x + y * self.x] = adjacent
                                }
                            }
                        }
                    }
                }

                return basins
            }

            func prettify(_ arr: [Int]) {
                precondition(arr.count == self.x * self.y)
                for row in (0..<self.y) {
                    print(arr[row * self.x..<(row+1) * self.x])
                }
            }
        }

        func run() {
            let input = readLines()
//            let input: [String] = [
//                "2199943210",
//                "3987894921",
//                "9856789892",
//                "8767896789",
//                "9899965678"
//            ]
            let heights: [Int] = input
                .map { Array($0) }
                .flatMap { $0.map { String($0) } } // wowza
                .map { Int($0)! }
            let map = CaveMap(
                x: input.first!.count,
                y: input.count,
                heights: heights
            )
//            print(map.risk())
//            map.prettify(map.basins())

            let basins = map.basins()
            let counts = Dictionary(grouping: basins, by: { $0 })
                .mapValues { $0.count }
            print(counts.sorted(by: { $0.value > $1.value }))
        }
    }
}

extension Script {
    struct Day10: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "10"
        )

        class Parser {
            init() { state = [] }

            var state: [Character]

            func matches(_ opening: Character?, _ closing: Character) -> Bool {
                switch (opening, closing) {
                case (nil, _):
                    return false
                case ("(", ")"), ("[", "]"), ("{", "}"), ("<", ">"):
                    return true
                default:
                    return false
                }
            }

            // Returning a character as "found unexpected char"
            func parse(input: String) -> Character? {
                var reversed = String(input.reversed())
                while let next = reversed.popLast() {
                    switch next {
                    case "(", "[", "<", "{":
                        state.append(next)
                    case ")", "]", ">", "}":
                        if matches(state.last, next) {
                            _ = state.popLast()
                        } else {
                            return next
                        }
                    default:
                        preconditionFailure("unrecognised character \(next)")
                    }
                }
                return nil
            }

            func completionScore() -> Int {
                var score = 0
                while let next = state.popLast() {
                    score *= 5
                    switch next {
                    case "(":
                        score += 1
                    case "[":
                        score += 2
                    case "{":
                        score += 3
                    case "<":
                        score += 4
                    default:
                        preconditionFailure("found unexpected \(next) on state stack")
                    }
                }
                return score
            }
        }

        func corruptedValue(of c: Character) -> Int {
            switch c {
            case ")": return 3
            case "]": return 57
            case "}": return 1197
            case ">": return 25137
            default:
                preconditionFailure("unexpected char \(c)")
            }
        }

        func run() {
//            let input = """
//[({(<(())[]>[[{[]{<()<>>
//[(()[<>])]({[<{<<[]>>(
//{([(<{}[<>[]}>{[]{[(<()>
//(((({<>}<{<{<>}{[]{[]{}
//[[<[([]))<([[{}[[()]]]
//[{[{({}]{}}([{[{{{}}([]
//{<[[]]>}<{[{[{[]{()[[[]
//[<(<(<(<{}))><([]([]()
//<{([([[(<>()){}]>(<<{{
//<{([{{}}[<[[[<>{}]]]>[]]
//"""
            var corruptedScore = 0
            var incompleteScores: [Int] = []
//            for line in input.split(separator: "\n").map(String.init) {
            for line in readLines() {
                let p = Parser()
                if let unexpected = p.parse(input: line) {
                    corruptedScore += corruptedValue(of: unexpected)
                    print("corrupted: \(line) --- \(unexpected) --- \(corruptedScore)")
                } else {
                    let incompleteScore = p.completionScore()
                    incompleteScores.append(incompleteScore)
                    print("incomplete: \(line) --- \(incompleteScore)")
                }
            }
            print()
            incompleteScores.sort()
            print(incompleteScores[incompleteScores.count / 2])
        }
    }
}

extension Script {
    struct Day11: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "11"
        )

        struct CaveMap {
            let x: Int
            let y: Int
            var values: [Int] // values.count = x * y

            init(from strings: [String]) {
                let values: [Int] = strings
                    .map { Array($0) }
                    .flatMap { $0.map { String($0) } } // wowza
                    .map { Int($0)! }
                self.init(
                    x: strings.first!.count,
                    y: strings.count,
                    values: values
                )
            }

            init(x: Int, y: Int, values: [Int]) {
                precondition(values.count == x * y)
                self.x = x
                self.y = y
                self.values = values
            }

            func value(x: Int, y: Int) -> Int? {
                if x < 0 || x >= self.x { return nil }
                if y < 0 || y >= self.y { return nil }
                return values[x + self.x * y]
            }

            mutating func increment(x: Int, y: Int) -> Int? {
                if x < 0 || x >= self.x { return nil }
                if y < 0 || y >= self.y { return nil }
                values[x + self.x * y] += 1
                return values[x + self.x * y]
            }

            // Returns the number of flashes
            mutating func step() -> Int {
                var queue: [(Int, Int)] = []
                var flashes = 0
                for x in (0..<self.x) {
                    for y in (0..<self.y) {
                        if increment(x: x, y: y) == 10 {
                            queue.append((x, y))
                        }
                    }
                }
                while let next = queue.first {
                    let (x, y) = next
                    flashes += 1
                    queue.remove(at: 0)
                    for deltaX in [-1, 0, 1] {
                        for deltaY in [-1, 0, 1] {
                            if increment(x: x + deltaX, y: y + deltaY) == 10 {
                                queue.append((x + deltaX, y + deltaY))
                            }
                        }
                    }
                }
                for x in (0..<self.x) {
                    for y in (0..<self.y) {
                        if let v = value(x: x, y: y), v > 9 {
                            values[x + self.x * y] = 0
                        }
                    }
                }
                return flashes
            }

            func prettify(_ arr: [Int]) {
                precondition(arr.count == self.x * self.y)
                for row in (0..<self.y) {
                    print(arr[row * self.x..<(row+1) * self.x])
                }
            }

            func prettyPrint() {
                prettify(values)
            }
        }

        func run() {
            let input: [String] = """
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
""".split(separator: "\n").map(String.init)
            let _: [String] = """
1553421288
5255384882
1224315732
4258242274
1658564216
6872651182
5775552238
5622545172
8766672318
2178374835
""".split(separator: "\n").map(String.init)

            print(input)

            var map = CaveMap(from: input)

            var flashes = 0
            var i = 0
            while true {
                i += 1
                let flashesThisStep = map.step()
                flashes += flashesThisStep
                if flashesThisStep == 100 {
                    print("*** synchronised at step \(i) ***")
                    break
                }
            }
            map.prettyPrint()
            print(flashes)
        }
    }
}

extension Script {
    struct Day12: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "12"
        )

        struct Graph {
            let edges: [String: Set<String>]

            init(spec: [String]) {
                self.init(spec: spec
                    .map { $0.split(separator: "-") }
                    .map { (String($0[0]), String($0[1])) })
            }

            init(spec: [(String, String)]) {
                var edges: [String: Set<String>] = [:]
                for pair in spec {
                    if pair.0 != "end" && pair.1 != "start" {
                        edges[pair.0, default: Set()].insert(pair.1)
                    }
                    if pair.1 != "end" && pair.0 != "start" {
                        edges[pair.1, default: Set()].insert(pair.0)
                    }
                }
                self.edges = edges
            }

            func paths(
                from prefix: [String], to end: String,
                usedOurOneSmallVisit: Bool
            ) -> [[String]] {
                let room = prefix.last!
                if room == end {
                    return [prefix]
                }
                var result: [[String]] = []
                for next in edges[room]! {
                    if next.allSatisfy({ $0.isLowercase }) && prefix.contains(next) {
                        // returning to a small cave: is this allowed?
                        if usedOurOneSmallVisit {
                            continue
                        } else {
                            result.append(
                                contentsOf: paths(
                                    from: prefix + [next], to: end,
                                    usedOurOneSmallVisit: true))
                        }
                    } else {
                        result.append(
                            contentsOf: paths(
                                from: prefix + [next], to: end,
                                usedOurOneSmallVisit: usedOurOneSmallVisit))
                    }
                }
                return result
            }
        }

        func run() {
            let input: [String] = """
qi-UD
jt-br
wb-TF
VO-aa
UD-aa
br-end
end-HA
qi-br
br-HA
UD-start
TF-qi
br-hf
VO-hf
start-qi
end-aa
hf-HA
hf-UD
aa-hf
TF-hf
VO-start
wb-aa
UD-wb
KX-wb
qi-VO
br-TF
""".split(separator: "\n").map(String.init)

            let graph = Graph(spec: input)
            print(graph)

            let paths = graph.paths(from: ["start"], to: "end", usedOurOneSmallVisit: false)
            for path in paths {
                print(path)
            }
            print(paths.count)
        }
    }
}

extension Script {
    struct Day13: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "13"
        )

        struct Point: Equatable, Hashable {
            let x: Int
            let y: Int
        }

        func run() {
            let lines = readLines()
//            let lines = """
//6,10
//0,14
//9,10
//0,3
//10,4
//4,11
//6,0
//6,12
//4,1
//0,13
//10,12
//3,4
//3,0
//8,4
//1,10
//2,14
//8,10
//9,0
//
//fold along y=7
//fold along x=5
//""".split(separator: "\n").map(String.init)
            let coords = lines.filter { $0.contains(",") }
                .map { $0.split(separator: ",") }
                .map { Point(x: Int($0[0])!, y: Int($0[1])!) }
            let folds = lines.filter { $0.starts(with: "fold") }


            let result = folds.reduce(coords) { coords, fold in apply(fold: fold, to: coords) }
            print(result)

            let reduced = Set(result).sorted(by: { ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)) })
            print(reduced)

            var x = -1
            var y = -1
            for point in reduced {
                while point.y > y { print(); x = -1; y += 1 }
                while point.x > x { print(".", terminator: ""); x += 1 }
                print("#", terminator: "")
                x += 1
            }
        }

        func apply(fold: String, to coords: [Point]) -> [Point] {
            let split = fold.split(separator: "=")
            let axis = split[0]
            let point = Int(split[1])!

            return coords.map { coord in
                switch axis {
                case "fold along x":
                    return Point(x: coord.x > point ? point - (coord.x - point) : coord.x,
                                 y: coord.y)
                case "fold along y":
                    return Point(x: coord.x,
                                 y: coord.y > point ? point - (coord.y - point) : coord.y)
                default:
                    preconditionFailure("bad fold instruction \(axis)")
                }
            }
        }
    }
}

extension Script {
    struct Day14: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "14"
        )

        func run() {
            let _ = """
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
""".split(separator: "\n").map(String.init)

            let input = readLines()
            let template = input.filter { !$0.contains("-") }.filter { !$0.isEmpty }.first!
            let rules: [String: Character] = Dictionary(
                uniqueKeysWithValues: input.filter { $0.contains("-") }.map {
                    let chars = Array($0)
                    return ("\(chars[0])\(chars[1])", chars[6])
                }
            )
            print(template, rules)

//            var polymer = Array(template)
//            for i in (0..<40) {
//                print(i)
//                //print("\(i): \(polymer)")
//                step(input: &polymer, rules: rules)
//            }
//
//
//            let counts: [Character: Int] = polymer.reduce(into: [:]) { counts, char in
//                counts[char, default: 0] += 1
//            }
//            print(counts)
//            let all = counts.values.sorted()
//            print(all.last! - all.first!)

            var rawCounts: [Character: UInt64] = template.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            print(rawCounts)
            var polymer: [String: UInt64] = zip(template, template.dropFirst())
                .map {
                    "\($0)\($1)"
                }
                .reduce(into: [:]) { polymer, pair in
                    polymer[pair, default: 0] += 1
                }
            for step in (0..<40) {
                print(step)
                var next = [String: UInt64]()
                polymer
                    .forEach { (pair, count) in
                        if let insert = rules[pair] {
                            guard let f = pair.first, let l = pair.last else {
                                print("wth?!? [\(pair)]")
                                fatalError()
                            }
                            rawCounts[insert, default: 0] += count
                            next["\(f)\(insert)", default: 0] += count
                            next["\(insert)\(l)", default: 0] += count
                        } else {
                            next[pair] = count
                        }
                    }
                polymer = next
            }
            print("huzzah!")
//            print(rawCounts)
            let sortedCounts = rawCounts.sorted(by: { $0.value < $1.value })
            print(sortedCounts.count)
            print(sortedCounts.last!.value - sortedCounts.first!.value)
        }
    }
}

extension Script {
    struct Day15: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "15"
        )

        func run() {
            let _ = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
""".split(separator: "\n").map(String.init)

            let input = readLines()

            let longH = input.map {
                [$0,
                 $0.bump(),
                 $0.bump().bump(),
                 $0.bump().bump().bump(),
                 $0.bump().bump().bump().bump()].joined()
            }
            let longV = [
                longH,
                longH.bump(),
                longH.bump().bump(),
                longH.bump().bump().bump(),
                longH.bump().bump().bump().bump()
            ].flatMap { $0 }

            let map = CaveMap(from: longV)
            var solutions = Array<Solution?>(repeating: nil, count: map.values.count)

            var front = Heap<Solution>()

            front.insert(Solution(cost: 0, path: [(0, 0)]))

            while let current = front.popMin() {
                let pos = current.path.last!
                if pos == (map.x - 1, map.y - 1) {
                    print(current)
                    print("total cost: \(current.cost)")
                    break
                }
                for adjacent in [(pos.0 - 1, pos.1), (pos.0 + 1, pos.1),
                                 (pos.0, pos.1 - 1), (pos.0, pos.1 + 1)] {
                    if adjacent == (map.x - 1, map.y - 1) {
                        print("*******")
                        print(current)
                        print("total cost: \(current.cost + map.value(x: adjacent.0, y: adjacent.1)!)")
                        fatalError() // heheheh "break twice" wtf Swift
                    }
                    if let index = map.index(x: adjacent.0, y: adjacent.1) {
                        let cost = map.values[index]
                        if let alreadyVisited = solutions[index],
                           alreadyVisited.cost <= current.cost + cost {
                            continue
                        }
                        if solutions[index] == nil { print("\(adjacent)", terminator: " ") }
                        //print("\(adjacent)", terminator: " ")
                        var next = current
                        next.cost += cost
                        next.path.append(adjacent)
                        solutions[index] = next
                        front.insert(next)
                    }
                }
            }
        }

        struct Solution: Comparable {
            static func < (lhs: Script.Day15.Solution, rhs: Script.Day15.Solution) -> Bool {
                if lhs.cost < rhs.cost { return true }
                if lhs.cost > rhs.cost { return false }
                for (lhs, rhs) in zip(lhs.path, rhs.path) {
                    if lhs.0 < rhs.0 { return true }
                    if lhs.0 > rhs.0 { return false }
                    if lhs.1 < rhs.1 { return true }
                    if lhs.1 > rhs.1 { return false}
                }
                if lhs.path.count < rhs.path.count { return true }
                if lhs.path.count > rhs.path.count { return false }
                return false
            }

            static func == (lhs: Script.Day15.Solution, rhs: Script.Day15.Solution) -> Bool {
                return lhs.cost == rhs.cost
                && lhs.path.map { $0.0 } == rhs.path.map { $0.0 }
                && lhs.path.map { $0.1 } == rhs.path.map { $0.1 }
            }

            var cost: Int
            var path: [(Int, Int)]
        }
    }
}

extension String {
    func bump() -> String {
        return Array(self)
            .map {
                switch $0 {
                case "1": return "2"
                case "2": return "3"
                case "3": return "4"
                case "4": return "5"
                case "5": return "6"
                case "6": return "7"
                case "7": return "8"
                case "8": return "9"
                case "9": return "1"
                default: fatalError()
                }
            }
            .joined(separator: "")
    }
}

extension Array where Element == String {
    func bump() -> [String] {
        self.map { $0.bump() }
    }
}

struct CaveMap {
    let x: Int
    let y: Int
    var values: [Int] // values.count = x * y

    init(from strings: [String]) {
        let values: [Int] = strings
            .map { Array($0) }
            .flatMap { $0.map { String($0) } } // wowza
            .map { Int($0)! }
        self.init(
            x: strings.first!.count,
            y: strings.count,
            values: values
        )
    }

    init(x: Int, y: Int, values: [Int]) {
        precondition(values.count == x * y)
        self.x = x
        self.y = y
        self.values = values
    }

    func value(x: Int, y: Int) -> Int? {
        return index(x:x, y: y).map { values[$0] }
    }

    func index(x: Int, y: Int) -> Int? {
        if x < 0 || x >= self.x { return nil }
        if y < 0 || y >= self.y { return nil }
        return x + self.x * y
    }
}

Script.main()

