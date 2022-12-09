# My solutions to Advent of Code

Sometimes I solve the puzzles in [Advent of Code](https://adventofcode.com/). When I do they end up here.

## 2022

Language and packaging: [Swift](https://developer.apple.com/swift/), one Swift Package Manager [package](Advent2022/Package.swift) 
with many executable targets.

Reading the code: [`Advent2022/Sources/`](Advent2022/Sources) contains the Swift sources. Most days have a subdirectory containing a single 
`Script.swift` file. The first few days are combined in `Advent2022/Sources/Advent2022/Script.swift` (on the third day I created the template).

Running the code: from the top-level `Advent2022` directory: `cat input | swift run Day04 01` for the first puzzle, `Day04 02` for the second.

I understand the author of Advent of Code prefers us not to share our input files, to make it harder to reverse engineer the site (which 
personalised the puzzle input to some extent). I've tried to avoid committing input files; you can [get them yourself](https://adventofcode.com/2022).

## 2021

Language and packaging: [Swift](https://developer.apple.com/swift/), a Swift Package Manager package with one executable target.

Reading the code: it's all in one giant file: [`Advent2021/Sources/Advent2021/main.swift`](Advent2021/sources/Advent2021/main.swift).

Running the code: from the top-level `Advent2021` directory: `cat input | swift run Advent2021 <subcommand>`. Some days have two subcommands for the
two puzzles, some have only one. Use `swift run Advent2021 --help` to list the subcommands. Some days may not actually produce the answer.
