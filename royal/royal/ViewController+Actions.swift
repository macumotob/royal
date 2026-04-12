import UIKit

extension ViewController {
    @objc
    func didTapTile(_ sender: UIButton) {
        let position = GridPosition(row: sender.tag / boardSize, column: sender.tag % boardSize)
        handleSelection(at: position)
    }

    @objc
    func didPanBoard(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: boardStackView)
            swipeStartPoint = point
            swipeStartPosition = positionFromPoint(point)
        case .changed:
            guard let startPoint = swipeStartPoint, let startPos = swipeStartPosition else { return }
            let current = gesture.location(in: boardStackView)
            let dx = current.x - startPoint.x
            let dy = current.y - startPoint.y
            let threshold: CGFloat = 20
            guard max(abs(dx), abs(dy)) >= threshold else { return }

            let targetPos: GridPosition
            if abs(dx) > abs(dy) {
                targetPos = GridPosition(row: startPos.row, column: startPos.column + (dx > 0 ? 1 : -1))
            } else {
                targetPos = GridPosition(row: startPos.row + (dy > 0 ? 1 : -1), column: startPos.column)
            }

            swipeStartPoint = nil
            swipeStartPosition = nil

            guard targetPos.row >= 0, targetPos.row < boardSize,
                  targetPos.column >= 0, targetPos.column < boardSize else { return }

            selectedPosition = startPos
            handleSelection(at: targetPos)
        case .ended, .cancelled:
            swipeStartPoint = nil
            swipeStartPosition = nil
        default:
            break
        }
    }

    func positionFromPoint(_ point: CGPoint) -> GridPosition? {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let button = tileButtons[row][col]
                let frame = button.convert(button.bounds, to: boardStackView)
                if frame.contains(point) {
                    return GridPosition(row: row, column: col)
                }
            }
        }
        return nil
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
    func didTapCastle() {
        showCastleScreen()
    }

    @objc
    func didTapCastleBack() {
        showMapScreen()
    }

    @objc
    func didTapHelp() {
        let message = """
        ФИШКИ:
        👑 Корона  •  ♦️ Рубин  •  🛡 Щит
        ⭐️ Звезда  •  🍀 Клевер
        Совпадение 3+ в ряд — удаление.

        СПЕЦ-ФИШКИ:
        ➡️ Ракета → (4 в ряд ↔) — бьёт весь ряд
        ⬆️ Ракета ↑ (4 в ряд ↕) — бьёт весь столбец
        🧲 Магнит (L/T или 5+) — собирает все фишки того же цвета

        ПРЕПЯТСТВИЯ:
        ❄️ Лёд (1 слой) — 1 совпадение рядом разбивает
        🧊 Лёд (2 слоя) — нужно 2 совпадения
        ⛓️ Цепь — 1 совпадение рядом снимает
        Блокируют обмен фишки.
        """
        let alert = UIAlertController(title: "Подсказка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc
    func didTapSoundToggle() {
        SoundManager.toggleMute()
        let title = SoundManager.isMuted ? "🔇 Звук выкл" : "🔊 Звук вкл"
        soundToggleButton.configuration?.title = title
        if !SoundManager.isMuted {
            SoundManager.play(.tileSelect)
        }
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
    func didTapRoom(_ sender: UIButton) {
        let index = sender.tag
        let room = CastleRoom.allRooms[index]

        let totalStars = progressStore.totalStars(levelCount: levels.count)
        let spentStars = progressStore.spentStars()
        let availableStars = totalStars - spentStars

        guard availableStars >= room.cost else { return }

        progressStore.decorateRoom(index: index, cost: room.cost)
        SoundManager.play(.levelComplete)
        showCastleScreen()
    }

    @objc
    func didTapLevelButton(_ sender: UIButton) {
        startLevel(index: sender.tag)
    }
}
