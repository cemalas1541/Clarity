import Foundation
import AppIntents

@available(iOS 16.0, *)
struct ToggleTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Timer"
    static var description = IntentDescription("Start or pause timer")
    
    // Apple: "Open app for reliable interaction"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Set flag
        if let ud = UserDefaults(suiteName: "group.com.cemalas.Clarity") {
            ud.set("toggle", forKey: "pendingAction")
            ud.synchronize()
        }
        
        return .result()
    }
}

@available(iOS 16.0, *)
struct StartBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Break"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        if let ud = UserDefaults(suiteName: "group.com.cemalas.Clarity") {
            ud.set("toggle", forKey: "pendingAction")
            ud.synchronize()
        }
        
        return .result()
    }
}

@available(iOS 16.0, *)
struct ResetTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Timer"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        if let ud = UserDefaults(suiteName: "group.com.cemalas.Clarity") {
            ud.set("reset", forKey: "pendingAction")
            ud.synchronize()
        }
        
        return .result()
    }
}
