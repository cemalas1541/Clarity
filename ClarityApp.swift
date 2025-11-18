import SwiftUI
import AVFoundation
import UserNotifications // Bunu eklemek iyi bir pratik

@main
struct ClarityApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var themeManager = ThemeManager()
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        setupAudioSession()
        // Bildirim iznini istemek için de iyi bir yer
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(themeManager)
                    // DÜZELTME: Artık merkezi AppearanceManager'ı çağırıyor
                    .onAppear(perform: applyAppearanceMode)
            } else {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
                .environmentObject(themeManager)
                // DÜZELTME: Artık merkezi AppearanceManager'ı çağırıyor
                .onAppear(perform: applyAppearanceMode)
            }
        }
    }
    
    // DÜZELTME: Fonksiyon artık merkezi AppearanceManager'ı çağırıyor.
    private func applyAppearanceMode() {
        let settings = SettingsManager.load()
        AppearanceManager.applyAppearanceMode(settings.appearanceMode)
    }
    
    private func setupAudioSession() {
        do {
            // .playback kategorisi, uygulamanın arka planda ses çalacağını belirtir
            // .mixWithOthers seçeneği, kullanıcının Spotify vb. dinlerken
            // sizin uygulamanızın seslerinin (örn. bitiş sesi) de çalınmasını sağlar.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Hata durumunda sessiz kal (genelde simülatörde olur)
        }
    }
}
