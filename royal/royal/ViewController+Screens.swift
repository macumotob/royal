import UIKit

extension ViewController {
  func showMapScreen() {
    mapContainerView.isHidden = false
    castleContainerView.isHidden = true
    gameContainerView.isHidden = true
    subtitleLabel.text = "Выберите открытый уровень и начните прохождение."
    
    let unlockedCount = progressStore.unlockedLevelCount(totalLevels: levels.count)
    let totalStars = progressStore.totalStars(levelCount: levels.count)
    mapProgressLabel.text = "Открыто уровней: \(unlockedCount) из \(levels.count)  |  ⭐ \(totalStars)"
    
    for (index, button) in levelButtons.enumerated() {
      let unlocked = index < unlockedCount
      let stars = progressStore.stars(forLevel: index)
      
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
      
      if stars > 0 {
        levelStarLabels[index].text = String(repeating: "⭐", count: stars)
      } else {
        levelStarLabels[index].text = ""
      }
      
      button.configuration = nil
      button.isEnabled = unlocked
    }
  }
  
  func showGameScreen() {
    mapContainerView.isHidden = true
    castleContainerView.isHidden = true
    gameContainerView.isHidden = false
    updateStatus(currentLevel.startMessage)
  }
  
  func showCastleScreen() {
    mapContainerView.isHidden = true
    castleContainerView.isHidden = false
    gameContainerView.isHidden = true
    subtitleLabel.text = "Оформляйте замок за звёзды"
    
    let totalStars = progressStore.totalStars(levelCount: levels.count)
    let spentStars = progressStore.spentStars()
    let availableStars = totalStars - spentStars
    castleStarsLabel.text = "Доступно звёзд: \(availableStars)  |  Всего: \(totalStars)"
    
    buildRooms(availableStars: availableStars)
  }
  
  func buildRooms(availableStars: Int) {
    roomsStackView.arrangedSubviews.forEach { v in
      roomsStackView.removeArrangedSubview(v)
      v.removeFromSuperview()
    }
    roomButtons.removeAll()
    
    let rooms = CastleRoom.allRooms
    for (index, room) in rooms.enumerated() {
      let decorated = progressStore.isRoomDecorated(index: index)
      let canAfford = availableStars >= room.cost
      
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.tag = index
      button.layer.cornerRadius = 14
      button.clipsToBounds = true
      button.heightAnchor.constraint(equalToConstant: 56).isActive = true
      
      if decorated {
        button.setTitle("\(room.icon) \(room.name) — Оформлено ✅", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        button.isEnabled = false
      } else if canAfford {
        button.setTitle("\(room.icon) \(room.name) — \(room.cost) ⭐", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.85, green: 0.65, blue: 0.2, alpha: 1.0)
        button.addTarget(self, action: #selector(didTapRoom(_:)), for: .touchUpInside)
        button.isEnabled = true
      } else {
        button.setTitle("\(room.icon) \(room.name) — \(room.cost) ⭐", for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        button.isEnabled = false
      }
      
      button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
      roomsStackView.addArrangedSubview(button)
      roomButtons.append(button)
    }
  }
  
  func renderBoard() {
    let gemSize: CGFloat = 60
    
    for row in 0..<boardSize {
      for column in 0..<boardSize {
        let tile = board.tiles[row][column]
        let button = tileButtons[row][column]
        
        button.setTitle(nil, for: .normal)
        button.backgroundColor = .clear
        button.transform = .identity
        
        // Remove old overlay views (tagged 100 for power-up, 101 for obstacle)
        button.viewWithTag(100)?.removeFromSuperview()
        button.viewWithTag(101)?.removeFromSuperview()
        
        // Gem image
        let gemImg = GemRenderer.shared.gemImage(for: tile.kind, size: gemSize)
        button.setImage(gemImg, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        // Power-up overlay
        if tile.powerUp != .none, tile.obstacle == .none,
           let puImg = GemRenderer.shared.powerUpImage(for: tile.powerUp, size: gemSize) {
          let overlay = UIImageView(image: puImg)
          overlay.tag = 100
          overlay.contentMode = .scaleAspectFit
          overlay.translatesAutoresizingMaskIntoConstraints = false
          overlay.isUserInteractionEnabled = false
          button.addSubview(overlay)
          NSLayoutConstraint.activate([
            overlay.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            overlay.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            overlay.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7),
            overlay.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.7)
          ])
        }
        
        // Obstacle overlay
        if tile.obstacle != .none,
           let obsImg = GemRenderer.shared.obstacleImage(for: tile.obstacle, size: gemSize) {
          let overlay = UIImageView(image: obsImg)
          overlay.tag = 101
          overlay.contentMode = .scaleAspectFit
          overlay.translatesAutoresizingMaskIntoConstraints = false
          overlay.isUserInteractionEnabled = false
          button.addSubview(overlay)
          NSLayoutConstraint.activate([
            overlay.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            overlay.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            overlay.widthAnchor.constraint(equalTo: button.widthAnchor),
            overlay.heightAnchor.constraint(equalTo: button.heightAnchor)
          ])
        }
        
        // Border state
        let hasPowerUp = tile.powerUp != .none
        let hasObstacle = tile.obstacle != .none

        if hasObstacle {
          button.layer.borderWidth = 2
          if case .chain = tile.obstacle {
            button.layer.borderColor = UIColor.gray.cgColor
          } else {
            button.layer.borderColor = UIColor.cyan.cgColor
          }
          button.alpha = 1.0
        } else if hasPowerUp {
          button.layer.borderWidth = 2
          button.layer.borderColor = UIColor.yellow.cgColor
          button.alpha = 1.0
        } else {
          button.layer.borderWidth = 0
          button.layer.borderColor = nil
          button.alpha = 1.0
        }
      }
    }
  }
  
  func updateStatus(_ text: String) {
    let remainingMoves = max(currentLevel.goal.moveLimit - movesCount, 0)
    subtitleLabel.text = "Уровень \(currentLevel.number): \(currentLevel.title)"
    
    switch currentLevel.goal.type {
    case .collect(let kind, let count):
      progressLabel.text = "Цель: \(count) \(kind.symbol) за \(currentLevel.goal.moveLimit) ходов  |  Собрано: \(collectedGoalTiles)/\(count)"
    case .reachScore(let target):
      progressLabel.text = "Цель: \(target) очков за \(currentLevel.goal.moveLimit) ходов  |  Набрано: \(score)/\(target)"
    case .clearObstacles(let count):
      progressLabel.text = "Цель: разбить \(count) преград за \(currentLevel.goal.moveLimit) ходов  |  Разбито: \(clearedObstacles)/\(count)"
    }
    
    let comboText = comboMultiplier > 1 ? "  |  x\(comboMultiplier) комбо!" : ""
//    statusLabel.text = "Очки: \(score)  |  Ходов осталось: \(remainingMoves)\n\(text)\(comboText)"
    statusLabel.text = "Очки: \(score)  |  Ходов осталось: \(remainingMoves)"
  }
}
