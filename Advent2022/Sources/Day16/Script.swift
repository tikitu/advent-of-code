import ArgumentParser
import Foundation
import Parsing
import Utils
import DequeModule

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 16",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 16 part 01")
            let input = try readLines().map(parseLine(_:))
            let cave = Dictionary.init(uniqueKeysWithValues: input.map { ($0.id, $0) })

            let initial = State(flowSoFar: 0, minute: 0, room: "AA", openValves: [], path: ["AA"], cave: cave)
            var pending = Deque(arrayLiteral: initial)
            var best: [String: State] = [initial.room: initial]
            while !pending.isEmpty {
                let current = pending.popFirst()!
                for next in current.moves(cave: cave) {
                    if next.minute > 30 { continue }
                    if !best.keys.contains(next.room)
                        || next.flowSoFar > best[next.room]!.flowSoFar
                        // opening a valve gives delayed value, but it's *always* worth exploring
                        || (next.flowSoFar == best[next.room]!.flowSoFar && next.path.last == "*")
                    {
                        best[next.room] = next
                        pending.append(next)
                    }
                }
            }
            print("")
            let winner = best.values.max(by: { $0.flowSoFar <= $1.flowSoFar })!
            print(winner)
            print(winner.value)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 16 part 02")
            // let input = readLines()
        }
    }
}

struct State {
    var flowSoFar: Int
    var minute: Int // 0 to 30
    var room: String
    var openValves: Set<String>
    var value: Int
    var path: [String]

    init(flowSoFar: Int, minute: Int, room: String, openValves: Set<String>, path: [String], cave: [String: Room]) {
        self.flowSoFar = flowSoFar
        self.minute = minute
        self.room = room
        self.openValves = openValves
        self.path = path
        let minutesToGo = 30 - minute
        let flowRate = cave.flowRate(rooms: openValves)
        self.value = flowSoFar + minutesToGo * flowRate
    }

    func moves(cave: [String: Room]) -> [State] {
        // go to another room
        var result: [State] = cave[room]!.tunnels.map { next in
            State(
                flowSoFar: self.flowSoFar + cave.flowRate(rooms: openValves),
                minute: self.minute + 1,
                room: next,
                openValves: self.openValves,
                path: self.path + [next],
                cave: cave)
        }
        // open a valve (no point if the flow rate is zero)
        if !openValves.contains(room) && cave[room]!.flowRate > 0 {
            result.append(
                State(
                    flowSoFar: self.flowSoFar + cave.flowRate(rooms: openValves),
                    minute: self.minute + 1,
                    room: self.room,
                    openValves: self.openValves.union([self.room]),
                    path: self.path + ["*"],
                    cave: cave)
            )
        }
        return result
    }
}

extension Dictionary where Key == String, Value == Room {
    func flowRate(rooms: some Collection<String>) -> Int {
        rooms.map { self[$0]?.flowRate ?? 0 }.reduce(0, +)
    }
}

struct Room {
    let id: String
    let flowRate: Int
    let tunnels: [String]
}

func parseLine(_ line: String) throws -> Room {
    let parser = Parse(Room.init(id:flowRate:tunnels:)) {
        Parse {
            "Valve "
            PrefixUpTo(" ").map(String.init)
            " has flow rate="
        }
        Int.parser()
        Parse {
            "; tunnel"
            Skip { Optionally { "s" } }
            " lead"
            Skip { Optionally { "s" } }
            " to valve"
            Skip { Optionally { "s" } }
        }
        " "
        Many {
            CharacterSet.uppercaseLetters.map(String.init)
        } separator: {
            ", "
        } terminator: {
            End()
        }
    }
    return try parser.parse(line)
}
