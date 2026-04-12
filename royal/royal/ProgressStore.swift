import Foundation

struct ProgressStore {
    private let unlockedLevelKey = "royal.unlockedLevelIndex"
    private let starsKeyPrefix = "royal.stars.level."
    private let decoratedKeyPrefix = "royal.room.decorated."
    private let spentStarsKey = "royal.spentStars"

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

    func saveStars(_ stars: Int, forLevel index: Int) {
        let key = starsKeyPrefix + "\(index)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(max(current, stars), forKey: key)
    }

    func stars(forLevel index: Int) -> Int {
        UserDefaults.standard.integer(forKey: starsKeyPrefix + "\(index)")
    }

    func totalStars(levelCount: Int) -> Int {
        (0..<levelCount).reduce(0) { $0 + stars(forLevel: $1) }
    }

    func spentStars() -> Int {
        UserDefaults.standard.integer(forKey: spentStarsKey)
    }

    func isRoomDecorated(index: Int) -> Bool {
        UserDefaults.standard.bool(forKey: decoratedKeyPrefix + "\(index)")
    }

    func decorateRoom(index: Int, cost: Int) {
        UserDefaults.standard.set(true, forKey: decoratedKeyPrefix + "\(index)")
        let current = UserDefaults.standard.integer(forKey: spentStarsKey)
        UserDefaults.standard.set(current + cost, forKey: spentStarsKey)
    }

    func resetProgress() {
        UserDefaults.standard.set(0, forKey: unlockedLevelKey)
        UserDefaults.standard.set(0, forKey: spentStarsKey)
        for i in 0..<40 {
            UserDefaults.standard.removeObject(forKey: starsKeyPrefix + "\(i)")
            UserDefaults.standard.removeObject(forKey: decoratedKeyPrefix + "\(i)")
        }
    }
}
