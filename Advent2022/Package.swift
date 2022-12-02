// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let allDependencies: [Target.Dependency] = [
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
    .product(name: "Collections", package: "swift-collections"),
    .product(name: "Algorithms", package: "swift-algorithms"),
    .product(name: "Parsing", package: "swift-parsing"),
]
let package = Package(
    name: "Advent2022",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Advent2022", targets: ["Advent2022"]),
        .executable(name: "Day03", targets: ["Day03"]),
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
        .executableTarget(name: "Advent2022", dependencies: allDependencies),
        .executableTarget(name: "Day03", dependencies: allDependencies)
    ]
)
