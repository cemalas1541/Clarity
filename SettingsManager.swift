import Foundation

struct SettingsManager {
    private static let key = "pomodoroSettingsKey"
    
    static func load() -> PomodoroSettings {
        if let data = UserDefaults.standard.data(forKey: key) {
            if let decodedSettings = try? JSONDecoder().decode(PomodoroSettings.self, from: data) {
                return decodedSettings
            }
        }
        // Hatanın olduğu kısım burasıydı.
        // Doğrusu, basitçe yeni bir PomodoroSettings nesnesi oluşturmaktır.
        return PomodoroSettings()
    }
    
    static func save(settings: PomodoroSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
