import Foundation

struct StatsManager {
    private static let key = "completedPomodoroSessionsKey" // AnahtarÄ± deÄŸiÅŸtirmek iyi bir pratik olabilir
    
    static func loadSessions() -> [CompletedPomodoro] {
        if let data = UserDefaults.standard.data(forKey: key) {
            if let sessions = try? JSONDecoder().decode([CompletedPomodoro].self, from: data) {
                return sessions
            }
        }
        return []
    }
    
    static func save(session: CompletedPomodoro) {
        var allSessions = loadSessions()
        allSessions.append(session)
        
        if let data = try? JSONEncoder().encode(allSessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func clearAllStats() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
