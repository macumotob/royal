import UIKit

extension ViewController {
    
    // MARK: - Level Management
    
    func startLevel(index: Int) {
        currentLevelIndex = max(0, min(index, levels.count - 1))
        board = Match3Board(size: boardSize, obstacles: currentLevel.obstacles)
        selectedPosition = nil
        movesCount = 0
        score = 0
        collectedGoalTiles = 0
        clearedObstacles = 0
        isLevelFinished = false
        isResolvingMove = false
        comboMultiplier = 1
        lastMatchTime = nil
        lastMatchStepScore = 0 // Добавлено: инициализация переменной
        renderBoard()
        showGameScreen()

        // Ensure the initial board has available moves
        if !board.hasAvailableMoves() {
            board.shuffle()
            renderBoard()
        }
    }

    func handleSwap(from: GridPosition, to: GridPosition) {
        guard !isResolvingMove, !isLevelFinished else { return }

        if board.tiles[from.row][from.column].obstacle != .none
            || board.tiles[to.row][to.column].obstacle != .none {
            SoundManager.play(.swapDenied)
            return
        }

        isResolvingMove = true
        animateSwap(from: from, to: to) { [weak self] in
            guard let self else { return }
            self.board.swapTiles(at: from, and: to)
            self.renderBoard()

            if self.board.hasMatches() {
                self.movesCount += 1
                self.updateStatus("Проверяем совпадение...")
                self.animateResolveChain(totalRemoved: 0, removedByKind: [:])
            } else {
                SoundManager.play(.swapDenied)

                self.animateSwap(from: from, to: to) { [weak self] in
                    guard let self else { return }
                    self.board.swapTiles(at: from, and: to)
                    self.isResolvingMove = false
                    self.renderBoard()
                }
            }
        }
    }
    
    // MARK: - Combo System
    
    func updateCombo() {
        if let lastTime = lastMatchTime, Date().timeIntervalSince(lastTime) < 0.5 {
            comboMultiplier = min(comboMultiplier + 1, 5)
        } else {
            comboMultiplier = 1
        }
        lastMatchTime = Date()
    }
    
    // MARK: - Obstacle Processing
    
    private func processObstacleDamage(at position: GridPosition) -> Int {
        var cleared = 0
        switch board.tiles[position.row][position.column].obstacle {
        case .ice(let hits) where hits > 1:
            board.tiles[position.row][position.column].obstacle = .ice(hits: hits - 1)
        case .ice, .chain:
            board.tiles[position.row][position.column].obstacle = .none
            cleared = 1
        case .none:
            break
        }
        return cleared
    }
    
    private func damageAdjacentObstacles(to expanded: Set<GridPosition>) -> Int {
        var cleared = 0
        var processed = Set<GridPosition>()
        
        for pos in expanded {
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let r = pos.row + dr
                let c = pos.column + dc
                guard r >= 0, r < boardSize, c >= 0, c < boardSize else { continue }
                let adj = GridPosition(row: r, column: c)
                guard !expanded.contains(adj), !processed.contains(adj) else { continue }
                processed.insert(adj)
                cleared += processObstacleDamage(at: adj)
            }
        }
        
