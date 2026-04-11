//
//  ViewController.swift
//  royal
//
//  Created by Василий Букшован on 11.04.26.
//

import UIKit
import AudioToolbox

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
        stackView.spacing = 10
        stackView.alignment = .center
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

    private let resetButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Начать сначала"
        configuration.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
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
    private let levelsPerRow = 5

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
        // Map screen: progress label + grid of level icons + about button inside container
        let mapInnerStack = UIStackView(arrangedSubviews: [mapProgressLabel, levelButtonsStackView, aboutButton, resetButton])
        mapInnerStack.translatesAutoresizingMaskIntoConstraints = false
        mapInnerStack.axis = .vertical
        mapInnerStack.spacing = 16
        mapInnerStack.alignment = .center

        mapContainerView.addSubview(mapInnerStack)

        // Game screen
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

        // Main scroll view wrapping everything
        let contentStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, mapContainerView, gameContainerView])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        let mainScrollView = UIScrollView()
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.alwaysBounceVertical = true
        mainScrollView.addSubview(contentStack)
        view.addSubview(mainScrollView)

        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            mapInnerStack.topAnchor.constraint(equalTo: mapContainerView.topAnchor, constant: 20),
            mapInnerStack.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 20),
            mapInnerStack.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -20),
            mapInnerStack.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: -20),

            mapProgressLabel.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            mapProgressLabel.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            aboutButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            aboutButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            resetButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

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
        levelButtonsStackView.arrangedSubviews.forEach { view in
            levelButtonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        levelButtons.removeAll()

        var currentRow: UIStackView?
        for (index, level) in levels.enumerated() {
            if index % levelsPerRow == 0 {
                let row = UIStackView()
                row.axis = .horizontal
                row.spacing = 10
                row.distribution = .fillEqually
                levelButtonsStackView.addArrangedSubview(row)
                currentRow = row
            }

            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = level.number - 1
            button.layer.cornerRadius = 16
            button.clipsToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            button.addTarget(self, action: #selector(didTapLevelButton(_:)), for: .touchUpInside)

            let size: CGFloat = 52
            button.widthAnchor.constraint(equalToConstant: size).isActive = true
            button.heightAnchor.constraint(equalToConstant: size).isActive = true

            currentRow?.addArrangedSubview(button)
            levelButtons.append(button)
        }

        let lastRowCount = levels.count % levelsPerRow
        if lastRowCount > 0, let lastRow = currentRow {
            for _ in 0..<(levelsPerRow - lastRowCount) {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                spacer.widthAnchor.constraint(equalToConstant: 52).isActive = true
                lastRow.addArrangedSubview(spacer)
            }
        }
    }

    func wireActions() {
        aboutButton.addTarget(self, action: #selector(didTapAbout), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(didTapMap), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    }

    func showMapScreen() {
        mapContainerView.isHidden = false
        gameContainerView.isHidden = true
        subtitleLabel.text = "Выберите открытый уровень и начните прохождение."

        let unlockedCount = progressStore.unlockedLevelCount(totalLevels: levels.count)
        mapProgressLabel.text = "Открыто уровней: \(unlockedCount) из \(levels.count)"

        for (index, button) in levelButtons.enumerated() {
            let unlocked = index < unlockedCount

            if unlocked {
                button.setTitle("\(index + 1)", for: .normal)
                button.setTitleColor(UIColor(red: 0.12, green: 0.21, blue: 0.52, alpha: 1.0), for: .normal)
                button.backgroundColor = .white
                button.layer.borderWidth = 0
            } else {
                button.setTitle("🔒", for: .normal)
                button.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
                button.backgroundColor = UIColor.white.withAlphaComponent(0.08)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            }

            button.configuration = nil
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

                switch tile.powerUp {
                case .none:
                    button.setTitle(tile.kind.symbol, for: .normal)
                case .rocketHorizontal:
                    button.setTitle("➡️", for: .normal)
                case .rocketVertical:
                    button.setTitle("⬆️", for: .normal)
                case .bomb:
                    button.setTitle("💣", for: .normal)
                }

                button.backgroundColor = tile.kind.color
                button.transform = .identity

                let isSelected = selectedPosition == GridPosition(row: row, column: column)
                let hasPowerUp = tile.powerUp != .none
                button.layer.borderWidth = isSelected ? 3 : (hasPowerUp ? 2 : 0)
                button.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.yellow.cgColor
                button.alpha = isSelected ? 0.82 : 1.0
            }
        }
    }

    func updateStatus(_ text: String) {
        let remainingMoves = max(currentLevel.goal.moveLimit - movesCount, 0)
        subtitleLabel.text = "Уровень \(currentLevel.number): \(currentLevel.title)"

        switch currentLevel.goal.type {
        case .collect(let kind, let count):
            progressLabel.text = "Цель: собрать \(count) \(kind.symbol)  |  Собрано: \(collectedGoalTiles)"
        case .reachScore(let target):
            progressLabel.text = "Цель: набрать \(target) очков  |  Набрано: \(score)"
        }

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
            SoundManager.play(.tileSelect)
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
            animateResolveChain(totalRemoved: 0, removedByKind: [:])
        } else {
            isResolvingMove = true
            updateStatus("Совпадения нет. Возвращаем фишки назад.")
            SoundManager.play(.swapDenied)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else { return }
                self.board.swapTiles(at: currentSelection, and: position)
                self.isResolvingMove = false
                self.renderBoard()
                self.updateStatus("Совпадения нет. Обмен отменен.")
            }
        }
    }

    func animateResolveChain(totalRemoved: Int, removedByKind: [TileKind: Int]) {
        let matched = board.currentMatches()
        guard !matched.isEmpty else {
            score += totalRemoved * 10
            switch currentLevel.goal.type {
            case .collect(let kind, _):
                collectedGoalTiles += removedByKind[kind, default: 0]
            case .reachScore:
                break
            }
            isResolvingMove = false
            renderBoard()
            updateStatus("Совпадение найдено. Удалено фишек: \(totalRemoved).")
            evaluateLevelState()
            return
        }

        let runs = board.allMatchRuns()
        let spawns = board.determinePowerUpSpawns(runs: runs, matched: matched)
        let expanded = board.expandWithPowerUps(matched)

        var removalSet = expanded
        let spawnPositionSet = Set(spawns.map { $0.position })
        removalSet.subtract(spawnPositionSet)

        var updatedByKind = removedByKind
        for pos in removalSet {
            updatedByKind[board.tiles[pos.row][pos.column].kind, default: 0] += 1
        }
        let updatedTotal = totalRemoved + removalSet.count

        animateRemoval(at: removalSet) { [weak self] in
            guard let self else { return }

            if !spawns.isEmpty {
                SoundManager.play(.powerUpCreated)
            }

            let hasPowerUpActivation = expanded.count > matched.count
            if hasPowerUpActivation {
                SoundManager.play(.powerUpActivated)
            } else {
                SoundManager.play(.matchRemove)
            }

            for spawn in spawns {
                self.board.tiles[spawn.position.row][spawn.position.column].powerUp = spawn.powerUp
            }

            let drops = self.board.refillAfterRemoval(removalSet)
            self.renderBoard()
            self.prepareDropTransforms(drops)

            self.animateDrops(drops) { [weak self] in
                guard let self else { return }
                self.animateResolveChain(totalRemoved: updatedTotal, removedByKind: updatedByKind)
            }
        }
    }

    func animateRemoval(at positions: Set<GridPosition>, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            for pos in positions {
                let button = self.tileButtons[pos.row][pos.column]
                button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                button.alpha = 0
            }
        }, completion: { _ in
            completion()
        })
    }

    func prepareDropTransforms(_ drops: [TileDrop]) {
        for drop in drops {
            let button = tileButtons[drop.toRow][drop.column]
            let rowDelta = CGFloat(drop.toRow - drop.fromRow)
            let cellHeight = button.bounds.height + 8
            button.transform = CGAffineTransform(translationX: 0, y: -rowDelta * cellHeight)
            if drop.fromRow < 0 {
                button.alpha = 0
            }
        }
    }

    func animateDrops(_ drops: [TileDrop], completion: @escaping () -> Void) {
        guard !drops.isEmpty else {
            completion()
            return
        }

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                for drop in drops {
                    let button = self.tileButtons[drop.toRow][drop.column]
                    button.transform = .identity
                    button.alpha = 1
                }
            },
            completion: { _ in
                completion()
            }
        )
    }

    func evaluateLevelState() {
        let goalReached: Bool
        switch currentLevel.goal.type {
        case .collect(_, let count):
            goalReached = collectedGoalTiles >= count
        case .reachScore(let target):
            goalReached = score >= target
        }

        if goalReached {
            isLevelFinished = true
            progressStore.unlockLevel(afterCompleting: currentLevelIndex, totalLevels: levels.count)
            SoundManager.play(.levelComplete)

            if currentLevelIndex + 1 < levels.count {
                updateStatus("Уровень \(currentLevel.number) пройден! Очки: \(score).")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self else { return }
                    self.startLevel(index: self.currentLevelIndex + 1)
                }
            } else {
                showCompletionAlert(
                    title: "Победа",
                    message: "Все уровни пройдены! Финальный счёт: \(score)."
                )
            }
            return
        }

        if movesCount >= currentLevel.goal.moveLimit {
            isLevelFinished = true
            let details: String
            switch currentLevel.goal.type {
            case .collect(let kind, let count):
                details = "Собрано \(collectedGoalTiles) из \(count) \(kind.symbol), очки: \(score)."
            case .reachScore(let target):
                details = "Набрано \(score) из \(target) очков."
            }
            showCompletionAlert(
                title: "Ходы закончились",
                message: "Уровень \(currentLevel.number) не пройден. \(details)"
            )
            SoundManager.play(.levelFailed)
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
        2. Звуковые эффекты
        3. Экран замка и оформление
        """
        let alert = UIAlertController(title: "О прототипе", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc
    func didTapReset() {
        let alert = UIAlertController(
            title: "Начать сначала?",
            message: "Весь прогресс будет сброшен. Продолжить?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сбросить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.progressStore.resetProgress()
            self.currentLevelIndex = 0
            self.showMapScreen()
            self.startLevel(index: 0)
        })
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
    var powerUp: PowerUp = .none
}

private enum PowerUp {
    case none
    case rocketHorizontal
    case rocketVertical
    case bomb
}

private enum RunDirection {
    case horizontal
    case vertical
}

private struct MatchRun {
    let positions: [GridPosition]
    let direction: RunDirection
}

private struct PowerUpSpawn {
    let position: GridPosition
    let powerUp: PowerUp
}

private struct LevelGoal {
    let type: GoalType
    let moveLimit: Int
}

private enum GoalType {
    case collect(kind: TileKind, count: Int)
    case reachScore(target: Int)

    var description: String {
        switch self {
        case .collect(let kind, let count):
            return "собрать \(count) \(kind.symbol)"
        case .reachScore(let target):
            return "набрать \(target) очков"
        }
    }
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
            goal: LevelGoal(type: .collect(kind: .crown, count: 10), moveLimit: 16),
            startMessage: "Соберите короны. Лёгкое начало!"
        ),
        LevelConfiguration(
            number: 2,
            title: "Рубиновая галерея",
            goal: LevelGoal(type: .collect(kind: .ruby, count: 12), moveLimit: 14),
            startMessage: "Теперь цель - рубины. Старайтесь собирать 4+!"
        ),
        LevelConfiguration(
            number: 3,
            title: "Зал щитов",
            goal: LevelGoal(type: .collect(kind: .shield, count: 14), moveLimit: 13),
            startMessage: "Щиты встречаются реже. Планируйте ходы."
        ),
        LevelConfiguration(
            number: 4,
            title: "Звёздный балкон",
            goal: LevelGoal(type: .collect(kind: .star, count: 14), moveLimit: 13),
            startMessage: "Звёзды добавляют азарта. Используйте спец-фишки!"
        ),
        LevelConfiguration(
            number: 5,
            title: "Клеверное поле",
            goal: LevelGoal(type: .collect(kind: .leaf, count: 15), moveLimit: 12),
            startMessage: "Удача на вашей стороне? Соберите клевер."
        ),
        LevelConfiguration(
            number: 6,
            title: "Зал побед",
            goal: LevelGoal(type: .reachScore(target: 500), moveLimit: 12),
            startMessage: "Новая цель! Наберите 500 очков за 12 ходов."
        ),
        LevelConfiguration(
            number: 7,
            title: "Корона и рубин",
            goal: LevelGoal(type: .collect(kind: .crown, count: 18), moveLimit: 13),
            startMessage: "Корон нужно много. Создавайте ракеты и бомбы!"
        ),
        LevelConfiguration(
            number: 8,
            title: "Рубиновая шахта",
            goal: LevelGoal(type: .collect(kind: .ruby, count: 20), moveLimit: 14),
            startMessage: "Глубоко в шахте прячутся рубины."
        ),
        LevelConfiguration(
            number: 9,
            title: "Тронный зал",
            goal: LevelGoal(type: .reachScore(target: 800), moveLimit: 12),
            startMessage: "800 очков! Комбинируйте спец-фишки для мега-бонуса."
        ),
        LevelConfiguration(
            number: 10,
            title: "Щитовая стена",
            goal: LevelGoal(type: .collect(kind: .shield, count: 22), moveLimit: 14),
            startMessage: "22 щита — серьёзный вызов. Думайте стратегически."
        ),
        LevelConfiguration(
            number: 11,
            title: "Звёздный дождь",
            goal: LevelGoal(type: .collect(kind: .star, count: 20), moveLimit: 11),
            startMessage: "Мало ходов, много звёзд. Спец-фишки — ваш друг."
        ),
        LevelConfiguration(
            number: 12,
            title: "Сад удачи",
            goal: LevelGoal(type: .collect(kind: .leaf, count: 22), moveLimit: 12),
            startMessage: "Клевер прячется. Ищите длинные цепочки."
        ),
        LevelConfiguration(
            number: 13,
            title: "Комната сокровищ",
            goal: LevelGoal(type: .reachScore(target: 1200), moveLimit: 13),
            startMessage: "1200 очков! Каждый ход должен быть точным."
        ),
        LevelConfiguration(
            number: 14,
            title: "Коронный марафон",
            goal: LevelGoal(type: .collect(kind: .crown, count: 28), moveLimit: 15),
            startMessage: "28 корон за 15 ходов. Нужны мощные комбинации."
        ),
        LevelConfiguration(
            number: 15,
            title: "Королевский финал",
            goal: LevelGoal(type: .reachScore(target: 1500), moveLimit: 12),
            startMessage: "Финальное испытание! 1500 очков. Покажите мастерство!"
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

    func currentMatches() -> Set<GridPosition> {
        allMatches()
    }

    func allMatchRuns() -> [MatchRun] {
        var runs: [MatchRun] = []

        for row in 0..<size {
            var startColumn = 0
            while startColumn < size {
                let kind = tiles[row][startColumn].kind
                var endColumn = startColumn + 1
                while endColumn < size, tiles[row][endColumn].kind == kind {
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
                let kind = tiles[startRow][column].kind
                var endRow = startRow + 1
                while endRow < size, tiles[endRow][column].kind == kind {
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
            spawns.append(PowerUpSpawn(position: pos, powerUp: .bomb))
            usedPositions.insert(pos)
        }

        for run in runs where run.positions.count >= 5 {
            let spawnPos = run.positions[run.positions.count / 2]
            if !usedPositions.contains(spawnPos) {
                spawns.append(PowerUpSpawn(position: spawnPos, powerUp: .bomb))
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

            while remainingTiles.count < size {
                let row = size - remainingTiles.count - 1
                let forbidden = forbiddenKinds(row: row, column: column, currentColumn: remainingTiles)
                remainingTiles.insert(Match3Tile(kind: Self.randomKind(avoiding: forbidden)), at: 0)
            }

            for row in 0..<removedCount {
                drops.append(TileDrop(column: column, fromRow: row - removedCount, toRow: row))
            }

            for row in 0..<size {
                tiles[row][column] = remainingTiles[row]
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

private struct MoveResult {
    let totalRemoved: Int
    let removedByKind: [TileKind: Int]
}

private struct TileDrop {
    let column: Int
    let fromRow: Int
    let toRow: Int
}

private enum SoundManager {
    enum Sound {
        case tileSelect
        case matchRemove
        case powerUpCreated
        case powerUpActivated
        case swapDenied
        case levelComplete
        case levelFailed

        var systemSoundID: SystemSoundID {
            switch self {
            case .tileSelect:       return 1104  // key press click
            case .matchRemove:      return 1025  // short pop
            case .powerUpCreated:   return 1054  // fanfare-like
            case .powerUpActivated: return 1109  // swoosh
            case .swapDenied:       return 1073  // negative beep
            case .levelComplete:    return 1335  // success chime
            case .levelFailed:      return 1257  // sad tone
            }
        }
    }

    static func play(_ sound: Sound) {
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
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

    func resetProgress() {
        UserDefaults.standard.set(0, forKey: unlockedLevelKey)
    }
}
