import SwiftUI

struct TimerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let pomodoroState: PomodoroState
    let timeRemaining: Int
    let sessionTotalDuration: Int
    let completedPomodoros: Int
    let isActive: Bool
    
    var onToggleTimer: () -> Void
    var onReset: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Durum Etiketi (State Label)
            HStack(spacing: 8) {
                Image(systemName: pomodoroState.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .symbolEffect(.bounce, value: pomodoroState)
                // DÜZELTME: Bir önceki hatayı gider, Text() sarmalayıcısı yok
                Text(pomodoroState.displayName)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(themeManager.currentTheme.accentColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .liquidGlassCapsule(opacity: 0.2)
            .overlay(
                Capsule()
                    .stroke(themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 8, y: 4)
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: pomodoroState)
            .accessibilityLabel("\(pomodoroState.displayName) session")
            .accessibilityHint("Current pomodoro session type")
            
            // MARK: - Zamanlayıcı Halkası ve Sayaç
            ZStack {
                // Arka plan blur efekti
                Circle()
                    .fill(themeManager.currentTheme.inactiveColor.opacity(0.3))
                    .blur(radius: 10)
                    .offset(y: 5)
                
                // Progress Circle
                ProgressCircleView(
                    progress: 1.0 - (Double(timeRemaining) / Double(sessionTotalDuration > 0 ? sessionTotalDuration : 1)),
                    backgroundColor: themeManager.currentTheme.inactiveColor,
                    foregroundGradient: Gradient(colors: [
                        themeManager.currentTheme.accentColor.opacity(0.9),
                        themeManager.currentTheme.accentColor
                    ]),
                    pomodoroState: pomodoroState
                )
                .shadow(color: themeManager.currentTheme.accentColor.opacity(isActive ? 0.6 : 0.3), radius: isActive ? 10 : 5)
                .animation(.linear(duration: 1.0), value: timeRemaining)
                .animation(.easeInOut, value: isActive)
                
                VStack(spacing: 15) {
                    // Zaman Metni
                    Text(formatTime(seconds: timeRemaining))
                        .font(.system(size: 72, weight: .light, design: .rounded))
                        .foregroundColor(themeManager.currentTheme.primaryTextColor)
                        .shadow(color: pomodoroState.accentColor(for: themeManager.currentTheme).opacity(0.3), radius: isActive ? 15 : 0)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: timeRemaining)
                        .animation(.easeInOut(duration: 0.3), value: isActive)
                        .monospacedDigit() // Rakamların zıplamasını engeller
                        .accessibilityLabel("Time remaining: \(formatTime(seconds: timeRemaining))")
                        .accessibilityValue(isActive ? "Timer is running" : "Timer is paused")
                        .dynamicTypeSize(.large ... .accessibility5)
                    
                    // Oturum Noktaları (Session Dots)
                    HStack(spacing: 12) {
                        ForEach(0..<pomodoroState.sessionDotsCount, id: \.self) { index in
                            let isCompleted = pomodoroState.isDotCompleted(
                                dotIndex: index,
                                completedSessions: completedPomodoros
                            )
                            
                            let isCurrent = pomodoroState.isDotCurrent(
                                dotIndex: index,
                                completedSessions: completedPomodoros,
                                isTimerActive: isActive
                            )
                            
                            if isCompleted {
                                Circle()
                                    .fill(themeManager.currentTheme.accentColor)
                                    .frame(width: 10, height: 10)
                                    .scaleEffect(1.1)
                            } else if isCurrent {
                                Circle()
                                    .stroke(themeManager.currentTheme.accentColor, lineWidth: 2.5)
                                    .frame(width: 10, height: 10)
                            } else {
                                Circle()
                                    .stroke(themeManager.currentTheme.inactiveColor.opacity(0.5), lineWidth: 1.5)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: completedPomodoros)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isActive)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: pomodoroState)
                }
            }
            .frame(width: 260, height: 260)
            
            // MARK: - Kontrol Butonları
            
            // DÜZELTME: Butonları gizlemek için `overlay` değil,
            // orijinal `HStack` yapısını ve `.opacity` kullan
            HStack(spacing: 30) {
                // Reset Butonu
                Button(action: {
                    HapticsManager.generateFeedback(.medium)
                    onReset()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(themeManager.currentTheme.inactiveColor))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                }
                // DÜZELTME: Butonu gizlemek için if bloğu yerine opacity kullan.
                // Bu, düzeni korur.
                .opacity(isActive ? 1 : 0)
                .disabled(!isActive)
                .scaleEffect(isActive ? 1 : 0.95)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
                .accessibilityLabel("Reset timer")
                .accessibilityHint("Resets the current timer session")
                
                // Play/Pause Butonu (Merkezde)
                Button(action: {
                    HapticsManager.generateFeedback(.medium)
                    onToggleTimer()
                }) {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .padding(.leading, isActive ? 0 : 5)
                        .frame(width: 80, height: 80)
                        .background(Circle().fill(themeManager.currentTheme.accentColor))
                        .clipShape(Circle())
                        .shadow(color: themeManager.currentTheme.accentColor.opacity(0.5), radius: 15, y: 8)
                }
                .scaleEffect(isActive ? 1.05 : 1.0)
                .symbolEffect(.bounce, value: isActive)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
                .accessibilityLabel(isActive ? "Pause timer" : "Start timer")
                .accessibilityHint(isActive ? "Pauses the current timer session" : "Starts the timer session")
                
                // Skip Butonu
                Button(action: {
                    HapticsManager.generateFeedback(.medium)
                    onSkip()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(themeManager.currentTheme.inactiveColor))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                }
                // DÜZELTME: Butonu gizlemek için if bloğu yerine opacity kullan.
                .opacity(isActive ? 1 : 0)
                .disabled(!isActive)
                .scaleEffect(isActive ? 1 : 0.95)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
                .accessibilityLabel("Skip session")
                .accessibilityHint("Skips to the next pomodoro session")
            }
            .foregroundColor(themeManager.currentTheme.primaryTextColor)
        }
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        // DÜZELTME: formatTime %02d kullanmalı ki "25:0" değil "25:00" olsun
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
