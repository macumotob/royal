//
//  ViewController.swift
//  royal
//
//  Created by Василий Букшован on 11.04.26.
//

import UIKit

final class ViewController: UIViewController {
    private let boardSize = 6
    private let levels = LevelConfiguration.defaultLevels
    private let progressStore = ProgressStore()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Royal Quest"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.84)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let mapContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.layer.cornerRadius = 24
        return view
    }()

    private let mapProgressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let levelButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        return stackView
    }()

    private let aboutButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "О прототипе"
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.16)
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        return button
    }()

    private let gameContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let boardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.layer.cornerRadius = 24
        return view
    }()

    private let boardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let shuffleButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Переиграть уровень"
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = UIColor(red: 0.12, green: 0.21, blue: 0.52, alpha: 1.0)
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        return button
    }()

    private let mapButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "К карте уровней"
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.16)
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        return button
    }()

    private var tileButtons: [[UIButton]] = []
    private var board = Match3Board(size: 6)
    private var selectedPosition: GridPosition?
    private var movesCount = 0
    private var score = 0
    private var collectedGoalTiles = 0
    private var isLevelFinished = false
    private var isResolvingMove = false
    private var currentLevelIndex = 0
    private var levelButtons: [UIButton] = []

    private var currentLevel: LevelConfiguration {
        levels[currentLevelIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentLevelIndex = progressStore.restoredLevelIndex(maxIndex: levels.count - 1)
        configureView()
        layoutInterface()
        buildBoardGrid()
        buildLevelButtons()
        wireActions()
        showMapScreen()
    }
}

