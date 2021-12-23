import ArgumentParser
import Collections
import Darwin

struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2021 programs",
        version: "0.0.1",
        subcommands: [Day1_1.self, Day1_2.self, Day2_1.self, Day2_2.self,
                      Day3_1.self, Day3_2.self, Day4_1.self, Day4_2.self,
                      Day5_1.self, Day5_2.self, Day6_1.self, Day7_1.self,
                      Day8_1.self, Day8_2.self, Day9_1.self, Day10.self,
                      Day11.self, Day12.self, Day13.self, Day14.self, Day15.self,
                      Day16.self, Day17.self, Day18.self, Day19.self, Day20.self,
                      Day21_1.self, Day21_2.self, Day22_1.self, Day22_2.self,
                      Day23.self]
    )
}

extension Script {
    struct Day23: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "23")

        func run() {
            let input = """
            #############
            #...........#
            ###B#D#C#A###
              #C#D#B#A#
              #########
            """
            let _ = """
            #############
            #...........#
            ###B#C#B#D###
              #A#D#C#A#
              #########
            """

            let states = [
                """
        #############
        #...........#
        ###B#C#B#D###
          #A#D#C#A#
          #########
        """,
                """
        #############
        #...B.......#
        ###B#C#.#D###
          #A#D#C#A#
          #########
        """,
                """
        #############
        #...B.......#
        ###B#.#C#D###
          #A#D#C#A#
          #########
        """,
                """
        #############
        #...B.D.....#
        ###B#.#C#D###
          #A#.#C#A#
          #########
        """,
                """
        #############
        #.....D.....#
        ###B#.#C#D###
          #A#B#C#A#
          #########
        """,
                """
        #############
        #.....D.....#
        ###.#B#C#D###
          #A#B#C#A#
          #########
        """,
                """
        #############
        #.....D.D.A.#
        ###.#B#C#.###
          #A#B#C#.#
          #########
        """,
                """
        #############
        #.........A.#
        ###.#B#C#D###
          #A#B#C#D#
          #########
        """,
                """
        #############
        #...........#
        ###A#B#C#D###
          #A#B#C#D#
          #########
        """
            ].map { AmphipodState(from: $0) }

            let broken = AmphipodState(from: """
        #############
        #...B.......#
        ###B#.#C#D###
          #A#D#C#A#
          #########
        """)
            print(broken)
            print()
            broken.moves().map { $0.state }.prettyPrint()
            print()
            print(broken.corridors(of: .d, from: 1))

            var queue = Heap<AmphipodMove>([AmphipodMove(state: AmphipodState(from: input), cost: 0)])
            var costs = [AmphipodState: Int]()
            var solutions = [AmphipodState: AmphipodState]()

            while let next = queue.popMin() {
//                if Set(states).contains(next.state) {
//                    solutions.chain(from: next.state).prettyPrint()
//                    print()
//                }
                if (queue.count % 100 == 0) {
                    print("progress: \(queue.count) / \(costs.count)")
                }
                if next.state.allHome {
                    print(next.state)
                    print(next.cost)
                    break
                }
                next.state.moves().forEach { move in
                    var move = move
                    move.cost += next.cost
                    if costs[move.state, default: Int.max] > move.cost {
                        costs[move.state] = move.cost
                        solutions[move.state] = next.state
                        queue.insert(move)
                    }
                }
            }
//            for step in solutions.chain(from: AmphipodState(houses: [[.a, .a], [.b, .b], [.c, .c], [.d, .d]])) {
//                print(step)
//                print(costs[step])
//                print()
//            }

            print("DONE!")
        }
    }
}

extension Dictionary where Key == AmphipodState, Value == AmphipodState {
    func chain(from state: AmphipodState?) -> [AmphipodState] {
        if let state = state {
            var tail = chain(from: self[state])
            tail.insert(state, at: 0)
            return tail
        } else {
            return []
        }
    }
}

extension Array where Element == AmphipodState {
    func prettyPrint() {
        let pretty = self
            .map { $0.description }
            .map { $0.split(separator: "\n") }
        print([
            pretty.map { $0[0] }.joined(separator: "  "),
            pretty.map { $0[1] }.joined(separator: "  "),
            pretty.map { $0[2] }.joined(separator: "  "),
            pretty.map { $0[3] }.joined(separator: "  "),
            pretty.map { $0[4] }.joined(separator: "  ")
        ].joined(separator: "\n"))
    }
}

struct AmphipodMove: Equatable, Hashable, Comparable, CustomStringConvertible {
    var state: AmphipodState
    var cost: Int

    static func < (lhs: AmphipodMove, rhs: AmphipodMove) -> Bool {
        if lhs.cost < rhs.cost { return true }
        if lhs.cost > rhs.cost { return false }
        return lhs.state < rhs.state
    }

    var description: String {
        """
        cost: \(cost)
        \(state)
        """
    }
}

struct AmphipodState: Equatable, Hashable, CustomStringConvertible {
    var corridor = Array<Amphipod?>(repeating: nil, count: 11)
    var houses: [[Amphipod?]]

    var description: String {
        """
        #############
        #\(corridor.map { $0?.description ?? "." }.joined())#
        ###\(houses[0][0]?.description ?? ".")#\(houses[1][0]?.description ?? ".")#\(houses[2][0]?.description ?? ".")#\(houses[3][0]?.description ?? ".")###
        ###\(houses[0][1]?.description ?? ".")#\(houses[1][1]?.description ?? ".")#\(houses[2][1]?.description ?? ".")#\(houses[3][1]?.description ?? ".")###
        #############
        """
    }

    var allHome: Bool {
        houses == [[.a, .a], [.b, .b], [.c, .c], [.d, .d]]
    }

