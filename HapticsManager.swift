import UIKit

struct HapticsManager {
    // Farklı hisler için farklı jeneratörler
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let successNotification = UINotificationFeedbackGenerator()
    private static let warningNotification = UINotificationFeedbackGenerator()
    private static let errorNotification = UINotificationFeedbackGenerator()
    private static let selectionFeedback = UISelectionFeedbackGenerator()
    
    enum FeedbackType {
        case light
        case medium
        case heavy
        case soft
        case rigid
        case success
        case warning
        case error
        case selection
    }
    
    // Standart buton tıklaması (geriye uyumluluk için)
    static func generateFeedback() {
        generateFeedback(.medium)
    }
    
    // Özelleştirilebilir feedback
    static func generateFeedback(_ type: FeedbackType) {
        switch type {
        case .light:
            lightImpact.prepare()
            lightImpact.impactOccurred()
        case .medium:
            mediumImpact.prepare()
            mediumImpact.impactOccurred()
        case .heavy:
            heavyImpact.prepare()
            heavyImpact.impactOccurred()
        case .soft:
            softImpact.prepare()
            softImpact.impactOccurred()
        case .rigid:
            rigidImpact.prepare()
            rigidImpact.impactOccurred()
        case .success:
            successNotification.prepare()
            successNotification.notificationOccurred(.success)
        case .warning:
            warningNotification.prepare()
            warningNotification.notificationOccurred(.warning)
        case .error:
            errorNotification.prepare()
            errorNotification.notificationOccurred(.error)
        case .selection:
            selectionFeedback.prepare()
            selectionFeedback.selectionChanged()
        }
    }
    
    // Başarılı bir eylem sonrası (geriye uyumluluk için)
    static func generateSuccessFeedback() {
        generateFeedback(.success)
    }
}
