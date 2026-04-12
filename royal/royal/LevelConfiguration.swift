struct LevelConfiguration {
    let number: Int
    let title: String
    let goal: LevelGoal
    let startMessage: String
    let obstacles: [(GridPosition, Obstacle)]

    init(number: Int, title: String, goal: LevelGoal, startMessage: String, obstacles: [(GridPosition, Obstacle)] = []) {
        self.number = number
        self.title = title
        self.goal = goal
        self.startMessage = startMessage
        self.obstacles = obstacles
    }

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
            goal: LevelGoal(type: .collect(kind: .crown, count: 18), moveLimit: 15),
            startMessage: "Лёд блокирует фишки! Совпадения рядом разбивают его.",
            obstacles: [
                (GridPosition(row: 1, column: 1), .ice(hits: 1)),
                (GridPosition(row: 1, column: 4), .ice(hits: 1)),
                (GridPosition(row: 4, column: 1), .ice(hits: 1)),
                (GridPosition(row: 4, column: 4), .ice(hits: 1)),
            ]
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
            goal: LevelGoal(type: .collect(kind: .shield, count: 22), moveLimit: 16),
            startMessage: "Цепи не дают двигать фишки. Собирайте совпадения рядом!",
            obstacles: [
                (GridPosition(row: 0, column: 2), .chain),
                (GridPosition(row: 0, column: 3), .chain),
                (GridPosition(row: 5, column: 2), .chain),
                (GridPosition(row: 5, column: 3), .chain),
            ]
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
            title: "Ледяной замок",
            goal: LevelGoal(type: .clearObstacles(count: 8), moveLimit: 15),
            startMessage: "Разбейте все преграды! Лёд и цепи блокируют поле.",
            obstacles: [
                (GridPosition(row: 0, column: 1), .ice(hits: 1)),
                (GridPosition(row: 0, column: 4), .ice(hits: 1)),
                (GridPosition(row: 1, column: 2), .ice(hits: 2)),
                (GridPosition(row: 1, column: 3), .ice(hits: 2)),
                (GridPosition(row: 4, column: 2), .chain),
                (GridPosition(row: 4, column: 3), .chain),
                (GridPosition(row: 5, column: 1), .ice(hits: 1)),
                (GridPosition(row: 5, column: 4), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 14,
            title: "Коронный марафон",
            goal: LevelGoal(type: .collect(kind: .crown, count: 28), moveLimit: 17),
            startMessage: "28 корон! Лёд и цепи мешают. Используйте спец-фишки!",
            obstacles: [
                (GridPosition(row: 1, column: 0), .ice(hits: 2)),
                (GridPosition(row: 1, column: 5), .ice(hits: 2)),
                (GridPosition(row: 2, column: 2), .chain),
                (GridPosition(row: 3, column: 3), .chain),
            ]
        ),
        LevelConfiguration(
            number: 15,
            title: "Королевский финал",
            goal: LevelGoal(type: .reachScore(target: 1500), moveLimit: 14),
            startMessage: "Финальное испытание! Преграды повсюду. Покажите мастерство!",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 2)),
                (GridPosition(row: 0, column: 5), .ice(hits: 2)),
                (GridPosition(row: 2, column: 1), .chain),
                (GridPosition(row: 2, column: 4), .chain),
                (GridPosition(row: 3, column: 1), .ice(hits: 1)),
                (GridPosition(row: 3, column: 4), .ice(hits: 1)),
                (GridPosition(row: 5, column: 0), .ice(hits: 2)),
                (GridPosition(row: 5, column: 5), .ice(hits: 2)),
            ]
        ),
        // --- Act II: Магнит ---
        LevelConfiguration(
            number: 16,
            title: "Магнитное поле",
            goal: LevelGoal(type: .collect(kind: .ruby, count: 24), moveLimit: 14),
            startMessage: "L/Т-комбо создаёт магнит 🧲 — собирает все фишки одного цвета!"
        ),
        LevelConfiguration(
            number: 17,
            title: "Ледяной лабиринт",
            goal: LevelGoal(type: .clearObstacles(count: 6), moveLimit: 14),
            startMessage: "Лёд повсюду. Магнит поможет расчистить путь!",
            obstacles: [
                (GridPosition(row: 0, column: 1), .ice(hits: 1)),
                (GridPosition(row: 0, column: 4), .ice(hits: 1)),
                (GridPosition(row: 2, column: 0), .ice(hits: 2)),
                (GridPosition(row: 2, column: 5), .ice(hits: 2)),
                (GridPosition(row: 4, column: 2), .ice(hits: 1)),
                (GridPosition(row: 4, column: 3), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 18,
            title: "Цепной мост",
            goal: LevelGoal(type: .collect(kind: .shield, count: 20), moveLimit: 13),
            startMessage: "Цепи перекрыли мост. Освободите щиты!",
            obstacles: [
                (GridPosition(row: 1, column: 1), .chain),
                (GridPosition(row: 1, column: 4), .chain),
                (GridPosition(row: 2, column: 2), .chain),
                (GridPosition(row: 3, column: 3), .chain),
                (GridPosition(row: 4, column: 1), .chain),
                (GridPosition(row: 4, column: 4), .chain),
            ]
        ),
        LevelConfiguration(
            number: 19,
            title: "Звёздная ночь",
            goal: LevelGoal(type: .collect(kind: .star, count: 22), moveLimit: 12),
            startMessage: "Соберите звёзды! Создавайте магниты для массового сбора."
        ),
        LevelConfiguration(
            number: 20,
            title: "Тысяча очков",
            goal: LevelGoal(type: .reachScore(target: 1000), moveLimit: 11),
            startMessage: "1000 очков за 11 ходов. Магнит — ваш лучший друг!",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 1)),
                (GridPosition(row: 0, column: 5), .ice(hits: 1)),
                (GridPosition(row: 5, column: 0), .ice(hits: 1)),
                (GridPosition(row: 5, column: 5), .ice(hits: 1)),
            ]
        ),
        // --- Act III: Сложные комбинации ---
        LevelConfiguration(
            number: 21,
            title: "Корона во льду",
            goal: LevelGoal(type: .collect(kind: .crown, count: 25), moveLimit: 15),
            startMessage: "Короны заморожены. Растопите лёд и соберите их!",
            obstacles: [
                (GridPosition(row: 1, column: 1), .ice(hits: 2)),
                (GridPosition(row: 1, column: 2), .ice(hits: 1)),
                (GridPosition(row: 1, column: 3), .ice(hits: 1)),
                (GridPosition(row: 1, column: 4), .ice(hits: 2)),
                (GridPosition(row: 4, column: 1), .ice(hits: 2)),
                (GridPosition(row: 4, column: 4), .ice(hits: 2)),
            ]
        ),
        LevelConfiguration(
            number: 22,
            title: "Рубиновая крепость",
            goal: LevelGoal(type: .collect(kind: .ruby, count: 28), moveLimit: 16),
            startMessage: "Крепость окружена цепями и льдом. Прорывайтесь!",
            obstacles: [
                (GridPosition(row: 0, column: 2), .chain),
                (GridPosition(row: 0, column: 3), .chain),
                (GridPosition(row: 2, column: 0), .ice(hits: 2)),
                (GridPosition(row: 2, column: 5), .ice(hits: 2)),
                (GridPosition(row: 3, column: 0), .ice(hits: 1)),
                (GridPosition(row: 3, column: 5), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 23,
            title: "Зелёный лабиринт",
            goal: LevelGoal(type: .clearObstacles(count: 10), moveLimit: 16),
            startMessage: "10 преград! Используйте ракеты и магниты.",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 1)),
                (GridPosition(row: 0, column: 5), .ice(hits: 1)),
                (GridPosition(row: 1, column: 2), .chain),
                (GridPosition(row: 1, column: 3), .chain),
                (GridPosition(row: 2, column: 1), .ice(hits: 2)),
                (GridPosition(row: 2, column: 4), .ice(hits: 2)),
                (GridPosition(row: 3, column: 1), .chain),
                (GridPosition(row: 3, column: 4), .chain),
                (GridPosition(row: 5, column: 0), .ice(hits: 1)),
                (GridPosition(row: 5, column: 5), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 24,
            title: "Щитовой турнир",
            goal: LevelGoal(type: .collect(kind: .shield, count: 30), moveLimit: 17),
            startMessage: "30 щитов! Лёд и цепи на поле. Думайте на 2 хода вперёд.",
            obstacles: [
                (GridPosition(row: 0, column: 1), .ice(hits: 1)),
                (GridPosition(row: 0, column: 4), .ice(hits: 1)),
                (GridPosition(row: 2, column: 2), .chain),
                (GridPosition(row: 3, column: 3), .chain),
                (GridPosition(row: 5, column: 1), .ice(hits: 2)),
                (GridPosition(row: 5, column: 4), .ice(hits: 2)),
            ]
        ),
        LevelConfiguration(
            number: 25,
            title: "Звёздный гейзер",
            goal: LevelGoal(type: .reachScore(target: 1800), moveLimit: 14),
            startMessage: "1800 очков! Спец-фишки — ключ к победе.",
            obstacles: [
                (GridPosition(row: 1, column: 0), .ice(hits: 2)),
                (GridPosition(row: 1, column: 5), .ice(hits: 2)),
                (GridPosition(row: 4, column: 0), .ice(hits: 2)),
                (GridPosition(row: 4, column: 5), .ice(hits: 2)),
            ]
        ),
        // --- Act IV: Мастерство ---
        LevelConfiguration(
            number: 26,
            title: "Двойной лёд",
            goal: LevelGoal(type: .clearObstacles(count: 12), moveLimit: 18),
            startMessage: "Двойной лёд повсюду! Каждый ход на счету.",
            obstacles: [
                (GridPosition(row: 0, column: 1), .ice(hits: 2)),
                (GridPosition(row: 0, column: 4), .ice(hits: 2)),
                (GridPosition(row: 1, column: 0), .ice(hits: 2)),
                (GridPosition(row: 1, column: 5), .ice(hits: 2)),
                (GridPosition(row: 2, column: 2), .ice(hits: 2)),
                (GridPosition(row: 2, column: 3), .ice(hits: 2)),
                (GridPosition(row: 3, column: 2), .ice(hits: 2)),
                (GridPosition(row: 3, column: 3), .ice(hits: 2)),
                (GridPosition(row: 4, column: 0), .ice(hits: 2)),
                (GridPosition(row: 4, column: 5), .ice(hits: 2)),
                (GridPosition(row: 5, column: 1), .ice(hits: 2)),
                (GridPosition(row: 5, column: 4), .ice(hits: 2)),
            ]
        ),
        LevelConfiguration(
            number: 27,
            title: "Клеверный шторм",
            goal: LevelGoal(type: .collect(kind: .leaf, count: 30), moveLimit: 15),
            startMessage: "Шторм принёс клевер. Собирайте быстро!",
            obstacles: [
                (GridPosition(row: 1, column: 1), .chain),
                (GridPosition(row: 1, column: 4), .chain),
                (GridPosition(row: 4, column: 1), .chain),
                (GridPosition(row: 4, column: 4), .chain),
            ]
        ),
        LevelConfiguration(
            number: 28,
            title: "Магнитная буря",
            goal: LevelGoal(type: .reachScore(target: 2000), moveLimit: 13),
            startMessage: "2000 очков! Создавайте магниты из L/T-комбинаций.",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 1)),
                (GridPosition(row: 0, column: 5), .ice(hits: 1)),
                (GridPosition(row: 2, column: 1), .ice(hits: 2)),
                (GridPosition(row: 2, column: 4), .ice(hits: 2)),
                (GridPosition(row: 3, column: 1), .chain),
                (GridPosition(row: 3, column: 4), .chain),
                (GridPosition(row: 5, column: 0), .ice(hits: 1)),
                (GridPosition(row: 5, column: 5), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 29,
            title: "Последняя крепость",
            goal: LevelGoal(type: .clearObstacles(count: 14), moveLimit: 18),
            startMessage: "14 преград! Магниты и ракеты — ваше оружие.",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 2)),
                (GridPosition(row: 0, column: 2), .chain),
                (GridPosition(row: 0, column: 3), .chain),
                (GridPosition(row: 0, column: 5), .ice(hits: 2)),
                (GridPosition(row: 1, column: 1), .ice(hits: 1)),
                (GridPosition(row: 1, column: 4), .ice(hits: 1)),
                (GridPosition(row: 2, column: 2), .ice(hits: 2)),
                (GridPosition(row: 2, column: 3), .ice(hits: 2)),
                (GridPosition(row: 3, column: 2), .ice(hits: 2)),
                (GridPosition(row: 3, column: 3), .ice(hits: 2)),
                (GridPosition(row: 4, column: 1), .chain),
                (GridPosition(row: 4, column: 4), .chain),
                (GridPosition(row: 5, column: 0), .ice(hits: 1)),
                (GridPosition(row: 5, column: 5), .ice(hits: 1)),
            ]
        ),
        LevelConfiguration(
            number: 30,
            title: "Королевский триумф",
            goal: LevelGoal(type: .reachScore(target: 2500), moveLimit: 15),
            startMessage: "Финал второго акта! 2500 очков. Вы — мастер Royal Quest!",
            obstacles: [
                (GridPosition(row: 0, column: 0), .ice(hits: 2)),
                (GridPosition(row: 0, column: 5), .ice(hits: 2)),
                (GridPosition(row: 1, column: 2), .chain),
                (GridPosition(row: 1, column: 3), .chain),
                (GridPosition(row: 2, column: 0), .ice(hits: 2)),
                (GridPosition(row: 2, column: 5), .ice(hits: 2)),
                (GridPosition(row: 3, column: 0), .chain),
                (GridPosition(row: 3, column: 5), .chain),
                (GridPosition(row: 4, column: 2), .ice(hits: 2)),
                (GridPosition(row: 4, column: 3), .ice(hits: 2)),
                (GridPosition(row: 5, column: 0), .ice(hits: 2)),
                (GridPosition(row: 5, column: 5), .ice(hits: 2)),
            ]
        )
    ]
}
