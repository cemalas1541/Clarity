import Foundation
import SwiftUI
import Combine

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
    weak var themeManager: ThemeManager?
    
    var minutesSpent: Int {
        (sessionTotalDuration - timeRemaining) / 60
    }
    
    // MARK: - Init
    init() {
        // Performans: Settings'i lazy yükle
        let settings = SettingsManager.load()
        _currentSettings = Published(initialValue: settings)
        
        let duration = settings.workDuration * 60
        _timeRemaining = Published(initialValue: duration)
        _sessionTotalDuration = Published(initialValue: duration)
        
        // Haptic feedback jeneratörlerini önceden hazırla
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        // Haptic feedback gecikmesini azaltmak için jeneratörleri hazırla
        _ = UIImpactFeedbackGenerator(style: .medium)
        _ = UINotificationFeedbackGenerator()
    }
    
    deinit {
        timer?.invalidate()
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
        
        // Focus Mode entegrasyonu: Timer başladığında Focus Mode'u aç
        if currentSettings.enableFocusModeOnTimerStart {
            if #available(iOS 16.0, *) {
                FocusModeManager.shared.activateFocusModeOnTimerStart()
            }
        }
        
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
        
        // Focus Mode entegrasyonu: Timer durduğunda Focus Mode'u kapat
        if currentSettings.enableFocusModeOnTimerStart {
            if #available(iOS 16.0, *) {
                FocusModeManager.shared.deactivateFocusModeOnTimerStop()
            }
        }
    }
    
    private func reset() {
        timer?.invalidate()
        timer = nil
        isActive = false
        endDate = nil
        
        NotificationManager.cancelNotifications()
        
        // Focus Mode entegrasyonu: Timer sıfırlandığında Focus Mode'u kapat
        if currentSettings.enableFocusModeOnTimerStart {
            if #available(iOS 16.0, *) {
                FocusModeManager.shared.deactivateFocusModeOnTimerStop()
            }
        }
        
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
            start()
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

extension PomodoroState {
    var stateString: String {
        switch self {
        case .working: return "work"
        case .shortBreak: return "shortBreak"
        case .longBreak: return "longBreak"
        }
    }
}
