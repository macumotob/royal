struct CastleRoom {
    let name: String
    let icon: String
    let cost: Int

    static let allRooms: [CastleRoom] = [
        CastleRoom(name: "Тронный зал", icon: "👑", cost: 3),
        CastleRoom(name: "Королевская спальня", icon: "🛏", cost: 4),
        CastleRoom(name: "Банкетный зал", icon: "🍽", cost: 5),
        CastleRoom(name: "Библиотека", icon: "📚", cost: 5),
        CastleRoom(name: "Сад", icon: "🌺", cost: 6),
        CastleRoom(name: "Башня мага", icon: "🧙", cost: 7),
        CastleRoom(name: "Сокровищница", icon: "💰", cost: 8),
    ]
}
