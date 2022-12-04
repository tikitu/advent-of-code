import Foundation

public func readLines() -> [String] {
    var lines: [String] = []
    while let line = readLine() {
        lines.append(line)
    }
    return lines
}

public extension ClosedRange where Bound: Comparable {
    func includes(_ other: ClosedRange) -> Bool {
        return contains(other.lowerBound) && contains(other.upperBound)
    }
}