    func moves() -> Set<AmphipodMove> {
        var result = Set<AmphipodMove>()
        // move an amphipod from a house into the corridor
        for (i, house) in houses.enumerated() {
            let owner = Amphipod.allCases[i]
            // only the topmost can move
            switch house.compactMap({ $0 }).first {
            case nil: // nobody to move, we're done
                continue
            case let amphipod? where amphipod == owner:
                // only move if it's the topmost and there's someone trapped underneath
                guard house[0] != nil && house[1] != nil && house[1] != owner else { continue }
                fallthrough
            case let amphipod?:
                var next = AmphipodMove(state: self, cost: 0)
                let nextHouse = house[0] == nil ? [nil, nil] : [nil, house[1]]
                next.state.houses[i] = nextHouse
                let corridors = self.corridors(of: amphipod, from: i)
                for (corridor, cost) in corridors {
                    next.state.corridor = corridor
                    next.cost = cost
                    if house[0] == nil { next.cost += amphipod.cost(of: 1) } // moving from the bottom
                    result.insert(next)
                }
            }
        }
        // move an amphipod from the corridor into their house
        for (loc, amphipod) in corridor.enumerated() {
            guard let amphipod = amphipod else { continue }
            let house: Int
            switch amphipod {
            case .a: house = 0
            case .b: house = 1
            case .c: house = 2
            case .d: house = 3
            }
            // moving into the house must not block anyone else
            guard houses[house].allSatisfy({ $0 == nil || $0 == amphipod }) else { continue }
            let houseLoc = [2, 4, 6, 8][house]
            let pathway = corridor[min(loc, houseLoc)...max(loc, houseLoc)]
            // the way to the door must be unblocked (this amphipod is the only one)
            guard pathway.compactMap({$0}).count == 1 else { continue }
            var next = AmphipodMove(state: self, cost: amphipod.cost(of: pathway))
            next.state.corridor[loc] = nil
            if houses[house][1] == nil {
                next.cost += amphipod.cost(of: 1) // going to the bottom
            }
            next.state.put(amphipod: amphipod, in: house)
            result.insert(next)
        }
        return result
    }

    /// Convenience only. You must check if you may and should do this!!!
    mutating func put(amphipod: Amphipod, in house: Int) {
        if houses[house][1] == nil {
            houses[house][1] = amphipod
        } else {
            houses[house][0] = amphipod
        }
    }

    func corridors(of amphipod: Amphipod, from house: Int) -> [([Amphipod?], Int)] {
        let houseLoc = [2, 4, 6, 8][house]
        let possibles = [0, 1, 3, 5, 7, 9, 10] // locations that can be moved to
        return possibles.compactMap { loc in
            let pathway = corridor[min(loc, houseLoc)...max(loc, houseLoc)]
            if pathway.compactMap({ $0 }).isEmpty {
                var next = corridor
                next[loc] = amphipod
                return (next, amphipod.cost(of: pathway))
            } else {
                return nil
            }
        }
    }
}

extension AmphipodState {
    init(from string: String) {
        let lines = string.split(separator: "\n").map { String($0) }
        self.corridor = lines[1].chars[1...11].map { Amphipod($0) }
        self.houses = [
            [Amphipod(lines[2].chars[3]), Amphipod(lines[3].chars[3])],
            [Amphipod(lines[2].chars[5]), Amphipod(lines[3].chars[5])],
            [Amphipod(lines[2].chars[7]), Amphipod(lines[3].chars[7])],
            [Amphipod(lines[2].chars[9]), Amphipod(lines[3].chars[9])]
        ]
    }
}

extension String {
    var chars: [Character] {
        self.reduce(into: []) { $0.append($1) }
    }
}

extension AmphipodState: Comparable {
    static func < (lhs: AmphipodState, rhs: AmphipodState) -> Bool {
        lhs.hashValue < rhs.hashValue
    }
}

public enum Amphipod: String, Equatable, Hashable, CaseIterable { case a,b,c,d }
extension Amphipod {
    init?(_ character: Character) {
        switch character {
        case "A": self = .a
        case "B": self = .b
        case "C": self = .c
        case "D": self = .d
        default: return nil
        }
    }
}
extension Amphipod: Comparable {
    public static func < (lhs: Amphipod, rhs: Amphipod) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
extension Amphipod: CustomStringConvertible {
    public var description: String { self.rawValue }
}

extension Amphipod {
    func cost(of pathway: ArraySlice<Amphipod?>) -> Int {
        cost(of: pathway.count)
    }

    func cost(of steps: Int) -> Int {
        switch self {
        case .a: return steps
        case .b: return steps * 10
        case .c: return steps * 100
        case .d: return steps * 1000
        }
    }
}

extension Script {
    struct Day22_2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "22_2")

        func run() {
            let c1 = Instruction22(from: "on x=10..12,y=10..12,z=10..12").cuboid
            let c2 = Instruction22(from: "on x=11..13,y=11..13,z=11..13").cuboid
            print(c1)
            print(c2)
            print(c2.subtracting(c1))
            print(c2.subtracting(c1).map { $0.count }.reduce(0, +))

            let input = readLines().map(Instruction22.init(from:))
            var reactor = Reactor(on: [])
            for (i, instruction) in input.enumerated() {
                switch instruction.on {
                case true:
                    reactor.turn(on: instruction.cuboid)
                case false:
                    reactor.turn(off: instruction.cuboid)
                }
                print("\(i): \(reactor.on.count) / \(reactor.count)")
            }
            print("===done===")
            print("\(reactor.on.count) / \(reactor.count)")
        }
    }

    struct Day22_1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "22_1")

        func run() {
            let input = readLines().map(Instruction22.init(from:))

            let overlaps = input.filter {
                (-50...50).overlaps($0.cuboid.x) ||
                (-50...50).overlaps($0.cuboid.y) ||
                (-50...50).overlaps($0.cuboid.z)
            }.reversed()
            var on = 0
            for x in (-50...50) {
                for y in (-50...50) {
                    for z in (-50...50) {
                        if let latest = overlaps.first(
                            where: {
                                $0.cuboid.x.contains(x)
                                && $0.cuboid.y.contains(y)
                                && $0.cuboid.z.contains(z)
                            }),
                           latest.on {
                            on += 1
                        }
                    }
                }
            }
            print(on)
        }
    }
}

struct Reactor {
    var on: Set<Cuboid> // invariant: they do not overlap
    var count: Int { on.map(\.count).reduce(0, +) }

    mutating func turn(on newOn: Cuboid) {
        self.on = on.reduce(into: [newOn]) { result, oldOn in
            result.formUnion(oldOn.subtracting(newOn))
        }
    }

    mutating func turn(off newOff: Cuboid) {
        self.on = on.reduce(into: []) { result, oldOn in
            result.formUnion(oldOn.subtracting(newOff))
        }
    }
}


struct Cuboid: Equatable, Hashable {
    let x: ClosedRange<Int>
    let y: ClosedRange<Int>
    let z: ClosedRange<Int>

    var count: Int {
        x.count * y.count * z.count
    }

    func overlaps(_ other: Cuboid) -> Bool {
        return x.overlaps(other.x) && y.overlaps(other.y) && z.overlaps(other.z)
    }

    /**
     * Return a set of non-overlapping cuboids collectively covering all cubes in `self` that are not in `other`.
     */
    func subtracting(_ other: Cuboid) -> Set<Cuboid> {
        guard self.overlaps(other) else { return [self] }
        return self.union(with: other).filter { !$0.overlaps(other) }
    }

