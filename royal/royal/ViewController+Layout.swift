import UIKit

extension ViewController {
    func configureView() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.21, blue: 0.52, alpha: 1.0)
    }

    func layoutInterface() {
        // Map screen
        let mapInnerStack = UIStackView(arrangedSubviews: [mapProgressLabel, levelButtonsStackView, castleButton, soundToggleButton, aboutButton, resetButton])
        mapInnerStack.translatesAutoresizingMaskIntoConstraints = false
        mapInnerStack.axis = .vertical
        mapInnerStack.spacing = 16
        mapInnerStack.alignment = .center

        mapContainerView.addSubview(mapInnerStack)

        // Castle screen
        let castleInnerStack = UIStackView(arrangedSubviews: [castleTitleLabel, castleStarsLabel, roomsStackView, castleBackButton])
        castleInnerStack.translatesAutoresizingMaskIntoConstraints = false
        castleInnerStack.axis = .vertical
        castleInnerStack.spacing = 16
        castleInnerStack.alignment = .fill

        castleContainerView.addSubview(castleInnerStack)

        // Game screen
        let gameButtonsStack = UIStackView(arrangedSubviews: [shuffleButton, mapButton])
        gameButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        gameButtonsStack.axis = .vertical
        gameButtonsStack.spacing = 14

        let topGameBar = UIStackView(arrangedSubviews: [progressLabel, helpButton])
        topGameBar.translatesAutoresizingMaskIntoConstraints = false
        topGameBar.axis = .horizontal
        topGameBar.spacing = 8
        topGameBar.alignment = .center

        boardContainerView.addSubview(boardStackView)

        let gameStack = UIStackView(arrangedSubviews: [topGameBar, statusLabel, boardContainerView, gameButtonsStack])
        gameStack.translatesAutoresizingMaskIntoConstraints = false
        gameStack.axis = .vertical
        gameStack.spacing = 18

        gameContainerView.addSubview(gameStack)

        // Main scroll view wrapping everything
        let contentStack = UIStackView(arrangedSubviews: [subtitleLabel, mapContainerView, castleContainerView, gameContainerView])
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

            castleButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            castleButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            aboutButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            aboutButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            soundToggleButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            soundToggleButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            resetButton.leadingAnchor.constraint(equalTo: mapInnerStack.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: mapInnerStack.trailingAnchor),

            castleInnerStack.topAnchor.constraint(equalTo: castleContainerView.topAnchor, constant: 20),
            castleInnerStack.leadingAnchor.constraint(equalTo: castleContainerView.leadingAnchor, constant: 20),
            castleInnerStack.trailingAnchor.constraint(equalTo: castleContainerView.trailingAnchor, constant: -20),
            castleInnerStack.bottomAnchor.constraint(equalTo: castleContainerView.bottomAnchor, constant: -20),

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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanBoard(_:)))
        boardStackView.addGestureRecognizer(panGesture)

        for row in 0..<boardSize {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 8
            rowStackView.distribution = .fillEqually

            var rowButtons: [UIButton] = []

            for column in 0..<boardSize {
                let button = UIButton(type: .custom)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.tag = row * boardSize + column
                button.layer.cornerRadius = 14
                button.clipsToBounds = true
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = false
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
        levelStarLabels.removeAll()

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

            let cellStack = UIStackView()
            cellStack.axis = .vertical
            cellStack.spacing = 2
            cellStack.alignment = .center

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

            let starLabel = UILabel()
            starLabel.font = .systemFont(ofSize: 10)
            starLabel.textAlignment = .center
            starLabel.text = ""

            cellStack.addArrangedSubview(button)
            cellStack.addArrangedSubview(starLabel)

            currentRow?.addArrangedSubview(cellStack)
            levelButtons.append(button)
            levelStarLabels.append(starLabel)
        }

        let lastRowCount = levels.count % levelsPerRow
        if lastRowCount > 0, let lastRow = currentRow {
            for _ in 0..<(levelsPerRow - lastRowCount) {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                spacer.widthAnchor.constraint(equalToConstant: 52).isActive = true
                let cellStack = UIStackView()
                cellStack.axis = .vertical
                cellStack.spacing = 2
                cellStack.alignment = .center
                cellStack.addArrangedSubview(spacer)
                cellStack.addArrangedSubview(UILabel())
                lastRow.addArrangedSubview(cellStack)
            }
        }
    }

    func wireActions() {
        aboutButton.addTarget(self, action: #selector(didTapAbout), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(didTapMap), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        soundToggleButton.addTarget(self, action: #selector(didTapSoundToggle), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(didTapHelp), for: .touchUpInside)
        castleButton.addTarget(self, action: #selector(didTapCastle), for: .touchUpInside)
        castleBackButton.addTarget(self, action: #selector(didTapCastleBack), for: .touchUpInside)
    }
}
