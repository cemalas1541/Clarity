import Foundation
import SwiftUI
import Combine
import ActivityKit // Önemli

@MainActor
class PomodoroViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var timeRemaining: Int = 0
    @Published var isActive: Bool = false
    @Published var pomodoroState: PomodoroState = .working
    @Published var completedPomodoros: Int = 0
    @Published var sessionTotalDuration: Int = 0
    @Published var currentSettings: PomodoroSettings
    @Published var selectedTab: String = "tab_focus"
    @Published var isShowingSkipAlert = false
    @Published var isShowingResetAlert = false
    
    // MARK: - Private
    private var timer: Timer?
    private var endDate: Date?
    // Live Activity referansı
    private var currentActivity: Activity<ClarityActivityAttributes>?
    
    weak var themeManager: ThemeManager?
    
    var minutesSpent: Int {
        (sessionTotalDuration - timeRemaining) / 60
    }
    
    // MARK: - Init
    init() {
        let settings = SettingsManager.load()
        _currentSettings = Published(initialValue: settings)
        
        let duration = settings.workDuration * 60
        _timeRemaining = Published(initialValue: duration)
        _sessionTotalDuration = Published(initialValue: duration)
        
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        _ = UIImpactFeedbackGenerator(style: .medium)
        _ = UINotificationFeedbackGenerator()
    }
    
    deinit {
        timer?.invalidate()
        // ViewModel ölürse aktiviteyi de sonlandırabiliriz, ama genelde app lifecycle yönetir.
    }
    
    // MARK: - Actions
    func handleToggle() async {
        if isActive {
            pause()
        } else {
            start()
        }
    }
    
    func handleReset() async {
        reset()
    }
    
    func handleSkip() async {
        skip()
    }
    
    // MARK: - Timer Control
    private func start() {
        timer?.invalidate()
        
        endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
        isActive = true
        
        NotificationManager.scheduleNotification(
            state: pomodoroState,
            durationInSeconds: timeRemaining
        )
        
        // Live Activity Başlat
        startLiveActivity()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func pause() {
        timer?.invalidate()
        timer = nil
        isActive = false
        endDate = nil
        
        NotificationManager.cancelNotifications()
        
        // Live Activity Bitir
        endLiveActivity()
    }
    
    private func reset() {
        timer?.invalidate()
        timer = nil
        isActive = false
        endDate = nil
        
        NotificationManager.cancelNotifications()
        
        // Live Activity Bitir
        endLiveActivity()
        
        pomodoroState = .working
        completedPomodoros = 0
        let duration = currentSettings.workDuration * 60
        timeRemaining = duration
        sessionTotalDuration = duration
    }
    
    private func skip() {
        if pomodoroState == .working {
            let spent = (sessionTotalDuration - timeRemaining) / 60
            if spent > 0 {
                StatsManager.save(session: CompletedPomodoro(durationMinutes: spent))
            }
            completedPomodoros += 1
        }
        
        playSound()
        transition()
    }
    
    private func tick() {
        guard let end = endDate else {
            timer?.invalidate()
            return
        }
        
        let remaining = Int(end.timeIntervalSinceNow.rounded())
        timeRemaining = max(0, remaining)
        
        if timeRemaining <= 0 {
            timer?.invalidate()
            timer = nil
            timeRemaining = 0
            isActive = false
            endDate = nil
            
            // Live Activity Bitir (Süre doldu)
            endLiveActivity()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.complete()
            }
        }
    }
    
    func sync() {
        guard let end = endDate, isActive else { return }
        
        let remaining = Int(end.timeIntervalSinceNow)
        timeRemaining = max(0, remaining)
        
        if timeRemaining <= 0 {
            complete()
        } else {
            // Uygulama tekrar aktif olduğunda timer'ı yeniden başlatmaya gerek yok
            // çünkü tick() zaten çalışıyor, ancak UI'ı güncellemek iyidir.
            // Live Activity zaten arka planda çalışıyor.
        }
    }
    
    // MARK: - State Transitions
    private func complete() {
        if pomodoroState == .working {
            StatsManager.save(session: CompletedPomodoro(
                durationMinutes: currentSettings.workDuration
            ))
            completedPomodoros += 1
        }
        
        playSound()
        HapticsManager.generateFeedback(.success)
        transition()
    }
    
    private func transition() {
        let nextState: PomodoroState
        let nextDuration: Int
        
        switch pomodoroState {
        case .working:
            if completedPomodoros % 4 == 0 {
                nextState = .longBreak
                nextDuration = currentSettings.longBreakDuration * 60
            } else {
                nextState = .shortBreak
                nextDuration = currentSettings.shortBreakDuration * 60
            }
        case .shortBreak, .longBreak:
            nextState = .working
            nextDuration = currentSettings.workDuration * 60
        }
        
        pomodoroState = nextState
        timeRemaining = nextDuration
        sessionTotalDuration = nextDuration
        isActive = false
        endDate = nil
        
        if currentSettings.autoStartSessions {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.start()
            }
        }
    }
    
    // MARK: - Live Activity Management
    private func startLiveActivity() {
        // Eğer zaten bir aktivite varsa ve çalışıyorsa, yenisini başlatma
        if let activity = currentActivity, activity.activityState == .active {
            return
        }
        
        // Eski aktiviteleri temizle (opsiyonel ama temizlik için iyi)
        Task {
            for activity in Activity<ClarityActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        
        guard let endDate = endDate else { return }
        
        let attributes = ClarityActivityAttributes(sessionName: "Clarity Session")
        
        let contentState = ClarityActivityAttributes.ContentState(
            estimatedEndDate: endDate,
            totalDuration: Double(sessionTotalDuration),
            stateName: pomodoroState.displayNameKey
        )
        
        do {
            let activity = try Activity<ClarityActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func endLiveActivity() {
        Task {
            // Tüm aktiviteleri bitir
            for activity in Activity<ClarityActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            currentActivity = nil
        }
    }
    
    // MARK: - Helpers
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func applySettings() {
        let old = currentSettings
        currentSettings = SettingsManager.load()
        themeManager?.loadTheme()
        
        if !isActive && old.workDuration != currentSettings.workDuration {
            reset()
        }
    }
    
    func playSound() {
        SoundPlayer.playSound(named: currentSettings.selectedSound.rawValue)
    }
}

// MARK: - Pomodoro State Extensions
extension PomodoroState {
    var stateString: String {
        switch self {
        case .working: return "work"
        case .shortBreak: return "shortBreak"
        case .longBreak: return "longBreak"
        }
    }
    
    var displayNameKey: String {
        switch self {
        case .working: return "Odaklanma"
        case .shortBreak: return "Kısa Mola"
        case .longBreak: return "Uzun Mola"
        }
    }
}