    func union(with other: Cuboid) -> Set<Cuboid> {
        guard self.overlaps(other) else { return [self, other] }
        let xs = x.union(with: other.x)
        let ys = y.union(with: other.y)
        let zs = z.union(with: other.z)
        return Set(
            xs.flatMap { x in
                ys.flatMap { y in
                    zs.map { z in
                        Cuboid(x: x, y: y, z: z)
                    }
                }
            }
                .filter { $0.overlaps(self) || $0.overlaps(other) }
        )
    }
}

extension ClosedRange where Element == Int {
    /**
     * Return a list of ranges that cover all elements in `self` that do not appear in `other`. Can be empty!
     */
    func subtracting(_ other: ClosedRange<Int>) -> [ClosedRange<Int>] {
        guard !self.overlaps(other) else { return [self] }
        return union(with: other).filter { !$0.overlaps(other) }
    }

    func union(with other: ClosedRange<Int>) -> [ClosedRange<Int>] {
        precondition(self.overlaps(other))
        let (one, two) = self.lowerBound < other.lowerBound ? (self, other) : (other, self)
        var result = [ClosedRange<Int>]()
        if two.lowerBound > one.lowerBound {
            result.append((one.lowerBound...two.lowerBound - 1))
        }
        result.append(two.lowerBound...Swift.min(one.upperBound, two.upperBound))
        if one.upperBound != two.upperBound {
            result.append((Swift.min(one.upperBound, two.upperBound) + 1...Swift.max(one.upperBound, two.upperBound)))
        }
        return result
    }
}

extension Cuboid: CustomStringConvertible {
    var description: String { "x=\(x),y=\(y),z=\(z)"}
}

struct Instruction22 {
    let cuboid: Cuboid
    let on: Bool

    init(from string: String) {
        on = string.split(separator: " ")[0] == "on"
        let cuboid = string.split(separator: " ")[1]
            .split(separator: ",")
            .map { $0.dropFirst(2) }
            .map { $0.split(separator: ".", omittingEmptySubsequences: true)}
            .map { $0.map { Int($0)! } }
        self.cuboid = Cuboid(
            x: ClosedRange(uncheckedBounds: (cuboid[0].min()!, cuboid[0].max()!)),
            y: ClosedRange(uncheckedBounds: (cuboid[1].min()!, cuboid[1].max()!)),
            z: ClosedRange(uncheckedBounds: (cuboid[2].min()!, cuboid[2].max()!))
        )
    }
}

extension Script {
    struct Day21_2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "21_2")

        func run() {
            var universe: [Game: Int] = [
                Game(score_0: 0, score_1: 0, position_0: 8, position_1: 4): 1
            ]
            var wins_0 = 0
            var wins_1 = 0

            let rolls: [UInt8: Int] = Dictionary(
                // gah, Vector array-init overloads are interfering!!!
                grouping: ([1 as UInt8, 2, 3] as [UInt8]).flatMap { a in
                    [1 as UInt8, 2, 3].flatMap { b in
                        [1 as UInt8, 2, 3].map { c in
                            (a+b+c) as UInt8
                        }
                    }
                },
                by: { $0 })
                .mapValues(\.count)
            print("possible rolls: \(rolls)")

            var rounds = 0
            while !universe.isEmpty {
                print(".", terminator: "")
                rounds += 1
                if rounds >= 10 {
                    print("")
                    rounds = 0
                }
                let snapshot = universe
                universe = [Game: Int]()
                universe.reserveCapacity(snapshot.count)

                for (game, count) in snapshot {
                    for (roll_0, roll_0_count) in rolls {
                        var game_0 = game
                        game_0.applyPlayer0(roll: roll_0)
                        if game_0.score_0 >= 21 {
                            wins_0 += (count * roll_0_count)
                            continue
                        }
                        for (roll_1, roll_1_count) in rolls {
                            var game_1 = game_0
                            game_1.applyPlayer1(roll: roll_1)
                            if game_1.score_1 >= 21 {
                                wins_1 += (count * roll_0_count * roll_1_count)
                                continue
                            }
                            universe[game_1, default: 0] += (count * roll_0_count * roll_1_count)
                        }
                    }
                }
            }
            print("wins 0: \(wins_0)")
            print("wins 1: \(wins_1)")
            print("winner: \(max(wins_0, wins_1))")
        }
    }

    struct Game: Equatable, Hashable {
        var score_0: UInt8
        var score_1: UInt8
        var position_0: UInt8
        var position_1: UInt8

        mutating func applyPlayer0(roll: UInt8) {
            _ = position_0.increment(by: roll, limit: 10)
            score_0 += position_0
        }

        mutating func applyPlayer1(roll: UInt8) {
            _ = position_1.increment(by: roll, limit: 10)
            score_1 += position_1
        }
    }

    struct Day21_1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "21_1")

        func run() {
            let input = [
                "Player 1 starting position: 8",
                "Player 2 starting position: 4"
            ]
            var positions = input.map {
                UInt8($0.split(separator: ":")[1].filter { $0.isNumber })!
            }
            var scores = positions.map { _ in 0 }
            print(positions)

            var count = 0
            var die: UInt8 = 0
        GAME:
            while true {
                for player in (0..<positions.count) {
                    _ = positions[player].increment(by: die.increment(by: 1, limit: 100),
                                                    limit: 10)
                    _ = positions[player].increment(by: die.increment(by: 1, limit: 100),
                                                    limit: 10)
                    _ = positions[player].increment(by: die.increment(by: 1, limit: 100),
                                                    limit: 10)
                    count += 3
                    scores[player] += Int(positions[player])
                    if scores[player] >= 1000 {
                        break GAME
                    }
                }
            }
            print("positions: \(positions)")
            print("scores   : \(scores)")
            print("die rolls: \(count)")

            print("result \(Int(scores.min()!) * count)")
        }
    }
}

extension UInt8 {
    mutating func increment(by value: UInt8, limit: UInt8) -> UInt8 {
        self += value
        while self > limit {
            self -= limit
        }
        return self
    }
}

extension Script {
    struct Day20: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "20")

        func run() {
            let input = readLines()
            let rule = input[0].map { $0 == "#" }
            print(rule.count, " should be 512")

            var image = Life(from: input[2...])
            print(image.on.count)
            image.on.prettyPrint()

            print(image.value(of: [2, 2]))
            print(rule.map { $0 ? "1" : "0" }.joined())


            for i in (1...50) {
                image.iterate(rule: rule)
                print("\(i): \(image.on.count)")
            }
        }
    }
}

