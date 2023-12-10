import Foundation

public func readLines() -> [String] {
    var lines: [String] = []
    while let line = readLine() {
        lines.append(line)
    }
    return lines
}

public struct Grid<Cell> {
    var rows: [[Cell]]

    /// Prettify with separators between cells
    public func pretty(separator: String = " ") -> String {
        let cells = rows.map {
            $0.map {
                "\($0)"
            }
        }
        let maxWidth = cells.map { $0.map { $0.count }.max()! }.max()!
        return cells.map {
            $0.map {
                var cell = "\($0)"
                if cell.count < maxWidth {
                    cell += String(repeating: " ", count: maxWidth - cell.count)
                }
                return cell
            }.joined(separator: separator)
        }.joined(separator: "\n")
    }

    /// Edge-safe cell lookup
    public subscript(row row: Int, col col: Int) -> Cell? {
        guard row >= 0, row < rows.count,
              col >= 0, col < rows[0].count
        else { return nil }
        return rows[row][col]
    }

    // Apply a convolution (returning the result, can be assigned to self after)
    public func convolve(_ f: (Int, Int) -> Cell) -> Grid {
        var grid = self
        for row in rows.indices {
            for col in rows[0].indices {
                grid.rows[row][col] = f(row, col)
            }
        }
        return grid
    }
}

public struct CharGrid {
    public var rows: [[Character]]
    public init(lines: [String]) {
        rows = lines.map { $0.map { $0} }
    }

    /// Stringify as compact as possible
    public var pretty: String {
        rows.map {
            String($0)
        }.joined(separator: "\n")
    }

    /// Edge-safe cell lookup
    public subscript(row row: Int, col col: Int) -> Character? {
        get {
            guard row >= 0, row < rows.count,
                  col >= 0, col < rows[0].count
            else { return nil }
            return rows[row][col]
        }
        set {
            guard row >= 0, row < rows.count,
                  col >= 0, col < rows[0].count
            else { return }
            rows[row][col] = newValue!
        }
    }

    /// Edge-safe neighbour set of a cell (not including the cell itself)
    public func neighbours(row: Int, col: Int) -> [Character] {
        [-1, 0, 1].map { dX in
            [-1, 0, 1].map { dY in
                guard dX != 0 || dY != 0 else { return nil }
                return self[row: row + dX, col: col + dY]
            }.compactMap { $0 }
        }.flatMap { $0 }
    }

    /// Replace all non-matching cells, leave matching cells alone
    public mutating func filter(replacement: Character = ".", _ predicate: (Character) -> Bool) {
        rows = rows.map {
            $0.map {
                if predicate($0) { $0 } else { replacement }
            }
        }
    }

    /// Print this grid highlighting non-default cells that are also in the other grid
    public func diff(_ other: CharGrid, showSame: Bool = true) -> String {
        guard rows.count == other.rows.count,
              rows[0].count == other.rows[0].count
        else { fatalError() }
        return rows.indices.map { row in
            rows[row].indices.map { col in
                let cell = rows[row][col]
                if cell == "." {
                    return String(cell)
                }
                if showSame == (rows[row][col] == other.rows[row][col]) {
                    return "\u{1b}[31;1;4m\(cell)\u{1b}[0m"
                } else {
                    return String(cell)
                }
            }.joined(separator: "")
        }.joined(separator: "\n")
    }

    // Apply a convolution (returning the result, can be assigned to self after)
    public func convolve(_ f: (Int, Int) -> Character) -> CharGrid {
        var grid = self
        for row in rows.indices {
            for col in rows[0].indices {
                grid.rows[row][col] = f(row, col)
            }
        }
        return grid
    }
}
