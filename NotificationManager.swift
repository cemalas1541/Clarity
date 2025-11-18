import Foundation
import UserNotifications

struct NotificationManager {
    
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            // İzin sonucu sessizce işleniyor
        }
    }
    
    static func scheduleNotification(state: PomodoroState, durationInSeconds: Int) {
        // Önce tüm bekleyen bildirimleri temizle
        cancelNotifications()
        
        // Geçersiz süre kontrolü
        guard durationInSeconds > 0 else { return }
        
        let content = UNMutableNotificationContent()
        
        switch state {
        case .working:
            content.title = NSLocalizedString("notification_timer_up_title", comment: "")
            content.body = NSLocalizedString("notification_work_session_body", comment: "")
        case .shortBreak, .longBreak:
            content.title = NSLocalizedString("notification_break_over_title", comment: "")
            content.body = NSLocalizedString("notification_new_session_body", comment: "")
        }
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "ClarityTimerNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