struct Life {
    var on = Set<Point>()
    var off = Set<Point>()
    var out = false

    init(from rows: ArraySlice<String>) {
        rows.enumerated().forEach { (y, row) in
            row.enumerated().forEach { (x, char) in
                if char == "#" {
                    on.insert([x, y])
                } else {
                    off.insert([x, y])
                }
            }
        }
    }

    func value(of point: Point) -> Int {
        let result = point.neighbourhood.reduce(into: 0) { result, point in
            result *= 2
            if on.contains(point) { result += 1 }
            else if out && !self.off.contains(point) { result += 1 }
        }
        //print(point, " in ", point.neighbourhood, " = ", result)
        return result
    }

    mutating func iterate(rule: [Bool]) {
        let candidates: Set<Point> = on.union(off).reduce(into: []) { result, point in
            result.formUnion(point.neighbourhood)
        }
        var newOn = Set<Point>()
        var newOff = Set<Point>()
        candidates.forEach {
            if rule[self.value(of: $0)] {
                newOn.insert($0)
            } else {
                newOff.insert($0)
            }
        }
        on = newOn
        off = newOff
        switch out {
        case false:
            out = rule[0]
        case true:
            out = rule[511]
        }
    }

}

extension Set where Element == Point {
    func prettyPrint() {
        let minX = self.map { $0.x }.min()!
        let minY = self.map { $0.y }.min()!
        var x = minX
        var y = minY
        self.sorted().forEach { point in
            while y < point.y {
                print()
                y += 1
                x = minX
            }
            while x < point.x {
                print(".", terminator: "")
                x += 1
            }
            print("#", terminator: "")
            x += 1
        }
        print()
    }
}

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int
}

extension Point: CustomStringConvertible {
    var description: String { "\(x),\(y)" }
}

extension Point: Comparable {
    static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.y < rhs.y { return true }
        if lhs.y > rhs.y { return false }
        return lhs.x < rhs.x
    }
}

extension Point: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Int...) {
        x = elements[0]
        y = elements[1]
    }
}

extension Point {
    var neighbourhood: [Point] {
        [-1, 0, 1].flatMap { dy in // note the inversion!
            [-1, 0, 1].map { dx in
                [self.x + dx, self.y + dy] as Point
            }
        }
    }
//
//    var farNeighbourhood: Set<Point> {
//        Set(
//            [-2, -1, 0, 1, 2].flatMap { x in
//                [-2, -1, 0, 1, 2].map { y in
//                    [self.x + x, self.y + y] as Point
//                }
//            }
//        )
//    }
}

extension Set where Element == Point {
    func value(of point: Point) -> Int {
        let result = point.neighbourhood.reduce(into: 0) { result, point in
            result *= 2
            if self.contains(point) { result += 1 }
        }
        print(point, " in ", point.neighbourhood, " = ", result, terminator: "")
        return result
    }
    func iterate(rule: [Bool]) -> Set<Point> {
        let candidates: Set<Point> = self.reduce(into: []) { result, point in
            result.formUnion(point.neighbourhood)
        }
        return Set(candidates.sorted().filter {
            let result = rule[self.value(of: $0)]
            print(" in: ", result)
            return result
        })
    }
}

extension Script {
    struct Day19: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "19")

        func run() {
            print("=== Day 19 ===")

            var scanners: [Set<Vector>] = []
            var input = readLines()
            while !input.isEmpty {
                _ = input.removeFirst() // "scanner 1"
                var scanner = Set<Vector>()
                while !input.isEmpty && !input[0].isEmpty {
                    scanner.insert(Vector(from: input.removeFirst()))
                }
                if !input.isEmpty {
                    input.removeFirst() // empty line
                }
                scanners.append(scanner)
            }
            print(scanners)

            let orientations = Matrix.orientations()
            print("orientations: \(orientations.count)")

            // for s_1 in scanners {
            //   for s_2 in scanners.rest {
            //       for orientation in s_2.oriented {
            //         for beacon_1 in s_1 {
            //           for beacon_2 in s_2 {
            //             assume s_2 sees beacon_1 as beacon_2
            //             does s_2 translated and oriented overlap with s_1 by 12 beacons?
            //             does s_2 translated and oriented anti-overlap with s_1 by any beacons?
            //             if (yes,no): write orientation+translation as a hope, and exit loops
            //                  (owow that's not good...)
            //         }
            //       }
            //    }
            // }

            print(scanners.map { $0.count })
            var changed = true

            var scannersFinal: Set<Vector> = [[0,0,0]] // we can cheat, they always merge with 0

        SCANNER:
            while scanners.count > 1 && changed {
                changed = false

                let scannersXorientations = scanners.map { scanner in
                    orientations.map { orientation in
                        Set(scanner.map { orientation * $0 })
                    }
                }

            SEARCH:
                for i_1 in (0..<scanners.count) {
                    let scanner_1 = scanners[i_1]
                    for i_2 in (i_1..<scanners.count) {
                        if i_1 == i_2 { continue }
                        print("scanners \(i_1) (\(scanner_1.count)), \(i_2) (\(scanners[i_2].count))")
                        let scannerXorientation = scannersXorientations[i_2]
                        for orientation in (0..<scannerXorientation.count) {
                            let scanner_2 = scannerXorientation[orientation]
                            for beacon_1 in scanner_1 {
                                for beacon_2 in scanner_2 {
                                    let trans_2_to_1 = beacon_1 - beacon_2
                                    let scanner_2_to_1 = Set(scanner_2.map { $0 + trans_2_to_1 })
                                    if scanner_2_to_1.intersection(scanner_1).count < 12 {
                                        continue // not enough overlap
                                    }
                                    //                                if scanner_2_to_1.subtracting(scanner_1).first(where: { $0.within1000 }) != nil {
                                    //                                    continue // scanner 2 sees something scanner 1 should see
                                    //                                }
                                    //                                let trans_1_to_2 = beacon_2 - beacon_1
                                    //                                let scanner_1_to_2 = Set(scanner_1.map { $0 + trans_1_to_2})
                                    //                                if scanner_1_to_2.subtracting(scanner_2).first(where: { $0.within1000 }) != nil {
                                    //                                    continue // scanner 1 sees something scanner 2 should see
                                    //                                }
                                    scanners[i_1].formUnion(scanner_2_to_1)
                                    scanners.remove(at: i_2)
                                    scannersFinal.insert(trans_2_to_1)
                                    changed = true

                                    print("\(i_1) to \(i_2) with orientation \(orientation) and transform \(trans_2_to_1)")
                                    // optimistically! assume this is *the* answer and move on...
                                    break SEARCH
                                }
                            }
                        }
                    }
                }
            }
            print(scanners.first!.count)
            var maxManhattan = 0
            for x in scannersFinal {
                for y in scannersFinal {
                    maxManhattan = max(maxManhattan, x.manhattan(from: y))
                }
            }
            print("max manhattan \(maxManhattan)")
        }
    }
}

