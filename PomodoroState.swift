import SwiftUI

enum PomodoroState: String, Codable, CaseIterable, Hashable {
    case working = "working"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"
    
    var displayKey: String {
        switch self {
        case .working: return "state_working"
        case .shortBreak: return "state_short_break"
        case .longBreak: return "state_long_break"
        }
    }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .working: return "state_working"
        case .shortBreak: return "state_short_break"
        case .longBreak: return "state_long_break"
        }
    }
    
    var icon: String {
        switch self {
        case .working: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "moon.stars.fill"
        }
    }
    
    func accentColor(for theme: Theme) -> Color {
        return theme.accentColor
    }
    
    var sessionDotsCount: Int {
        return 4
    }
    
    func isDotCompleted(dotIndex: Int, completedSessions: Int) -> Bool {
        let currentSessionIndex = completedSessions % 4
        return dotIndex < currentSessionIndex
    }
    
    func isDotCurrent(dotIndex: Int, completedSessions: Int, isTimerActive: Bool) -> Bool {
        let currentSessionIndex = completedSessions % 4
        return dotIndex == currentSessionIndex && isTimerActive && self == .working
    }
}
