//
//  ViewController.swift
//  royal
//
//  Created by Василий Букшован on 11.04.26.
//

import UIKit
import AudioToolbox

final class ViewController: UIViewController {
  let boardSize = 6
  let levels = LevelConfiguration.defaultLevels
  let progressStore = ProgressStore()
  
//  let titleLabel: UILabel = {
//    let label = UILabel()
//    label.translatesAutoresizingMaskIntoConstraints = false
//    label.text = "Royal Quest"
//    label.font = .systemFont(ofSize: 32, weight: .bold)
//    label.textColor = .white
//    label.textAlignment = .center
//    return label
//  }()
  
  let subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .white.withAlphaComponent(0.84)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let mapContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
    view.layer.cornerRadius = 24
    return view
  }()
  
  let mapProgressLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let levelButtonsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.alignment = .center
    return stackView
  }()
  
  let aboutButton: UIButton = {
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
  
  let soundToggleButton: UIButton = {
    var configuration = UIButton.Configuration.tinted()
    configuration.title = SoundManager.isMuted ? "🔇 Звук выкл" : "🔊 Звук вкл"
    configuration.baseBackgroundColor = .white.withAlphaComponent(0.16)
    configuration.baseForegroundColor = .white
    configuration.cornerStyle = .large
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
    
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = configuration
    return button
  }()
  
  let resetButton: UIButton = {
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
  
  let castleButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = "🏰 Замок"
    configuration.baseBackgroundColor = UIColor(red: 0.85, green: 0.65, blue: 0.2, alpha: 1.0)
    configuration.baseForegroundColor = .white
    configuration.cornerStyle = .large
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
    
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = configuration
    return button
  }()
  
  let castleContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
    view.layer.cornerRadius = 24
    view.isHidden = true
    return view
  }()
  
  let castleTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 20, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    label.text = "🏰 Королевский замок"
    return label
  }()
  
  let castleStarsLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15, weight: .semibold)
    label.textColor = .white.withAlphaComponent(0.84)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let roomsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.alignment = .fill
    return stackView
  }()
  
  let castleBackButton: UIButton = {
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
  
  var roomButtons: [UIButton] = []
  
  let gameContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  
  let progressLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let statusLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15, weight: .semibold)
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let boardContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
    view.layer.cornerRadius = 24
    return view
  }()
  
  let boardStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  let shuffleButton: UIButton = {
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
  
  let helpButton: UIButton = {
    var configuration = UIButton.Configuration.tinted()
    configuration.title = "❓"
    configuration.baseBackgroundColor = .white.withAlphaComponent(0.16)
    configuration.baseForegroundColor = .white
    configuration.cornerStyle = .capsule
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
    
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration = configuration
    return button
  }()
  
  let mapButton: UIButton = {
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
  
  var tileButtons: [[UIButton]] = []
  var board = Match3Board(size: 6)
  var selectedPosition: GridPosition?
  var swipeStartPoint: CGPoint?
  var swipeStartPosition: GridPosition?
  var movesCount = 0
  var score = 0
  var collectedGoalTiles = 0
  var clearedObstacles = 0
  var isLevelFinished = false
  var isResolvingMove = false
  var currentLevelIndex = 0
  var levelButtons: [UIButton] = []
  var levelStarLabels: [UILabel] = []
  let levelsPerRow = 5
  
  // Combo system
  var comboMultiplier = 1
  var lastMatchTime: Date?
  var lastMatchStepScore = 0
  
  var currentLevel: LevelConfiguration {
    levels[currentLevelIndex]
  }

  var effectiveMoveLimit: Int {
    currentLevel.goal.moveLimit + progressStore.bonusMoves(forLevel: currentLevelIndex)
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