struct Vector: Equatable, Hashable, CustomStringConvertible {
    var x: Int
    var y: Int
    var z: Int

    func modify(f: (inout Vector) -> Void) -> Vector {
        var v = self
        f(&v)
        return v
    }
}

extension Vector {
    var within1000: Bool {
        return x >= -1000 && x <= 1000
        && y >= -1000 && y <= 1000
        && z >= -1000 && z <= 1000
    }

    func manhattan(from other: Vector) -> Int {
        abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
    }
}

extension Vector {
    var description: String { "\(x),\(y),\(z)" }

    init(from s: String) {
        let parsed = s.split(separator: ",").map { Int($0)! }
        x = parsed[0]
        y = parsed[1]
        z = parsed[2]
    }
}

extension Vector {
    static func +(_ lhs: Vector, _ rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func -(_ lhs: Vector, _ rhs: Vector) -> Vector {
        Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    static func *(_ lhs: Vector, _ rhs: Vector) -> Int {
        lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }

    static func *(_ lhs: Matrix, _ rhs: Vector) -> Vector {
        Vector(
            x: lhs[row: 0] * rhs,
            y: lhs[row: 1] * rhs,
            z: lhs[row: 2] * rhs)
    }
}

struct Matrix {
    var x: Vector
    var y: Vector
    var z: Vector
}

extension Vector: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Int...) {
        x = elements[0]
        y = elements[1]
        z = elements[2]
    }
}

extension Matrix: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Vector...) {
        x = elements[0]
        y = elements[1]
        z = elements[2]
    }
}

extension Matrix {
    subscript(row i: Int) -> Vector {
        switch i {
        case 0: return x
        case 1: return y
        case 2: return z
        default: preconditionFailure("bad matrix subscript \(i)")
        }
    }

    subscript(col i: Int) -> Vector {
        switch i {
        case 0: return Vector(x: x.x, y: y.x, z: z.x)
        case 1: return Vector(x: x.y, y: y.y, z: z.y)
        case 2: return Vector(x: x.z, y: y.z, z: z.z)
        default: preconditionFailure("bad matrix subscript \(i)")
        }
    }

    static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        Matrix(
            x: Vector(x: lhs[row: 0] * rhs[col: 0], y: lhs[row: 0] * rhs[col: 1], z: lhs[row: 0] * rhs[col: 2]),
            y: Vector(x: lhs[row: 1] * rhs[col: 0], y: lhs[row: 1] * rhs[col: 1], z: lhs[row: 1] * rhs[col: 2]),
            z: Vector(x: lhs[row: 2] * rhs[col: 0], y: lhs[row: 2] * rhs[col: 1], z: lhs[row: 2] * rhs[col: 2])
        )
    }
}

extension Matrix {
    static func orientations() -> [Matrix] {
        var result = [Matrix]()
        for a: Matrix in [
            [[1, 0, 0],
             [0, 1, 0],
             [0, 0, 1]],

            [[0, 1, 0],
             [0, 0, 1],
             [1, 0, 0]],

            [[0, 0, 1],
             [1, 0, 0],
             [0, 1, 0]]] {
            for b: Matrix in [
                [[ 1, 0, 0],
                  [ 0, 1, 0],
                  [ 0, 0, 1]],

                 [[-1, 0, 0],
                  [ 0,-1, 0],
                  [ 0, 0, 1]],

                 [[-1, 0, 0],
                  [ 0, 1, 0],
                  [ 0, 0,-1]],

                 [[ 1, 0, 0],
                  [ 0,-1, 0],
                  [ 0, 0,-1]]
            ] {
                for c: Matrix in [
                    [[ 1, 0, 0],
                      [ 0, 1, 0],
                      [ 0, 0, 1]],

                     [[ 0, 0,-1],
                      [ 0,-1, 0],
                      [-1, 0, 0]]
                ] {
                    result.append(a * b * c)
                }
            }
        }
        return result
    }
}

