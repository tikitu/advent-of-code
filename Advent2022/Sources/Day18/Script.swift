import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 18",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            print("day 18 part 01")
            let parser = Parse(Cube.init(x:y:z:)) {
                Digits()
                ","
                Digits()
                ","
                Digits()
            }
            let cubes = try Set(readLines().map { try parser.parse($0) })
            var faces = 0
            for cube in cubes {
                for dx in [-1, 1] {
                    if !cubes.contains(Cube(x: cube.x + dx, y: cube.y, z: cube.z)) {
                        faces += 1
                    }
                }
                for dy in [-1, 1] {
                    if !cubes.contains(Cube(x: cube.x, y: cube.y + dy, z: cube.z)) {
                        faces += 1
                    }
                }
                for dz in [-1, 1] {
                    if !cubes.contains(Cube(x: cube.x, y: cube.y, z: cube.z + dz)) {
                        faces += 1
                    }
                }
            }
            print(faces)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 18 part 02")
            // let input = readLines()
        }
    }
}

struct Cube: Hashable {
    let x: Int
    let y: Int
    let z: Int
}
