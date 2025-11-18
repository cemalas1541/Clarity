import Foundation

// İstatistik ekranının kullandığı modeller
struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let date: Date
    let totalMinutes: Int
}

enum Timeframe: String, CaseIterable, Identifiable {
    case daily = "timeframe_daily"
    case weekly = "timeframe_weekly"
    case monthly = "timeframe_monthly"
    case yearly = "timeframe_yearly"
    
    var id: Self { self }
}

// Zamanlayıcı ve Kayıt Modeli
struct CompletedPomodoro: Codable, Identifiable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
    
    init(durationMinutes: Int) {
        self.id = UUID()
        self.date = Date()
        self.durationMinutes = durationMinutes
    }
}

// Ses Seçenekleri Modeli
enum SoundOption: String, CaseIterable, Identifiable, Codable {
    case digital = "timer_end"
    case bell = "bell"
    case chime = "chime"
    
    var id: Self { self }
    
    var displayKey: String {
        switch self {
        case .digital: return "sound_digital"
        case .bell: return "sound_bell"
        case .chime: return "sound_chime"
        }
    }
}

// YENİ: Appearance Mode
enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case light = "appearance_light"
    case dark = "appearance_dark"
    case system = "appearance_system"
    
    var id: Self { self }
    
    var displayKey: String {
        return self.rawValue
    }
}

// Ayarlar Modeli
struct PomodoroSettings: Codable {
    var workDuration: Int = 25
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 15
    var selectedSound: SoundOption = .digital
    var autoStartSessions: Bool = false
    var appearanceMode: AppearanceMode = .system  // YENİ EKLEME
    var enableFocusModeOnTimerStart: Bool = false  // Timer başladığında Focus Mode aç
}

// Yardımcı Uzantı
extension [CompletedPomodoro] {
    var totalMinutes: Int {
        return self.reduce(0) { $0 + $1.durationMinutes }
    }
}
