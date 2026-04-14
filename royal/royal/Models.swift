import UIKit

struct GridPosition: Hashable {
    let row: Int
    let column: Int

    func isAdjacent(to other: GridPosition) -> Bool {
        abs(row - other.row) + abs(column - other.column) == 1
    }
}

struct Match3Tile {
    let kind: TileKind
    var powerUp: PowerUp = .none
    var obstacle: Obstacle = .none
}

enum PowerUp {
    case none
    case rocketHorizontal
    case rocketVertical
    case bomb
    case magnet
}

enum Obstacle: Equatable {
    case none
    case ice(hits: Int)
    case chain
    /// Stone occupies a 2×2 area. `origin` is the top-left GridPosition. `hits` is remaining HP.
    case stone(hits: Int, origin: GridPosition)

    var isStone: Bool {
        if case .stone = self { return true }
        return false
    }
}

enum RunDirection {
    case horizontal
    case vertical
}

struct MatchRun {
    let positions: [GridPosition]
    let direction: RunDirection
}

struct PowerUpSpawn {
    let position: GridPosition
    let powerUp: PowerUp
}

struct LevelGoal {
    let type: GoalType
    let moveLimit: Int
}

enum GoalType {
    case collect(kind: TileKind, count: Int)
    case reachScore(target: Int)
    case clearObstacles(count: Int)

    var description: String {
        switch self {
        case .collect(let kind, let count):
            return "собрать \(count) \(kind.symbol)"
        case .reachScore(let target):
            return "набрать \(target) очков"
        case .clearObstacles(let count):
            return "разбить \(count) препятствий"
        }
    }
}

struct MoveResult {
    let totalRemoved: Int
    let removedByKind: [TileKind: Int]
}

struct TileDrop {
    let column: Int
    let fromRow: Int
    let toRow: Int
}

enum TileKind: CaseIterable {
    case crown
    case ruby
    case shield
    case star
    case leaf

    var symbol: String {
        switch self {
        case .crown:
            return "👑"
        case .ruby:
            return "♦️"
        case .shield:
            return "🛡"
        case .star:
            return "⭐️"
        case .leaf:
            return "🍀"
        }
    }

    var color: UIColor {
        switch self {
        case .crown:
            return UIColor(red: 0.95, green: 0.74, blue: 0.19, alpha: 1.0)
        case .ruby:
            return UIColor(red: 0.83, green: 0.24, blue: 0.36, alpha: 1.0)
        case .shield:
            return UIColor(red: 0.23, green: 0.52, blue: 0.88, alpha: 1.0)
        case .star:
            return UIColor(red: 0.97, green: 0.55, blue: 0.19, alpha: 1.0)
        case .leaf:
            return UIColor(red: 0.29, green: 0.68, blue: 0.42, alpha: 1.0)
        }
    }
}
