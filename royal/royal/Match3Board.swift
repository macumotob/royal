struct Match3Board {
    let size: Int
    var tiles: [[Match3Tile]]

    init(size: Int, obstacles: [(GridPosition, Obstacle)] = []) {
        self.size = size
        self.tiles = Array(
            repeating: Array(repeating: Match3Tile(kind: .crown), count: size),
            count: size
        )

        // Place stone obstacles first (they occupy 2x2)
        var stonePositions = Set<GridPosition>()
        for (pos, obstacle) in obstacles {
            if case .stone(let hits, let origin) = obstacle {
                for dr in 0..<2 {
                    for dc in 0..<2 {
                        let r = origin.row + dr
                        let c = origin.column + dc
                        guard r >= 0, r < size, c >= 0, c < size else { continue }
                        let gp = GridPosition(row: r, column: c)
                        stonePositions.insert(gp)
                        tiles[r][c].obstacle = .stone(hits: hits, origin: origin)
                    }
                }
            }
        }

        for row in 0..<size {
            for column in 0..<size {
                let gp = GridPosition(row: row, column: column)
                guard !stonePositions.contains(gp) else { continue }
                tiles[row][column] = Match3Tile(kind: Self.randomKind(avoiding: forbiddenKinds(row: row, column: column)))
            }
        }

        for (pos, obstacle) in obstacles {
            if case .stone = obstacle { continue }
            if pos.row >= 0, pos.row < size, pos.column >= 0, pos.column < size {
                tiles[pos.row][pos.column].obstacle = obstacle
            }
        }
    }

    mutating func swapTiles(at first: GridPosition, and second: GridPosition) {
        let temporaryTile = tiles[first.row][first.column]
        tiles[first.row][first.column] = tiles[second.row][second.column]
        tiles[second.row][second.column] = temporaryTile
    }

    func hasMatches() -> Bool {
        !allMatches().isEmpty
    }

    mutating func resolveCurrentMatches() -> MoveResult {
        resolve(matches: allMatches())
    }

    func currentMatches() -> Set<GridPosition> {
        allMatches()
    }

    func allMatchRuns() -> [MatchRun] {
        var runs: [MatchRun] = []

        for row in 0..<size {
            var startColumn = 0
            while startColumn < size {
                // Skip stone cells
                if tiles[row][startColumn].obstacle.isStone {
                    startColumn += 1
                    continue
                }
                let kind = tiles[row][startColumn].kind
                var endColumn = startColumn + 1
                while endColumn < size, !tiles[row][endColumn].obstacle.isStone, tiles[row][endColumn].kind == kind {
                    endColumn += 1
                }
                if endColumn - startColumn >= 3 {
                    var positions: [GridPosition] = []
                    for col in startColumn..<endColumn {
                        positions.append(GridPosition(row: row, column: col))
                    }
                    runs.append(MatchRun(positions: positions, direction: .horizontal))
                }
                startColumn = endColumn
            }
        }

        for column in 0..<size {
            var startRow = 0
            while startRow < size {
                // Skip stone cells
                if tiles[startRow][column].obstacle.isStone {
                    startRow += 1
                    continue
                }
                let kind = tiles[startRow][column].kind
                var endRow = startRow + 1
                while endRow < size, !tiles[endRow][column].obstacle.isStone, tiles[endRow][column].kind == kind {
                    endRow += 1
                }
                if endRow - startRow >= 3 {
                    var positions: [GridPosition] = []
                    for row in startRow..<endRow {
                        positions.append(GridPosition(row: row, column: column))
                    }
                    runs.append(MatchRun(positions: positions, direction: .vertical))
                }
                startRow = endRow
            }
        }

        return runs
    }

    func expandWithPowerUps(_ positions: Set<GridPosition>) -> Set<GridPosition> {
        var allPositions = positions
        var processed = Set<GridPosition>()

        while true {
            let unprocessed = allPositions.subtracting(processed)
            var newPositions = Set<GridPosition>()

            for pos in unprocessed {
                processed.insert(pos)
                let tile = tiles[pos.row][pos.column]
                switch tile.powerUp {
                case .rocketHorizontal:
                    for col in 0..<size {
                        newPositions.insert(GridPosition(row: pos.row, column: col))
                    }
                case .rocketVertical:
                    for row in 0..<size {
                        newPositions.insert(GridPosition(row: row, column: pos.column))
                    }
                case .bomb:
                    for dr in -1...1 {
                        for dc in -1...1 {
                            let r = pos.row + dr
                            let c = pos.column + dc
                            if r >= 0, r < size, c >= 0, c < size {
                                newPositions.insert(GridPosition(row: r, column: c))
                            }
                        }
                    }
                case .magnet:
                    let magnetKind = tiles[pos.row][pos.column].kind
                    for r in 0..<size {
                        for c in 0..<size {
                            if tiles[r][c].kind == magnetKind {
                                newPositions.insert(GridPosition(row: r, column: c))
                            }
                        }
                    }
                case .none:
                    break
                }
            }

            let before = allPositions.count
            allPositions.formUnion(newPositions)
            if allPositions.count == before { break }
        }

        return allPositions
    }

    func determinePowerUpSpawns(runs: [MatchRun], matched: Set<GridPosition>) -> [PowerUpSpawn] {
        var spawns: [PowerUpSpawn] = []
        var usedPositions = Set<GridPosition>()

        var positionDirections: [GridPosition: Set<RunDirection>] = [:]
        for run in runs {
            for pos in run.positions {
                positionDirections[pos, default: []].insert(run.direction)
            }
        }

        for (pos, directions) in positionDirections where directions.count > 1 {
            spawns.append(PowerUpSpawn(position: pos, powerUp: .magnet))
            usedPositions.insert(pos)
        }

        for run in runs where run.positions.count >= 5 {
            let spawnPos = run.positions[run.positions.count / 2]
            if !usedPositions.contains(spawnPos) {
                spawns.append(PowerUpSpawn(position: spawnPos, powerUp: .magnet))
                usedPositions.insert(spawnPos)
            }
        }

        for run in runs where run.positions.count == 4 {
            let hasSpawn = run.positions.contains { usedPositions.contains($0) }
            if hasSpawn { continue }
            let spawnPos = run.positions[1]
            let powerUp: PowerUp = run.direction == .horizontal ? .rocketVertical : .rocketHorizontal
            spawns.append(PowerUpSpawn(position: spawnPos, powerUp: powerUp))
            usedPositions.insert(spawnPos)
        }

        return spawns
    }

    mutating func refillAfterRemoval(_ matchedPositions: Set<GridPosition>) -> [TileDrop] {
        var drops: [TileDrop] = []

        for column in 0..<size {
            // Identify stone rows in this column (they stay fixed)
            var stoneRows = Set<Int>()
            for row in 0..<size {
                if tiles[row][column].obstacle.isStone {
                    stoneRows.insert(row)
                }
            }

            // If no stones, use simple drop logic
            if stoneRows.isEmpty {
                var remainingTiles: [Match3Tile] = []
                var originalRows: [Int] = []

                for row in 0..<size where !matchedPositions.contains(GridPosition(row: row, column: column)) {
                    remainingTiles.append(tiles[row][column])
                    originalRows.append(row)
                }

                let removedCount = size - remainingTiles.count
                
                for (index, originalRow) in originalRows.enumerated() {
                    let newRow = removedCount + index
                    if newRow != originalRow {
                        drops.append(TileDrop(column: column, fromRow: originalRow, toRow: newRow))
                    }
                }

                var newTiles: [Match3Tile] = []
                let newCount = size - remainingTiles.count
                
                for newRow in 0..<newCount {
                    var forbidden = Set<TileKind>()
                    
                    if newRow >= 2 {
                        let twoAbove = newTiles[newRow - 1].kind
                        let oneAbove = newTiles[newRow - 2].kind
                        if twoAbove == oneAbove {
                            forbidden.insert(twoAbove)
                        }
                    }
                    
                    if remainingTiles.count >= 2 {
                        let firstBelow = remainingTiles[0].kind
                        let secondBelow = remainingTiles[1].kind
                        if firstBelow == secondBelow {
                            forbidden.insert(firstBelow)
                        }
                    }
                    
                    if column >= 2 {
                        let left1 = column - 1 < size ? tiles[newRow][column - 1].kind : nil
                        let left2 = column - 2 < size ? tiles[newRow][column - 2].kind : nil
                        if let left1 = left1, let left2 = left2, left1 == left2 {
                            forbidden.insert(left1)
                        }
                    }
                    
                    let newKind = Self.randomKind(avoiding: forbidden)
                    newTiles.append(Match3Tile(kind: newKind))
                    drops.append(TileDrop(column: column, fromRow: -1, toRow: newRow))
                }
                
                let allTiles = newTiles + remainingTiles
                
                for row in 0..<size {
                    tiles[row][column] = allTiles[row]
                }
            } else {
                // With stones: process segments between stones independently
                // Segments are ranges of rows that are NOT stone rows
                // Tiles drop within each segment, new tiles fill from top of segment
                var segments: [(start: Int, end: Int)] = []
                var segStart: Int? = nil
                for row in 0...size {
                    if row < size && !stoneRows.contains(row) {
                        if segStart == nil { segStart = row }
                    } else {
                        if let s = segStart {
                            segments.append((start: s, end: row - 1))
                            segStart = nil
                        }
                    }
                }

                for seg in segments {
                    var remaining: [(tile: Match3Tile, origRow: Int)] = []
                    for row in seg.start...seg.end {
                        if !matchedPositions.contains(GridPosition(row: row, column: column)) {
                            remaining.append((tile: tiles[row][column], origRow: row))
                        }
                    }
                    let segLen = seg.end - seg.start + 1
                    let removedInSeg = segLen - remaining.count

                    for (index, item) in remaining.enumerated() {
                        let newRow = seg.start + removedInSeg + index
                        if newRow != item.origRow {
                            drops.append(TileDrop(column: column, fromRow: item.origRow, toRow: newRow))
                        }
                    }

                    for i in 0..<removedInSeg {
                        let newRow = seg.start + i
                        let forbidden = forbiddenKinds(row: newRow, column: column)
                        let newKind = Self.randomKind(avoiding: forbidden)
                        tiles[newRow][column] = Match3Tile(kind: newKind)
                        drops.append(TileDrop(column: column, fromRow: -1, toRow: newRow))
                    }
                    for (index, item) in remaining.enumerated() {
                        let newRow = seg.start + removedInSeg + index
                        tiles[newRow][column] = item.tile
                    }
                }
            }
        }

        return drops
    }

    private mutating func resolve(matches: Set<GridPosition>) -> MoveResult {
        var currentMatches = matches
        var removedByKind: [TileKind: Int] = [:]
        var totalRemoved = 0

        while !currentMatches.isEmpty {
            for position in currentMatches {
                let kind = tiles[position.row][position.column].kind
                removedByKind[kind, default: 0] += 1
                totalRemoved += 1
            }
            refill(matchedPositions: currentMatches)
            currentMatches = allMatches()
        }

        return MoveResult(totalRemoved: totalRemoved, removedByKind: removedByKind)
    }

    private mutating func refill(matchedPositions: Set<GridPosition>) {
        for column in 0..<size {
            var remainingTiles: [Match3Tile] = []

            for row in 0..<size where !matchedPositions.contains(GridPosition(row: row, column: column)) {
                remainingTiles.append(tiles[row][column])
            }

            while remainingTiles.count < size {
                let row = size - remainingTiles.count - 1
                let forbidden = forbiddenKinds(row: row, column: column, currentColumn: remainingTiles)
                remainingTiles.insert(Match3Tile(kind: Self.randomKind(avoiding: forbidden)), at: 0)
            }

            for row in 0..<size {
                tiles[row][column] = remainingTiles[row]
            }
        }
    }

    func hasAvailableMoves() -> Bool {
        var copy = self
        for row in 0..<size {
            for col in 0..<size {
                guard tiles[row][col].obstacle == .none else { continue }
                let pos = GridPosition(row: row, column: col)
                for (dr, dc) in [(0, 1), (1, 0)] {
                    let nr = row + dr
                    let nc = col + dc
                    guard nr < size, nc < size else { continue }
                    guard tiles[nr][nc].obstacle == .none else { continue }
                    let neighbor = GridPosition(row: nr, column: nc)
                    copy.swapTilesInPlace(pos, neighbor)
                    let found = !copy.allMatches().isEmpty
                    copy.swapTilesInPlace(pos, neighbor)
                    if found { return true }
                }
            }
        }
        return false
    }

    mutating func shuffle() {
        var positions: [GridPosition] = []
        for row in 0..<size {
            for col in 0..<size {
                if tiles[row][col].obstacle == .none {
                    positions.append(GridPosition(row: row, column: col))
                }
            }
        }

        guard !positions.isEmpty else { return }

        // Phase 1: try shuffling existing kinds (preserves distribution)
        for _ in 0..<100 {
            var kinds = positions.map { tiles[$0.row][$0.column].kind }
            kinds.shuffle()
            for (i, pos) in positions.enumerated() {
                tiles[pos.row][pos.column] = Match3Tile(
                    kind: kinds[i],
                    powerUp: tiles[pos.row][pos.column].powerUp
                )
            }
            if allMatches().isEmpty && hasAvailableMoves() {
                return
            }
        }

        // Phase 2: regenerate with fresh random kinds until valid
        for _ in 0..<200 {
            for pos in positions {
                let forbidden = forbiddenKinds(row: pos.row, column: pos.column)
                tiles[pos.row][pos.column] = Match3Tile(
                    kind: Self.randomKind(avoiding: forbidden),
                    powerUp: tiles[pos.row][pos.column].powerUp
                )
            }
            if hasAvailableMoves() {
                // Resolve any accidental matches silently
                while !allMatches().isEmpty {
                    let matched = allMatches()
                    for pos in matched where positions.contains(pos) {
                        let forbidden = forbiddenKinds(row: pos.row, column: pos.column)
                        tiles[pos.row][pos.column] = Match3Tile(
                            kind: Self.randomKind(avoiding: forbidden),
                            powerUp: tiles[pos.row][pos.column].powerUp
                        )
                    }
                }
                if hasAvailableMoves() {
                    return
                }
            }
        }
    }

    private mutating func swapTilesInPlace(_ a: GridPosition, _ b: GridPosition) {
        let tmp = tiles[a.row][a.column]
        tiles[a.row][a.column] = tiles[b.row][b.column]
        tiles[b.row][b.column] = tmp
    }

    /// Returns all 4 positions of a stone given its origin (top-left corner).
    func stonePositions(origin: GridPosition) -> [GridPosition] {
        var positions: [GridPosition] = []
        for dr in 0..<2 {
            for dc in 0..<2 {
                let r = origin.row + dr
                let c = origin.column + dc
                if r >= 0, r < size, c >= 0, c < size {
                    positions.append(GridPosition(row: r, column: c))
                }
            }
        }
        return positions
    }

    /// Damage a stone at the given origin. Returns number of cleared obstacles (4 if destroyed, 0 otherwise).
    mutating func damageStone(origin: GridPosition) -> Int {
        let topLeft = origin
        guard topLeft.row >= 0, topLeft.row < size, topLeft.column >= 0, topLeft.column < size else { return 0 }
        guard case .stone(let hits, let orig) = tiles[topLeft.row][topLeft.column].obstacle, orig == topLeft else { return 0 }

        if hits <= 1 {
            // Destroy stone — clear all 4 cells
            for pos in stonePositions(origin: origin) {
                tiles[pos.row][pos.column].obstacle = .none
                tiles[pos.row][pos.column] = Match3Tile(
                    kind: Self.randomKind(avoiding: forbiddenKinds(row: pos.row, column: pos.column))
                )
            }
            return 1
        } else {
            // Reduce hits on all 4 cells
            let newHits = hits - 1
            for pos in stonePositions(origin: origin) {
                tiles[pos.row][pos.column].obstacle = .stone(hits: newHits, origin: origin)
            }
            return 0
        }
    }

    private func allMatches() -> Set<GridPosition> {
        var positions = Set<GridPosition>()
        for run in allMatchRuns() {
            positions.formUnion(run.positions)
        }
        return positions
    }

    private func forbiddenKinds(row: Int, column: Int, currentColumn: [Match3Tile] = []) -> Set<TileKind> {
        var forbiddenKinds = Set<TileKind>()

        if column >= 2 {
            let firstKind = tiles[row][column - 1].kind
            let secondKind = tiles[row][column - 2].kind

            if firstKind == secondKind {
                forbiddenKinds.insert(firstKind)
            }
        }

        if row >= 2 {
            let firstKind: TileKind
            let secondKind: TileKind

            if currentColumn.isEmpty {
                firstKind = tiles[row - 1][column].kind
                secondKind = tiles[row - 2][column].kind
            } else {
                let firstIndex = currentColumn.count - (size - row + 1)
                let secondIndex = currentColumn.count - (size - row)

                if firstIndex >= 0, secondIndex >= 0 {
                    firstKind = currentColumn[firstIndex].kind
                    secondKind = currentColumn[secondIndex].kind
                } else {
                    firstKind = tiles[row - 1][column].kind
                    secondKind = tiles[row - 2][column].kind
                }
            }

            if firstKind == secondKind {
                forbiddenKinds.insert(firstKind)
            }
        }

        return forbiddenKinds
    }

    private static func randomKind(avoiding forbiddenKinds: Set<TileKind>) -> TileKind {
        let availableKinds = TileKind.allCases.filter { !forbiddenKinds.contains($0) }
        return availableKinds.randomElement() ?? TileKind.allCases[0]
    }
}