extension Script {
    struct Day18: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "18")

        func run() {
            for s: SNum in [
                [7,[6,[5,[4,[3,2]]]]],
                [[6,[5,[4,[3,2]]]],1],
                [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]],
                [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
            ] {
                var exploded = s
                _ = exploded.explode(nested: 0)
                print("\(s.pretty) --> \(exploded.pretty)")
            }

            let input: [SNum] = [
                [[1,[8,[5,8]]],[[4,4],[8,[8,8]]]],
                [[[3,[2,3]],[[8,0],2]],[0,[[8,1],[7,0]]]],
                [4,[[0,3],[[6,6],[3,8]]]],
                [[[7,[6,4]],[[0,6],[2,0]]],[[[5,6],[0,4]],[[8,1],[9,1]]]],
                [[[6,3],[[6,9],4]],[[1,[4,2]],[[0,0],1]]],
                [[2,0],[3,[0,8]]],
                [[0,[5,5]],[[4,2],[3,[6,4]]]],
                [[[[9,9],[8,5]],[7,4]],[[6,9],[8,[0,8]]]],
                [[[[7,1],[2,9]],[[9,3],0]],[3,[[0,6],[7,6]]]],
                [[[[3,7],[7,1]],[[5,8],[0,1]]],3],
                [[[[4,6],[6,2]],[[9,1],7]],[[9,1],[8,0]]],
                [[[[2,7],0],[[9,4],[2,6]]],[0,[[7,4],[0,3]]]],
                [[5,[[0,2],[8,8]]],[[[4,1],9],3]],
                [[[7,1],[[3,7],[3,4]]],[[[0,7],[1,6]],1]],
                [[[6,5],[[1,8],[8,8]]],[[4,5],[3,7]]],
                [[[1,[3,3]],[[3,2],[5,7]]],[[8,[9,3]],[[5,3],4]]],
                [[[4,[2,7]],9],[9,[[5,6],4]]],
                [[[9,1],3],[[1,2],9]],
                [[[[0,0],[2,3]],[[7,8],[1,5]]],[[[8,6],7],[[8,3],9]]],
                [6,[[5,[0,8]],1]],
                [4,[[[3,0],[2,0]],[[7,2],[1,4]]]],
                [[[[4,3],[4,1]],8],[[[9,4],[1,9]],[4,[0,6]]]],
                [4,[5,6]],
                [[[0,[6,1]],[[6,1],3]],[[0,[7,8]],[1,0]]],
                [[5,[[8,7],8]],8],
                [[5,[[5,2],0]],[[1,[4,7]],[[0,9],[2,3]]]],
                [[7,[2,2]],[[6,3],[5,8]]],
                [[[0,9],5],[1,[[5,7],1]]],
                [[8,[3,[0,3]]],[[[2,2],2],[[8,8],[8,9]]]],
                [[6,[[3,2],[2,6]]],[5,1]],
                [[[[9,8],[6,8]],[0,7]],7],
                [[[7,2],[[6,3],4]],2],
                [[[5,2],[[1,6],[8,3]]],[6,5]],
                [[5,2],[0,5]],
                [[[[4,5],5],[[4,6],[1,2]]],[[[3,6],[4,9]],[1,9]]],
                [[1,[4,1]],[[9,[5,5]],[[9,0],[5,7]]]],
                [[[[8,9],[7,7]],2],[8,1]],
                [[[8,1],[8,[9,5]]],3],
                [[[2,[3,9]],[[5,4],[7,9]]],[9,8]],
                [8,[[2,[0,9]],[[5,0],4]]],
                [[[6,[4,8]],[0,6]],[[8,[1,8]],1]],
                [[6,[[1,0],[6,2]]],[[9,[3,7]],[5,[4,0]]]],
                [[8,[0,[9,1]]],8],
                [7,[4,[7,2]]],
                [[1,[[5,7],[5,4]]],[[5,[8,0]],[1,6]]],
                [[[[0,6],[6,2]],3],[[[9,3],7],[7,[1,2]]]],
                [[[6,[4,9]],8],[6,5]],
                [[[0,[1,9]],[[1,9],[3,9]]],[[[3,4],[7,5]],3]],
                [[[[9,3],5],[[0,5],[2,7]]],9],
                [[[6,[7,5]],5],[1,[[7,0],[3,4]]]],
                [[[2,1],[[1,3],[1,5]]],[4,[9,[7,9]]]],
                [[[[7,9],4],[[8,8],7]],[[[3,5],2],[[4,4],[6,5]]]],
                [[1,1],[1,1]],
                [[8,[0,2]],8],
                [[[2,[2,1]],[[1,7],[1,2]]],[[1,6],5]],
                [6,[0,[[1,0],[0,9]]]],
                [6,[[2,[8,0]],[8,[8,8]]]],
                [4,[[3,[0,3]],4]],
                [[[5,3],3],[[0,[7,6]],[2,[5,8]]]],
                [[[[8,1],[4,1]],[[5,8],[4,8]]],[[[1,7],[7,2]],[0,[2,7]]]],
                [[[2,[3,5]],3],5],
                [[7,[[9,5],[8,2]]],[[[1,8],8],5]],
                [[3,5],[[4,[9,3]],5]],
                [[[[4,6],2],[2,2]],[0,[0,4]]],
                [[[[5,8],[6,6]],[2,0]],[[[2,3],9],[[4,5],2]]],
                [[[[1,9],3],[[3,4],6]],[[3,6],[6,[0,7]]]],
                [[[0,[5,5]],[2,6]],[[[7,4],4],2]],
                [0,[[8,[6,2]],[5,[1,5]]]],
                [[[[5,5],[9,6]],[[5,2],2]],[[4,7],[[5,5],[1,6]]]],
                [[4,7],[[[1,8],[9,6]],[2,3]]],
                [5,[5,4]],
                [[[[2,1],[7,0]],[5,[7,8]]],[6,[3,1]]],
                [[[3,1],[[2,4],6]],[[[1,8],[2,1]],[[1,7],4]]],
                [[[5,[3,3]],6],[[[0,0],9],[1,[7,4]]]],
                [[[6,5],[[7,3],4]],[[9,[0,3]],[3,[6,0]]]],
                [[[3,4],7],[8,[[1,7],[9,9]]]],
                [[[[2,1],6],[2,6]],[[[8,1],[6,2]],[9,0]]],
                [[8,4],[5,2]],
                [[4,[[4,5],9]],[[3,[5,2]],[4,2]]],
                [[[8,8],[[8,0],[5,3]]],4],
                [[1,8],[0,2]],
                [[[[7,2],[9,0]],[[9,2],[1,2]]],[[[4,0],3],0]],
                [[[[1,2],[1,8]],[[4,3],[8,6]]],[[[5,1],8],[8,1]]],
                [[[[5,3],[7,2]],7],[[6,[7,9]],[[3,8],[9,4]]]],
                [[[[3,1],[2,5]],6],[[[3,2],[8,8]],[4,6]]],
                [9,[[3,[2,3]],6]],
                [[[[4,0],[5,6]],[5,4]],[[[9,0],[1,8]],[5,[3,6]]]],
                [[[[9,5],[9,4]],[[5,7],5]],[[[1,4],7],[6,1]]],
                [[2,[6,[8,2]]],[7,[1,[3,3]]]],
                [[[9,1],[0,[6,3]]],[[5,[1,5]],[7,[1,0]]]],
                [1,6],
                [[0,[2,[8,9]]],[[[4,5],[5,4]],1]],
                [[[1,[4,1]],8],[[2,[7,0]],[7,[9,9]]]],
                [[[[5,7],[3,5]],[[6,6],2]],[2,[8,[9,0]]]],
                [6,[[[3,9],8],[[4,3],[6,1]]]],
                [[[[6,7],[7,6]],[2,8]],[[9,[4,1]],6]],
                [[[[4,5],[4,5]],[[0,6],5]],[[[6,5],[7,0]],1]],
                [[[[6,7],9],[[5,5],[6,6]]],[[7,1],[[8,2],[3,1]]]],
                [[[9,6],7],[[[1,8],8],[1,7]]],
                [[5,2],[[1,9],[2,2]]]
            ]
            var accum = input
            var num = accum.removeFirst()
            while !accum.isEmpty {
                num = .pair(num, accum.removeFirst())
                num.reduce()
            }
            print(num.pretty)
            print(num.magnitude)

            var maxMag = 0
            for i in (0..<input.count) {
                for j in (0..<input.count) {
                    if i == j { continue }
                    maxMag = max(maxMag, SNum.pair(input[i], input[j]).reduced.magnitude)
                }
            }
            print(maxMag)
        }
    }

    indirect enum SNum {
        case literal(Int)
        case pair(SNum, SNum)

        var pretty: String {
            switch self {
            case .literal(let v): return "\(v)"
            case .pair(let l, let r): return "[\(l.pretty),\(r.pretty)]"
            }
        }

        var magnitude: Int {
            switch self {
            case .literal(let v): return v
            case .pair(let l, let r): return 3 * l.magnitude + 2 * r.magnitude
            }
        }

        var reduced: Self {
            var s = self
            s.reduce()
            return s
        }

        mutating func reduce() {
            while reduceOnce() { }
        }

        mutating func reduceOnce() -> Bool {
            if self.explode(nested: 0) != nil { return true }
            return split()
        }

        mutating func split() -> Bool {
            switch self {
            case .literal(let v):
                if v >= 10 {
                    let half = v / 2
                    self = .pair(.literal(half), .literal(half + (half * 2 == v ? 0 : 1)))
                    return true
                }
                return false
            case .pair(var l, var r):
                var didSplit = l.split()
                if !didSplit {
                    didSplit = r.split()
                }
                self = .pair(l, r)
                return didSplit
            }
        }

        mutating func explode(nested: Int) -> (Int?, Int?)? {
            switch self {
            case .literal(_): return nil
            case .pair(.literal(let l), .literal(let r)) where nested >= 4:
                // explode!
                self  = .literal(0)
                return (l, r)
            case .pair(var l, var r):
                if let exploded = l.explode(nested: nested + 1) {
                    let rShrapnel = r.rShrapnel(exploded.1)
                    self = .pair(l, r)
                    return (exploded.0, rShrapnel)
                } else if let exploded = r.explode(nested: nested + 1) {
                    let lShrapnel = l.lShrapnel(exploded.0)
                    self = .pair(l, r)
                    return (lShrapnel, exploded.1)
                } else {
                    return nil
                }
            }
        }

        mutating func lShrapnel(_ shrapnel: Int?) -> Int? {
            guard let shrapnel = shrapnel else { return nil }
            switch self {
            case .literal(let v):
                self = .literal(v + shrapnel)
                return nil
            case .pair(var l, var r):
                var shrapnel = r.lShrapnel(shrapnel)
                if shrapnel != nil {
                    shrapnel = l.lShrapnel(shrapnel)
                }
                self = .pair(l, r)
                return shrapnel
            }
        }

        mutating func rShrapnel(_ shrapnel: Int?) -> Int? {
            guard let shrapnel = shrapnel else { return nil }
            switch self {
            case .literal(let v):
                self = .literal(v + shrapnel)
                return nil
            case .pair(var l, var r):
                var shrapnel = l.rShrapnel(shrapnel)
                if shrapnel != nil {
                    shrapnel = r.rShrapnel(shrapnel)
                }
                self = .pair(l, r)
                return shrapnel
            }
        }
    }
}

