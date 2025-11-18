import UIKit
import SwiftUI

// YENİ: Bu dosya, ClarityApp.swift ve SettingsView.swift'teki
// kod tekrarını önlemek için oluşturuldu.
struct AppearanceManager {
    
    static func applyAppearanceMode(_ mode: AppearanceMode) {
        // Aktif olan window sahnesini bul
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            
            // Eğer sahne hazır değilse (genellikle uygulama açılışında olur),
            // kısa bir gecikmeyle tekrar dene.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                applyAppearanceMode(mode)
            }
            return
        }
        
        let style: UIUserInterfaceStyle
        
        switch mode {
        case .light:
            style = .light
        case .dark:
            style = .dark
        case .system:
            style = .unspecified
        }
        
        // O sahnedeki tüm pencerelere stili uygula
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = style
        }
    }
}
