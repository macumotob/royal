import AudioToolbox

enum SoundManager {
    private static let muteKey = "royal.isMuted"

    static var isMuted: Bool {
        UserDefaults.standard.bool(forKey: muteKey)
    }

    static func toggleMute() {
        UserDefaults.standard.set(!isMuted, forKey: muteKey)
    }

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
            case .tileSelect:       return 1104
            case .matchRemove:      return 1025
            case .powerUpCreated:   return 1054
            case .powerUpActivated: return 1109
            case .swapDenied:       return 1073
            case .levelComplete:    return 1335
            case .levelFailed:      return 1257
            }
        }
    }

    static func play(_ sound: Sound) {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
}