extension Script.SNum: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int

    init(integerLiteral value: Int) {
        self = .literal(value)
    }
}

extension Script.SNum: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Script.SNum

    init(arrayLiteral elements: Script.SNum...) {
        self = .pair(elements[0], elements[1])
    }
}

extension Script {
    struct Day17: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "17")

        func run() {
            //let target = (x: (20, 30), y:(-10, -5))
            let target = (x: (70, 125), y: (-159, -121))

            let minX = (1...)
                .lazy
                .map { ($0, ($0 * ($0 + 1)) / 2) }
                .first(where: { $0.1 >= target.x.0 })!
                .0
            let maxX = target.x.1

            let xs = (minX...maxX).filter {
                var xV = $0
                var x = 0
                while xV > 0 {
                    if Set(target.x.0...target.x.1).contains(x) {
                        return true
                    }
                    x += xV
                    xV -= 1
                }
                return false
            }
            print(xs, xs.count)

            // free-falling at max velocity from 0 already goes past the target zone
            let ys = (min(target.y.0, target.y.1)...abs(min(target.y.0, target.y.1)))
                .filter {
                    var yV = $0
                    var y = 0
                    while y >= min(target.y.0, target.y.1) {
                        if Set(min(target.y.0, target.y.1)...max(target.y.0, target.y.1)).contains(y) { return true }
                        y += yV
                        yV -= 1
                    }
                    return false
                }

            print(ys.count)

            var candidates = [(Int, (Int, Int))]()

            for xV in xs {
                var steps = 0
                var minSteps = Int.max
                var maxSteps = 0
                var xV = xV
                var x = 0
                while xV > 0 && x <= target.x.1 {
                    x += xV
                    xV -= 1
                    if Set(target.x.0...target.x.1).contains(x) {
                        minSteps = min(minSteps, steps)
                        maxSteps = max(maxSteps, steps)
                    }
                    steps += 1
                }
//                let ys = lazyYs
//                    // free-falling from 0 would already jump past the target zone...
//                    .prefix(while: { $0 <= abs(min(target.y.0, target.y.1)) })
//                    // ... or, more complicated, the possible x-values don't land in target Y
//                    .prefix(while: {
//                        var yV = $0
//                        var y = 0
//                        for _ in (0...maxSteps) {
//                            y += yV
//                            yV -= 1
//                        }
//                        return y >= min(target.y.0, target.y.1)
//                    })
                for startXv in Set(xs) {
                    for startYv in Set(ys) {
                        var x = 0
                        var y = 0
                        var xV = startXv
                        var yV = startYv
                        var maxY = y
                        var hitTarget = false
                        while (x <= max(target.x.0, target.x.1) &&
                               y >= min(target.y.0, target.y.1)) {
                            maxY = max(maxY, y)
                            if (target.x.0...target.x.1).contains(x) && (target.y.0...target.y.1).contains(y) {
                                hitTarget = true
                                break
                            }
                            x += xV
                            y += yV
                            xV = max(0, xV - 1)
                            yV -= 1
                        }
                        if hitTarget {
                            candidates.append((maxY, (startXv, startYv)))
                        }
                    }
                }
            }
            // print(candidates)
            print(candidates.map { $0.0 }.max()!)
            // print(candidates.count)
            print(Set(candidates.map { "\($0.1)" }).count)
        }
    }
}