        return cleared
    }
    
    // MARK: - Match Resolution Chain
    
    func animateResolveChain(totalRemoved: Int, removedByKind: [TileKind: Int], totalClearedObstacles: Int = 0) {
        let matched = board.currentMatches()
        guard !matched.isEmpty else {
            // Начисляем очки за этот шаг с учётом комбо
            updateCombo()
            let stepScore = totalRemoved * 10 * comboMultiplier
            
            // Бонус за уничтожение препятствий
            let obstacleBonus = totalClearedObstacles * 15
            let totalStepScore = stepScore + obstacleBonus
            
            score += totalStepScore
            clearedObstacles += totalClearedObstacles
            
            // Бонус за спец-фишки (суммируем)
            if lastMatchStepScore > 0 {
                score += lastMatchStepScore
                lastMatchStepScore = 0
            }
            
            switch currentLevel.goal.type {
            case .collect(let kind, _):
                collectedGoalTiles += removedByKind[kind, default: 0]
            case .reachScore, .clearObstacles:
                break
            }
            
            isResolvingMove = false
            renderBoard()

            let comboText = comboMultiplier > 1 ? " (x\(comboMultiplier) комбо!)" : ""
            updateStatus("Совпадение найдено! +\(totalStepScore) очков\(comboText). Всего удалено фишек: \(totalRemoved).")
            evaluateLevelState()

            if !isLevelFinished {
                checkForAvailableMoves()
            }
            return
        }
        
        let runs = board.allMatchRuns()
        let spawns = board.determinePowerUpSpawns(runs: runs, matched: matched)
        let expanded = board.expandWithPowerUps(matched)
        
        // Process obstacles on matched/expanded tiles
        var obstacleProtected = Set<GridPosition>()
        var stepClearedObstacles = 0
        
        for pos in expanded {
            switch board.tiles[pos.row][pos.column].obstacle {
            case .ice(let hits) where hits > 1:
                board.tiles[pos.row][pos.column].obstacle = .ice(hits: hits - 1)
                obstacleProtected.insert(pos)
            case .ice:
                board.tiles[pos.row][pos.column].obstacle = .none
                stepClearedObstacles += 1
            case .chain:
                board.tiles[pos.row][pos.column].obstacle = .none
                stepClearedObstacles += 1
            case .none:
                break
            }
        }
        
        // Damage obstacles adjacent to matched tiles
        stepClearedObstacles += damageAdjacentObstacles(to: expanded)
        
        var removalSet = expanded
        let spawnPositionSet = Set(spawns.map { $0.position })
        removalSet.subtract(spawnPositionSet)
        removalSet.subtract(obstacleProtected)
        
        var updatedByKind = removedByKind
        var powerUpBonus = 0
        
        // Подсчёт удалённых фишек (включая те, что на местах спавна спец-фишек)
        for pos in removalSet {
            updatedByKind[board.tiles[pos.row][pos.column].kind, default: 0] += 1
            
            // Бонус за уничтожение фишек с power-up
            if board.tiles[pos.row][pos.column].powerUp != .none {
                powerUpBonus += 25
            }
        }
        
        // Фишки на позициях спец-фишек тоже считаются собранными для цели collect
        for pos in spawnPositionSet {
            updatedByKind[board.tiles[pos.row][pos.column].kind, default: 0] += 1
        }
        
        let updatedTotal = totalRemoved + removalSet.count
        let updatedClearedObstacles = totalClearedObstacles + stepClearedObstacles
        
        // Суммируем бонус за спец-фишки (исправлено: теперь накапливается)
        lastMatchStepScore += powerUpBonus
        
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
                self.animateResolveChain(totalRemoved: updatedTotal, removedByKind: updatedByKind, totalClearedObstacles: updatedClearedObstacles)
            }
        }
    }

    func animateSwap(from a: GridPosition, to b: GridPosition, completion: @escaping () -> Void) {
        let buttonA = tileButtons[a.row][a.column]
        let buttonB = tileButtons[b.row][b.column]

        let centerA = buttonA.center
        let centerB = buttonB.center

        // Convert centers to the common superview coordinate space
        guard let parentA = buttonA.superview, let parentB = buttonB.superview else {
            completion()
            return
        }

        let globalA = parentA.convert(centerA, to: boardStackView)
        let globalB = parentB.convert(centerB, to: boardStackView)

        let dx = globalB.x - globalA.x
        let dy = globalB.y - globalA.y

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                buttonA.transform = CGAffineTransform(translationX: dx, y: dy)
                buttonB.transform = CGAffineTransform(translationX: -dx, y: -dy)
            },
            completion: { _ in
                buttonA.transform = .identity
                buttonB.transform = .identity
                completion()
            }
        )
    }

    func animateRemoval(at positions: Set<GridPosition>, completion: @escaping () -> Void) {
        // Добавлена проверка на пустой набор
        guard !positions.isEmpty else {
            completion()
            return
        }
        
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
        
        let group = DispatchGroup()
        
        for drop in drops {
            group.enter()
            let distance = CGFloat(drop.toRow - drop.fromRow)
            let duration = 0.2 + Double(abs(distance)) * 0.05
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    let button = self.tileButtons[drop.toRow][drop.column]
                    button.transform = .identity
                    button.alpha = 1
                },
                completion: { _ in
                    group.leave()
                }
            )
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // MARK: - Level Evaluation
    
    func evaluateLevelState() {
        let goalReached: Bool
        switch currentLevel.goal.type {
        case .collect(_, let count):
            goalReached = collectedGoalTiles >= count
        case .reachScore(let target):
            goalReached = score >= target
        case .clearObstacles(let count):
            goalReached = clearedObstacles >= count
        }
        
        if goalReached {
            isLevelFinished = true
            let remainingMoves = max(currentLevel.goal.moveLimit - movesCount, 0)
            let moveRatio = Double(remainingMoves) / Double(currentLevel.goal.moveLimit)
            let stars: Int
            if moveRatio >= 0.4 {
                stars = 3
            } else if moveRatio >= 0.15 {
                stars = 2
            } else {
                stars = 1
            }
            
            progressStore.unlockLevel(afterCompleting: currentLevelIndex, totalLevels: levels.count)
            progressStore.saveStars(stars, forLevel: currentLevelIndex)
            SoundManager.play(.levelComplete)
            
            let starsText = String(repeating: "⭐", count: stars)
            if currentLevelIndex + 1 < levels.count {
                updateStatus("Уровень \(currentLevel.number) пройден! \(starsText) Очки: \(score).")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                    guard let self else { return }
                    self.startLevel(index: self.currentLevelIndex + 1)
                }
            } else {
                showCompletionAlert(
                    title: "Победа \(starsText)",
                    message: "Все уровни пройдены! Финальный счёт: \(score)."
                )
            }
            return
        }
        
        if movesCount >= currentLevel.goal.moveLimit {
            isLevelFinished = true
            let details: String
            let tip: String
            switch currentLevel.goal.type {
            case .collect(let kind, let count):
                let remaining = count - collectedGoalTiles
                details = "Собрано \(collectedGoalTiles) из \(count) \(kind.symbol)."
                if remaining > 5 {
                    tip = "Совет: создавайте магниты (L/T-комбо) — они собирают все фишки одного цвета."
                } else {
                    tip = "Совет: осталось немного! Ищите длинные цепочки из \(kind.symbol)."
                }
            case .reachScore(let target):
                let remaining = target - score
                details = "Набрано \(score) из \(target) очков."
                if remaining > 500 {
                    tip = "Совет: ракеты и магниты дают больше очков. Старайтесь делать 4+ в ряд."
                } else {
                    tip = "Совет: почти получилось! Комбинируйте спец-фишки для мега-бонуса."
                }
            case .clearObstacles(let count):
                let remaining = count - clearedObstacles
                details = "Разбито \(clearedObstacles) из \(count) препятствий."
                if remaining > 3 {
                    tip = "Совет: делайте совпадения рядом с препятствиями. Ракеты бьют целый ряд!"
                } else {
                    tip = "Совет: осталось \(remaining) преград. Цельтесь точнее!"
                }
            }
            showCompletionAlert(
                title: "Ходы закончились",
                message: "Уровень \(currentLevel.number) не пройден.\n\n\(details)\n\n\(tip)"
            )
            SoundManager.play(.levelFailed)
        }
    }

    func checkForAvailableMoves() {
        guard !board.hasAvailableMoves() else { return }
        isResolvingMove = true
        updateStatus("Нет доступных ходов! Перемешиваем поле...")

        UIView.animate(withDuration: 0.3, animations: {
            for row in 0..<self.boardSize {
                for col in 0..<self.boardSize {
                    self.tileButtons[row][col].transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    self.tileButtons[row][col].alpha = 0
                }
            }
        }, completion: { _ in
            self.board.shuffle()
            self.renderBoard()

            for row in 0..<self.boardSize {
                for col in 0..<self.boardSize {
                    self.tileButtons[row][col].transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    self.tileButtons[row][col].alpha = 0
                }
            }

            UIView.animate(withDuration: 0.3, animations: {
                for row in 0..<self.boardSize {
                    for col in 0..<self.boardSize {
                        self.tileButtons[row][col].transform = .identity
                        self.tileButtons[row][col].alpha = 1
                    }
                }
            }, completion: { _ in
                self.isResolvingMove = false
                self.updateStatus("Поле перемешано! Продолжайте играть.")
            })
        })
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
}