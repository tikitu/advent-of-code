// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let allDependencies: [Target.Dependency] = [
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
    .product(name: "Collections", package: "swift-collections"),
    .product(name: "Algorithms", package: "swift-algorithms"),
    .product(name: "Parsing", package: "swift-parsing"),
    .target(name: "Utils")
]
let package = Package(
    name: "Advent2022",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "Utils", targets: ["Utils"]),
        .executable(name: "Advent2022", targets: ["Advent2022"]),
        .executable(name: "Day03", targets: ["Day03"]),
        .executable(name: "Day04", targets: ["Day04"]),
        .executable(name: "Day05", targets: ["Day05"]),
        .executable(name: "Day06", targets: ["Day06"]),
        .executable(name: "Day07", targets: ["Day07"]),
        .executable(name: "Day08", targets: ["Day08"]),
        .executable(name: "Day09", targets: ["Day09"]),
        .executable(name: "Day10", targets: ["Day10"]),
        .executable(name: "Day11", targets: ["Day11"]),
        .executable(name: "Day12", targets: ["Day12"]),
        .executable(name: "Day13", targets: ["Day13"]),
        .executable(name: "Day14", targets: ["Day14"]),
        .executable(name: "Day15", targets: ["Day15"]),
        .executable(name: "Day16", targets: ["Day16"]),
        .executable(name: "Day17", targets: ["Day17"]),
        .executable(name: "Day18", targets: ["Day18"]),
        .executable(name: "Day19", targets: ["Day19"]),
        .executable(name: "Day20", targets: ["Day20"]),
        .executable(name: "Day21", targets: ["Day21"]),
        .executable(name: "Day22", targets: ["Day22"]),
        .executable(name: "Day23", targets: ["Day23"]),
        .executable(name: "Day24", targets: ["Day24"]),
        .executable(name: "Day25", targets: ["Day25"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Utils"),
        .executableTarget(name: "Advent2022", dependencies: allDependencies),
        .executableTarget(name: "Day03", dependencies: allDependencies),
        .executableTarget(name: "Day04", dependencies: allDependencies),
        .executableTarget(name: "Day05", dependencies: allDependencies),
        .executableTarget(name: "Day06", dependencies: allDependencies),
        .executableTarget(name: "Day07", dependencies: allDependencies),
        .executableTarget(name: "Day08", dependencies: allDependencies),
        .executableTarget(name: "Day09", dependencies: allDependencies),
        .executableTarget(name: "Day10", dependencies: allDependencies),
        .executableTarget(name: "Day11", dependencies: allDependencies),
        .executableTarget(name: "Day12", dependencies: allDependencies),
        .executableTarget(name: "Day13", dependencies: allDependencies),
        .executableTarget(name: "Day14", dependencies: allDependencies),
        .executableTarget(name: "Day15", dependencies: allDependencies),
        .executableTarget(name: "Day16", dependencies: allDependencies),
        .executableTarget(name: "Day17", dependencies: allDependencies),
        .executableTarget(name: "Day18", dependencies: allDependencies),
        .executableTarget(name: "Day19", dependencies: allDependencies),
        .executableTarget(name: "Day20", dependencies: allDependencies),
        .executableTarget(name: "Day21", dependencies: allDependencies),
        .executableTarget(name: "Day22", dependencies: allDependencies),
        .executableTarget(name: "Day23", dependencies: allDependencies),
        .executableTarget(name: "Day24", dependencies: allDependencies),
        .executableTarget(name: "Day25", dependencies: allDependencies),
    ]
)