extension Script {
    struct Day16: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "16")

        func run() {
            let val = "38006F45291200"
            print(val, " = ", val.hexBits.pretty, " version is ", Array(val.hexBits[0..<3]).value)
            var bits = val.hexBits[0...]
            let packet = Packet(parse: &bits)
            print(packet)

            for p in [
                "8A004A801A8002F478",
                "620080001611562C8802118E34",
                "C0015000016115A2E0802F182340",
                "A0016C880162017C3686B18A3D4780",
                "C200B40A82",
                "04005AC33890",
                "880086C3E88112",
                "CE00C43D881120",
                "D8005AC2A8F0",
                "F600BC2D8F",
                "9C005AC2F8F0",
                "9C0141080250320F1802104A08",
                "20546718027401204FE775D747A5AD3C3CCEEB24CC01CA4DFF2593378D645708A56D5BD704CC0110C469BEF2A4929689D1006AF600AC942B0BA0C942B0BA24F9DA8023377E5AC7535084BC6A4020D4C73DB78F005A52BBEEA441255B42995A300AA59C27086618A686E71240005A8C73D4CF0AC40169C739584BE2E40157D0025533770940695FE982486C802DD9DC56F9F07580291C64AAAC402435802E00087C1E8250440010A8C705A3ACA112001AF251B2C9009A92D8EBA6006A0200F4228F50E80010D8A7052280003AD31D658A9231AA34E50FC8010694089F41000C6A73F4EDFB6C9CC3E97AF5C61A10095FE00B80021B13E3D41600042E13C6E8912D4176002BE6B060001F74AE72C7314CEAD3AB14D184DE62EB03880208893C008042C91D8F9801726CEE00BCBDDEE3F18045348F34293E09329B24568014DCADB2DD33AEF66273DA45300567ED827A00B8657B2E42FD3795ECB90BF4C1C0289D0695A6B07F30B93ACB35FBFA6C2A007A01898005CD2801A60058013968048EB010D6803DE000E1C6006B00B9CC028D8008DC401DD9006146005980168009E1801B37E02200C9B0012A998BACB2EC8E3D0FC8262C1009D00008644F8510F0401B825182380803506A12421200CB677011E00AC8C6DA2E918DB454401976802F29AA324A6A8C12B3FD978004EB30076194278BE600C44289B05C8010B8FF1A6239802F3F0FFF7511D0056364B4B18B034BDFB7173004740111007230C5A8B6000874498E30A27BF92B3007A786A51027D7540209A04821279D41AA6B54C15CBB4CC3648E8325B490401CD4DAFE004D932792708F3D4F769E28500BE5AF4949766DC24BB5A2C4DC3FC3B9486A7A0D2008EA7B659A00B4B8ACA8D90056FA00ACBCAA272F2A8A4FB51802929D46A00D58401F8631863700021513219C11200996C01099FBBCE6285106"
            ] {
                let packet = Packet(parse: p)
                print("\(p.prefix(10)): version \(packet.versionSum), value: \(packet.value)")
            }
        }

        enum Packet {
            case literal(version: Int, value: Int)
            case opCode(version: Int, opCode: Int, packets: [Packet])

            init(parse string: String) {
                var bits = string.hexBits[0...]
                self.init(parse: &bits)
            }

            init(parse bits: inout ArraySlice<Bool>) {
                precondition(bits.count > 7, "bad packet [\(bits.pretty)]") // this is a wild underestimate but I'd like to know...
                let version = bits.popFirst(3).value
                let typeID = bits.popFirst(3).value
                if typeID == 4 {
                    var valueBits = [Bool]()
                    var more = true
                    while more {
                        more = bits.removeFirst()
                        valueBits.append(contentsOf: bits.popFirst(4))
                    }
                    self = .literal(
                        version: version,
                        value: valueBits.value)
                } else {
                    let lengthType = bits.removeFirst()
                    switch lengthType {
                    case true: // 11 bits: number of sub-packets
                        let subPacketCount = bits.popFirst(11).value
                        let packets = (0..<subPacketCount).map { _ in
                            Packet(parse: &bits)
                        }
                        self = .opCode(
                            version: version,
                            opCode: typeID, // TODO: sure?
                            packets: packets
                        )
                    case false: // 15 bits: total length of subpackets
                        let subPacketLength = bits.popFirst(15).value
                        var subPackets = bits.popFirst(subPacketLength)
                        var packets: [Packet] = []
                        while !subPackets.isEmpty {
                            packets.append(Packet(parse: &subPackets))
                        }
                        self = .opCode(
                            version: version,
                            opCode: typeID, // TODO: sure?
                            packets: packets
                        )
                    }
                }
            }

            var value: Int {
                switch self {
                case .literal(version: _, value: let v): return v
                case .opCode(version: _, opCode: let opCode, packets: let packets):
                    let subs = packets.map(\.value)
                    switch opCode {
                    case 0:
                        return subs.reduce(0, +)
                    case 1:
                        return subs.reduce(1, *)
                    case 2:
                        return subs.min()!
                    case 3:
                        return subs.max()!
                    case 4:
                        preconditionFailure("literal!")
                    case 5:
                        return subs[0] > subs[1] ? 1 : 0
                    case 6:
                        return subs[0] < subs[1] ? 1 : 0
                    case 7:
                        return subs[0] == subs[1] ? 1 : 0
                    default:
                        preconditionFailure("unexpected opCode \(opCode)")
                    }
                }
            }

            var versionSum: Int {
                switch self {
                case .literal(version: let v, value: _): return v
                case .opCode(version: let v, opCode: _, packets: let packets):
                    return packets.map { $0.versionSum }.reduce(v, +)
                }
            }
        }
    }
}

extension String {
    var hexBits: [Bool] { self.flatMap { $0.hexBits } }
}

extension Array where Element == Bool {
    var pretty: String { self.map({ $0 ? "1" : "0" }).joined() }
    var value: Int {
        var bits = self
        var result = 0
        while !bits.isEmpty {
            result *= 2
            result += bits.removeFirst() ? 1 : 0
        }
        return result
    }
}

extension ArraySlice where Element == Bool {
    var pretty: String { Array(self).pretty }
    var value: Int { Array(self).value }
    mutating func popFirst(_ n: Int) -> ArraySlice<Bool> {
        let result = prefix(n)
        removeFirst(n)
        return result
    }
}

extension Character {
    var hexBits: [Bool] {
        switch self {
        case "0": return [false, false, false, false]
        case "1": return [false, false, false, true]
        case "2": return [false, false, true, false]
        case "3": return [false, false, true, true]
        case "4": return [false, true, false, false]
        case "5": return [false, true, false, true]
        case "6": return [false, true, true, false]
        case "7": return [false, true, true, true]
        case "8": return [true, false, false, false]
        case "9": return [true, false, false, true]
        case "A": return [true, false, true, false]
        case "B": return [true, false, true, true]
        case "C": return [true, true, false, false]
        case "D": return [true, true, false, true]
        case "E": return [true, true, true, false]
        case "F": return [true, true, true, true]
        default: preconditionFailure("hexBits for \(self)")
        }
    }
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

