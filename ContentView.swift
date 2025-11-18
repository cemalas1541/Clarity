import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = PomodoroViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.currentTheme.backgroundColor,
                    themeManager.currentTheme.accentColor.opacity(0.1),
                    themeManager.currentTheme.backgroundColor
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                HeaderView(selectedTab: $viewModel.selectedTab)
                
                if viewModel.selectedTab == "tab_focus" {
                    Spacer()
                    TimerView(
                        pomodoroState: viewModel.pomodoroState,
                        timeRemaining: viewModel.timeRemaining,
                        sessionTotalDuration: viewModel.sessionTotalDuration,
                        completedPomodoros: viewModel.completedPomodoros,
                        isActive: viewModel.isActive,
                        onToggleTimer: {
                            Task { await viewModel.handleToggle() }
                        },
                        onReset: {
                            if viewModel.isActive {
                                viewModel.isShowingResetAlert = true
                            }
                        },
                        onSkip: {
                            if viewModel.isActive {
                                viewModel.isShowingSkipAlert = true
                            }
                        }
                    )
                    Spacer()
                } else if viewModel.selectedTab == "tab_stats" {
                    StatsView()
                        .environmentObject(themeManager)
                } else if viewModel.selectedTab == "tab_settings" {
                    SettingsView()
                        .environmentObject(themeManager)
                        .environmentObject(viewModel)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .onAppear {
            NotificationManager.requestAuthorization()
            viewModel.themeManager = themeManager
            checkIntent()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScene(newPhase)
        }
        .alert("alert_skip_title", isPresented: $viewModel.isShowingSkipAlert) {
            Button("cancel", role: .cancel) {}
            Button("skip") {
                Task { await viewModel.handleSkip() }
            }
        } message: {
            let formatString = NSLocalizedString("alert_skip_message", comment: "")
            let minutes = viewModel.minutesSpent
            let message = String(format: formatString, minutes)
            Text(message)
        }
        .alert("alert_reset_title", isPresented: $viewModel.isShowingResetAlert) {
            Button("cancel", role: .cancel) {}
            Button("alert_reset_confirm", role: .destructive) {
                Task { await viewModel.handleReset() }
            }
        } message: {
            Text(LocalizedStringKey("alert_reset_message"))
        }
    }
    
    // MARK: - Intent Handler
    private func checkIntent() {
        guard let ud = UserDefaults(suiteName: "group.com.cemalas.Clarity"),
              let action = ud.string(forKey: "pendingAction") else {
            return
        }
        
        ud.removeObject(forKey: "pendingAction")
        
        Task {
            switch action {
            case "toggle": await viewModel.handleToggle()
            case "reset": await viewModel.handleReset()
            default: break
            }
        }
    }
    
    // MARK: - Scene Handler
    private func handleScene(_ phase: ScenePhase) {
        switch phase {
        case .active:
            checkIntent()
            viewModel.sync()
        case .background:
            break
        default:
            break
        }
    }
}
