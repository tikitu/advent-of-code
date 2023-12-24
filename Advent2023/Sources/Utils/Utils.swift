import Foundation

public func readLines() -> [String] {
    var lines: [String] = []
    while let line = readLine() {
        lines.append(line)
    }
    return lines
}

// MARK: -- Points

public struct Point: Hashable, Equatable {
    public var row: Int
    public var col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

extension Point {
    public func manhattan(_ other: Point) -> Int {
        abs(other.row - self.row) + abs(other.col - self.col)
    }

    public func rows(to other: Point) -> ClosedRange<Int> {
        min(self.row, other.row)...max(self.row, other.row)
    }

    public func cols(to other: Point) -> ClosedRange<Int> {
        min(self.col, other.col)...max(self.col, other.col)
    }
}

extension Point: Comparable {
    public static func <(lhs: Point, rhs: Point) -> Bool {
        if lhs.row < rhs.row { return true }
        if lhs.row > rhs.row { return false }
        if lhs.col < rhs.col { return true }
        return false
    }
}

extension Point {
    public var west: Point {
        var result = self
        result.col -= 1
        return result
    }
    public var east: Point {
        var result = self
        result.col += 1
        return result
    }
    public var north: Point {
        var result = self
        result.row -= 1
        return result
    }
    public var south: Point {
        var result = self
        result.row += 1
        return result
    }
    public var cardinals: [Point] {
        [north, south, west, east]
    }
}


// MARK: -- Grids

public struct Grid<Cell> {
    public var rows: [[Cell]]
    public init(rows: [[Cell]]) {
        self.rows = rows
    }

    /// Prettify with separators between cells
    public func pretty(separator: String = " ", display: (Cell) -> String = { "\($0)" }) -> String {
        let cells = rows.map {
            $0.map(display)
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
        get {
            guard row >= 0, row < rows.count,
                  col >= 0, col < rows[0].count
            else { return nil }
            return rows[row][col]
        }
        mutating set {
            guard row >= 0, row < rows.count,
                  col >= 0, col < rows[0].count,
                  let newValue
            else { return }
            rows[row][col] = newValue
        }
    }

    public subscript(_ p: Point) -> Cell? {
        get {
            self[row: p.row, col: p.col]
        }
        mutating set {
            self[row: p.row, col: p.col] = newValue
        }
    }

    public subscript(wrapping p: Point) -> Cell {
        get {
            self[row: mod(p.row, rows.count),
                 col: mod(p.col, rows[0].count)]!
        }
        mutating set {
            self[row: mod(p.row, rows.count),
                 col: mod(p.col, rows[0].count)] = newValue
        }
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

    // Apply a convolution (returning the result, can be assigned to self after)
    public func convolve(_ f: (Point) -> Cell) -> Grid {
        var grid = self
        for row in rows.indices {
            for col in rows[0].indices {
                grid.rows[row][col] = f(Point(row: row, col: col))
            }
        }
        return grid
    }

    public mutating func transpose() {
        let cols: [[Cell]] = rows[0].indices.map { col in
            rows.map { $0[col] }
        }
        rows = cols
    }

    public func transposed() -> Self {
        var result = self
        result.transpose()
        return result
    }
}

public struct CharGrid: Equatable, Hashable {
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

    public subscript(_ point: Point) -> Character? {
        get {
            self[row: point.row, col: point.col]
        }
        mutating set {
            self[row: point.row, col: point.col] = newValue
        }
    }

    public subscript(wrapping p: Point) -> Character {
        get {
            self[row: mod(p.row, rows.count),
                 col: mod(p.col, rows[0].count)]!
        }
        mutating set {
            self[row: mod(p.row, rows.count),
                 col: mod(p.col, rows[0].count)] = newValue
        }
    }

    public func points() -> Array<Point> {
        rows.indices.flatMap { row in
            rows[row].indices.map { col in
                Point(row: row, col: col)
            }
        }
    }

    /// Neighbour points _within this grid_
    public func neighbours(of point: Point) -> [Point] {
        [point.north, point.south, point.west, point.east].filter { self[$0] != nil }
    }

    public func points(where predicate: (Character) -> Bool) -> Array<Point> {
        points().filter { predicate(self[$0]!) }
    }

    public func points(where predicate: (Point) ->  Bool) -> Array<Point> {
        points().filter { predicate($0) }
    }

    public mutating func transpose() {
        let cols: [[Character]] = rows[0].indices.map { col in
            rows.map { $0[col] }
        }
        rows = cols
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

    // Apply a convolution (returning the result, can be assigned to self after)
    public func convolve(_ f: (Point) -> Character) -> CharGrid {
        var grid = self
        for row in rows.indices {
            for col in rows[0].indices {
                grid.rows[row][col] = f(Point(row: row, col: col))
            }
        }
        return grid
    }
}

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
