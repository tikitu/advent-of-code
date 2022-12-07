import ArgumentParser
import Parsing
import Utils

@main
struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2022 Day 7",
        version: "0.0.1",
        subcommands: [Part1.self, Part2.self]
    )

    enum Command: Equatable{
        case ls
        case cd(Substring)
    }
    enum File: Equatable, Hashable {
        case file(Int, Substring)
        case dir(Substring)

        var size: Int {
            switch self {
            case .file(let size, _): return size
            case .dir(_): return 0
            }
        }
    }
    enum Line: Equatable {
        case command(Command)
        case file(File)
    }

    class Tree {
        let node: File
        var children: [Substring: Tree]
        var values: Set<File>
        init(node: File) {
            self.node = node
            self.children = [:]
            self.values = []
        }

        var size: Int {
            let subdirs = children.values.map(\.size).reduce(0, +)
            let files = values.map(\.size).reduce(0, +)
            return subdirs + files
        }

        func visit<Result>(_ f: (Tree) -> Result) -> [Result] {
            var result = children.values.flatMap { $0.visit(f) }
            result.append(f(self))
            return result
        }
    }

    static func parse(input: [String]) throws -> [Line] {
        let cd = Parse {
            "cd "
            Rest()
        }.map(Command.cd)
        let ls = Parse { "ls" }.map { Command.ls }
        let command = Parse {
            "$ "
            OneOf {
                cd
                ls
            }
        }

        let dir = Parse {
            "dir "
            Rest()
        }.map(File.dir)
        let file = Parse {
            Digits()
            " "
            Rest()
        }.map(File.file)
        let lsLine = Parse {
            OneOf {
                dir
                file
            }
        }

        let parser = Parse {
            OneOf {
                command.map(Line.command)
                lsLine.map(Line.file)
            }
        }
        return try input.map { try parser.parse($0[...]) }
    }

    static func makeTree(input: [String]) throws -> Tree {
        let lines = try Script.parse(input: input)

        let root = Tree(node: .dir("/"))
        var dirs = [root]
        var cwd: Tree { dirs.last! }
        for line in lines {
            switch line {
            case .command(.cd("/")):
                dirs = [root]
            case .command(.cd("..")):
                _ = dirs.popLast()
            case .command(.cd(let dir)):
                if !cwd.children.keys.contains(dir) {
                    cwd.children[dir] = Tree(node: .dir(dir))
                }
                dirs.append(cwd.children[dir]!)
            case .command(.ls):
                continue
            case .file(.dir(let dir)):
                if !cwd.children.keys.contains(dir) {
                    cwd.children[dir] = Tree(node: .dir(dir))
                }
            case .file(let file):
                cwd.values.insert(file)
            }
        }
        return root
    }

    struct Part1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "01")

        func run() throws {
            let input = readLines()
            let root = try Script.makeTree(input: input)

            let result = root.visit { $0.size }.filter { $0 <= 100000 }.reduce(0, +)
            print(result)
        }
    }

    struct Part2: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "02")

        func run() throws {
            print("day 07 part 02")
            let input = readLines()
            let root = try Script.makeTree(input: input)

            let total = 70000000
            let used = root.size
            let currentFree = total - used
            let minimumDelete = 30000000 - currentFree

            let sizes = root.visit { $0.size }
            let result = sizes.filter { $0 >= minimumDelete }.min()!
            print(result)
        }
    }
}