private extension ViewController {
    func configureView() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.21, blue: 0.52, alpha: 1.0)
    }

    func layoutInterface() {
        let mapStack = UIStackView(arrangedSubviews: [mapProgressLabel, levelButtonsStackView, aboutButton])
        mapStack.translatesAutoresizingMaskIntoConstraints = false
        mapStack.axis = .vertical
        mapStack.spacing = 16

        mapContainerView.addSubview(mapStack)

        let gameButtonsStack = UIStackView(arrangedSubviews: [shuffleButton, mapButton])
        gameButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        gameButtonsStack.axis = .vertical
        gameButtonsStack.spacing = 14

        boardContainerView.addSubview(boardStackView)

        let gameStack = UIStackView(arrangedSubviews: [progressLabel, statusLabel, boardContainerView, gameButtonsStack])
        gameStack.translatesAutoresizingMaskIntoConstraints = false
        gameStack.axis = .vertical
        gameStack.spacing = 18

        gameContainerView.addSubview(gameStack)

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, mapContainerView, gameContainerView])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            mapStack.topAnchor.constraint(equalTo: mapContainerView.topAnchor, constant: 20),
            mapStack.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 20),
            mapStack.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -20),
            mapStack.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: -20),

            gameStack.topAnchor.constraint(equalTo: gameContainerView.topAnchor),
            gameStack.leadingAnchor.constraint(equalTo: gameContainerView.leadingAnchor),
            gameStack.trailingAnchor.constraint(equalTo: gameContainerView.trailingAnchor),
            gameStack.bottomAnchor.constraint(equalTo: gameContainerView.bottomAnchor),

            boardContainerView.heightAnchor.constraint(equalTo: boardContainerView.widthAnchor),

            boardStackView.topAnchor.constraint(equalTo: boardContainerView.topAnchor, constant: 16),
            boardStackView.leadingAnchor.constraint(equalTo: boardContainerView.leadingAnchor, constant: 16),
            boardStackView.trailingAnchor.constraint(equalTo: boardContainerView.trailingAnchor, constant: -16),
            boardStackView.bottomAnchor.constraint(equalTo: boardContainerView.bottomAnchor, constant: -16)
        ])
    }

    func buildBoardGrid() {
        tileButtons.removeAll()
        boardStackView.arrangedSubviews.forEach { rowView in
            boardStackView.removeArrangedSubview(rowView)
            rowView.removeFromSuperview()
        }

        for row in 0..<boardSize {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 8
            rowStackView.distribution = .fillEqually

            var rowButtons: [UIButton] = []

            for column in 0..<boardSize {
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.tag = row * boardSize + column
                button.layer.cornerRadius = 14
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
                button.addTarget(self, action: #selector(didTapTile(_:)), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
                rowButtons.append(button)
            }

            boardStackView.addArrangedSubview(rowStackView)
            tileButtons.append(rowButtons)
        }
    }

    func buildLevelButtons() {
        levelButtonsStackView.arrangedSubviews.forEach { levelView in
            levelButtonsStackView.removeArrangedSubview(levelView)
            levelView.removeFromSuperview()
        }
        levelButtons.removeAll()

        for level in levels {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = level.number - 1
            button.addTarget(self, action: #selector(didTapLevelButton(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
            levelButtonsStackView.addArrangedSubview(button)
            levelButtons.append(button)
        }
    }

    func wireActions() {
        aboutButton.addTarget(self, action: #selector(didTapAbout), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(didTapMap), for: .touchUpInside)
    }

    func showMapScreen() {
        mapContainerView.isHidden = false
        gameContainerView.isHidden = true
        subtitleLabel.text = "Выберите открытый уровень и начните прохождение."

        let unlockedCount = progressStore.unlockedLevelCount(totalLevels: levels.count)
        mapProgressLabel.text = "Открыто уровней: \(unlockedCount) из \(levels.count)"

        for (index, button) in levelButtons.enumerated() {
            let level = levels[index]
            let unlocked = index < unlockedCount

            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .large
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            configuration.baseBackgroundColor = unlocked ? .white : UIColor.white.withAlphaComponent(0.12)
            configuration.baseForegroundColor = unlocked ? UIColor(red: 0.12, green: 0.21, blue: 0.52, alpha: 1.0) : .white.withAlphaComponent(0.7)
            configuration.title = unlocked
                ? "Уровень \(level.number) • \(level.title)"
                : "Уровень \(level.number) • Закрыт"
            configuration.subtitle = unlocked
                ? "Цель: \(level.goal.targetCount) \(level.goal.targetKind.symbol), ходов: \(level.goal.moveLimit)"
                : "Пройдите предыдущий уровень"
            button.configuration = configuration
            button.isEnabled = unlocked
        }
    }

    func showGameScreen() {
        mapContainerView.isHidden = true
        gameContainerView.isHidden = false
        updateStatus(currentLevel.startMessage)
    }

    func renderBoard() {
        for row in 0..<boardSize {
            for column in 0..<boardSize {
                let tile = board.tiles[row][column]
                let button = tileButtons[row][column]
                button.setTitle(tile.kind.symbol, for: .normal)
                button.backgroundColor = tile.kind.color

                let isSelected = selectedPosition == GridPosition(row: row, column: column)
                button.layer.borderWidth = isSelected ? 3 : 0
                button.layer.borderColor = UIColor.white.cgColor
                button.alpha = isSelected ? 0.82 : 1.0
            }
        }
    }

    func updateStatus(_ text: String) {
        let remainingMoves = max(currentLevel.goal.moveLimit - movesCount, 0)
        subtitleLabel.text = "Уровень \(currentLevel.number): \(currentLevel.title)"
        progressLabel.text = "Цель: собрать \(currentLevel.goal.targetCount) \(currentLevel.goal.targetKind.symbol)  |  Собрано: \(collectedGoalTiles)"
        statusLabel.text = "Очки: \(score)  |  Ходы: \(remainingMoves)\n\(text)"
    }

    func startLevel(index: Int) {
        currentLevelIndex = max(0, min(index, levels.count - 1))
        board = Match3Board(size: boardSize)
        selectedPosition = nil
        movesCount = 0
        score = 0
        collectedGoalTiles = 0
        isLevelFinished = false
        isResolvingMove = false
        renderBoard()
        showGameScreen()
    }

    func handleSelection(at position: GridPosition) {
        guard !isResolvingMove, !isLevelFinished else {
            return
        }

        guard let currentSelection = selectedPosition else {
            selectedPosition = position
            renderBoard()
            updateStatus("Выбрана фишка. Нажмите соседнюю клетку для обмена.")
            return
        }

        if currentSelection == position {
            selectedPosition = nil
            renderBoard()
            updateStatus("Выбор снят.")
            return
        }

        guard currentSelection.isAdjacent(to: position) else {
            selectedPosition = position
            renderBoard()
            updateStatus("Можно менять только соседние фишки.")
            return
        }

        selectedPosition = nil
        board.swapTiles(at: currentSelection, and: position)
        renderBoard()

        if board.hasMatches() {
            isResolvingMove = true
            movesCount += 1
            updateStatus("Фишки обменены. Проверяем совпадение...")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self else { return }
                let result = self.board.resolveCurrentMatches()
                self.score += result.totalRemoved * 10
                self.collectedGoalTiles += result.removedByKind[self.currentLevel.goal.targetKind, default: 0]
                self.isResolvingMove = false
                self.renderBoard()
                self.updateStatus("Совпадение найдено. Удалено фишек: \(result.totalRemoved).")
                self.evaluateLevelState()
            }
        } else {
            isResolvingMove = true
            updateStatus("Совпадения нет. Возвращаем фишки назад.")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self else { return }
                self.board.swapTiles(at: currentSelection, and: position)
                self.isResolvingMove = false
                self.renderBoard()
                self.updateStatus("Совпадения нет. Обмен отменен.")
            }
        }
    }

    func evaluateLevelState() {
        if collectedGoalTiles >= currentLevel.goal.targetCount {
            isLevelFinished = true
            progressStore.unlockLevel(afterCompleting: currentLevelIndex, totalLevels: levels.count)
            showCompletionAlert(
                title: "Победа",
                message: "Уровень \(currentLevel.number) пройден. Вы собрали \(collectedGoalTiles) \(currentLevel.goal.targetKind.symbol) и набрали \(score) очков."
            )
            return
        }

        if movesCount >= currentLevel.goal.moveLimit {
            isLevelFinished = true
            showCompletionAlert(
                title: "Ходы закончились",
                message: "Уровень \(currentLevel.number) не пройден. Собрано \(collectedGoalTiles) из \(currentLevel.goal.targetCount), очки: \(score)."
            )
        }
    }

    func showCompletionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if title == "Победа", currentLevelIndex + 1 < levels.count {
            alert.addAction(UIAlertAction(title: "Следующий уровень", style: .default) { [weak self] _ in
                guard let self else { return }
                self.startLevel(index: self.currentLevelIndex + 1)
            })
        }

        alert.addAction(UIAlertAction(title: "К карте", style: .default) { [weak self] _ in
            self?.showMapScreen()
        })

        alert.addAction(UIAlertAction(title: "Переиграть", style: .default) { [weak self] _ in
            self?.didTapShuffle()
        })

        present(alert, animated: true)
    }

    @objc
    func didTapTile(_ sender: UIButton) {
        let position = GridPosition(row: sender.tag / boardSize, column: sender.tag % boardSize)
        handleSelection(at: position)
    }

    @objc
    func didTapShuffle() {
        startLevel(index: currentLevelIndex)
    }

    @objc
    func didTapMap() {
        showMapScreen()
    }

    @objc
    func didTapAbout() {
        let unlockedCount = progressStore.unlockedLevelCount(totalLevels: levels.count)
        let message = """
        Открыто уровней: \(unlockedCount) из \(levels.count)

        Ближайшие шаги:
        1. Отдельная карта с путём между уровнями
        2. Спец-фишки и бустеры
        3. Экран замка и оформление
        """
        let alert = UIAlertController(title: "О прототипе", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc
    func didTapLevelButton(_ sender: UIButton) {
        startLevel(index: sender.tag)
    }
}

private struct GridPosition: Hashable {
    let row: Int
    let column: Int

    func isAdjacent(to other: GridPosition) -> Bool {
        abs(row - other.row) + abs(column - other.column) == 1
    }
}

private struct Match3Tile {
    let kind: TileKind
}

private struct LevelGoal {
    let targetKind: TileKind
    let targetCount: Int
    let moveLimit: Int
}

private struct LevelConfiguration {
    let number: Int
    let title: String
    let goal: LevelGoal
    let startMessage: String

    static let defaultLevels: [LevelConfiguration] = [
        LevelConfiguration(
            number: 1,
            title: "Королевский двор",
            goal: LevelGoal(targetKind: .crown, targetCount: 12, moveLimit: 14),
            startMessage: "Соберите короны до конца ходов."
        ),
        LevelConfiguration(
            number: 2,
            title: "Рубиновая галерея",
            goal: LevelGoal(targetKind: .ruby, targetCount: 14, moveLimit: 13),
            startMessage: "Теперь цель уровня - собрать рубины."
        ),
        LevelConfiguration(
            number: 3,
            title: "Зал щитов",
            goal: LevelGoal(targetKind: .shield, targetCount: 15, moveLimit: 12),
            startMessage: "Щиты сложнее. Ходов меньше, думайте на 2 шага вперед."
        )
    ]
}

private enum TileKind: CaseIterable {
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

private struct Match3Board {
    let size: Int
    var tiles: [[Match3Tile]]

    init(size: Int) {
        self.size = size
        self.tiles = Array(
            repeating: Array(repeating: Match3Tile(kind: .crown), count: size),
            count: size
        )

        for row in 0..<size {
            for column in 0..<size {
                tiles[row][column] = Match3Tile(kind: Self.randomKind(avoiding: forbiddenKinds(row: row, column: column)))
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

    private func allMatches() -> Set<GridPosition> {
        var positions = Set<GridPosition>()

        for row in 0..<size {
            var startColumn = 0
            while startColumn < size {
                let kind = tiles[row][startColumn].kind
                var endColumn = startColumn + 1

                while endColumn < size, tiles[row][endColumn].kind == kind {
                    endColumn += 1
                }

                if endColumn - startColumn >= 3 {
                    for column in startColumn..<endColumn {
                        positions.insert(GridPosition(row: row, column: column))
                    }
                }

                startColumn = endColumn
            }
        }

        for column in 0..<size {
            var startRow = 0
            while startRow < size {
                let kind = tiles[startRow][column].kind
                var endRow = startRow + 1

                while endRow < size, tiles[endRow][column].kind == kind {
                    endRow += 1
                }

                if endRow - startRow >= 3 {
                    for row in startRow..<endRow {
                        positions.insert(GridPosition(row: row, column: column))
                    }
                }

                startRow = endRow
            }
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

private struct MoveResult {
    let totalRemoved: Int
    let removedByKind: [TileKind: Int]
}

private struct ProgressStore {
    private let unlockedLevelKey = "royal.unlockedLevelIndex"

    func restoredLevelIndex(maxIndex: Int) -> Int {
        let savedIndex = UserDefaults.standard.integer(forKey: unlockedLevelKey)
        return max(0, min(savedIndex, maxIndex))
    }

    func unlockLevel(afterCompleting index: Int, totalLevels: Int) {
        let nextIndex = min(index + 1, totalLevels - 1)
        let currentStoredIndex = UserDefaults.standard.integer(forKey: unlockedLevelKey)
        UserDefaults.standard.set(max(currentStoredIndex, nextIndex), forKey: unlockedLevelKey)
    }

    func unlockedLevelCount(totalLevels: Int) -> Int {
        min(UserDefaults.standard.integer(forKey: unlockedLevelKey) + 1, totalLevels)
    }
}
