import ArgumentParser

struct Script: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Run Advent of Code 2021 programs",
        version: "0.0.1",
        subcommands: [Day1.self]
    )
}

extension Script {
    struct Day1: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "1"
        )
    }

    func run() {
        print("not yet")
    }
}

Script.main()
