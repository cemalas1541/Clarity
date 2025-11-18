import SwiftUI
import StoreKit

struct SettingsView: View {
    // --- YENİ EKLENEN SATIR ---
    // Ana PomodoroViewModel'e erişmek için
    @EnvironmentObject var pomodoroViewModel: PomodoroViewModel
    // --- BİTTİ ---
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.requestReview) var requestReview

    @State private var workDuration: Int
    @State private var shortBreakDuration: Int
    @State private var longBreakDuration: Int
    @State private var selectedSound: SoundOption
    @State private var autoStartSessions: Bool
    @State private var selectedAppearance: AppearanceMode
    @State private var enableFocusModeOnTimerStart: Bool
    @State private var showResetAlert = false
     
    init() {
        // Not: Bu init() metodu, @State'leri yüklemek için
        // EnvironmentObject'tan ÖNCE çalışır. Bu normaldir.
        let settings = SettingsManager.load()
        _workDuration = State(initialValue: settings.workDuration)
        _shortBreakDuration = State(initialValue: settings.shortBreakDuration)
        _longBreakDuration = State(initialValue: settings.longBreakDuration)
        _selectedSound = State(initialValue: settings.selectedSound)
        _autoStartSessions = State(initialValue: settings.autoStartSessions)
        _selectedAppearance = State(initialValue: settings.appearanceMode)
        _enableFocusModeOnTimerStart = State(initialValue: settings.enableFocusModeOnTimerStart)
    }
     
    var body: some View {
        Form {
            pomodoroSettingsSection
            soundSettingsSection
            appearanceSettingsSection
            
            if #available(iOS 15.0, *) {
                focusModeSection
            }
            
            communitySection
            
            resetSection
        }
        .scrollContentBackground(.hidden)
        .id(themeManager.currentTheme)
        .accessibilityElement(children: .contain)
        .alert("alert_reset_stats_title", isPresented: $showResetAlert) {
            Button("cancel", role: .cancel) { }
            Button("alert_reset_stats_confirm", role: .destructive) {
                StatsManager.clearAllStats()
            }
        } message: {
            Text("alert_reset_stats_message")
        }
        .tint(themeManager.currentTheme.accentColor)
    }
     
    private func saveSettingsOnChange() {
        let newSettings = PomodoroSettings(
            workDuration: workDuration,
            shortBreakDuration: shortBreakDuration,
            longBreakDuration: longBreakDuration,
            selectedSound: selectedSound,
            autoStartSessions: autoStartSessions,
            appearanceMode: selectedAppearance,
            enableFocusModeOnTimerStart: enableFocusModeOnTimerStart
        )
        SettingsManager.save(settings: newSettings)
        
        // --- YENİ EKLENEN SATIR ---
        // Ayarları kaydettikten sonra, ana ViewModel'i GÜNCELLE
        // Bu, PomodoroViewModel'deki applySettings() fonksiyonunu tetikler.
        pomodoroViewModel.applySettings()
        // --- BİTTİ ---
    }
}

// MARK: - Subviews
private extension SettingsView {
     
    var pomodoroSettingsSection: some View {
        Section(header: Text("settings_pomodoro_times").foregroundColor(.secondary)) {
            Stepper(value: $workDuration, in: 5...90, step: 5) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("settings_work")
                    Spacer()
                    Text("\(workDuration) \(NSLocalizedString("minutes_short", comment: ""))")
                        .foregroundColor(.secondary)
                }
            }
            // DÜZELTME: (iOS 17+) .onChange(of: workDuration, saveSettingsOnChange)
            // Bu şekilde daha temiz, ancak mevcut kodunuz da doğru çalışır
            .onChange(of: workDuration) { _, _ in saveSettingsOnChange() }
            
            Stepper(value: $shortBreakDuration, in: 1...30) {
                HStack {
                    Image(systemName: "cup.and.saucer")
                    Text("settings_short_break")
                    Spacer()
                    Text("\(shortBreakDuration) \(NSLocalizedString("minutes_short", comment: ""))")
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: shortBreakDuration) { _, _ in saveSettingsOnChange() }
            
            Stepper(value: $longBreakDuration, in: 5...45, step: 5) {
                HStack {
                    Image(systemName: "bed.double")
                    Text("settings_long_break")
                    Spacer()
                    Text("\(longBreakDuration) \(NSLocalizedString("minutes_short", comment: ""))")
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: longBreakDuration) { _, _ in saveSettingsOnChange() }
            
            Toggle("settings_autostart", isOn: $autoStartSessions)
                .onChange(of: autoStartSessions) { _, _ in saveSettingsOnChange() }
            
            if #available(iOS 16.0, *) {
                Toggle("Enable Focus Mode on Timer Start", isOn: $enableFocusModeOnTimerStart)
                    .onChange(of: enableFocusModeOnTimerStart) { _, _ in saveSettingsOnChange() }
                
                if enableFocusModeOnTimerStart {
                    Text("Note: To automatically activate Focus Mode, create a Shortcuts automation that triggers when Clarity timer starts.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
     
    var soundSettingsSection: some View {
        Section(header: Text("settings_sound_options").foregroundColor(.secondary)) {
            Picker("settings_session_end_sound", selection: $selectedSound) {
                ForEach(SoundOption.allCases) { sound in
                    Text(LocalizedStringKey(sound.displayKey)).tag(sound)
                }
            }
            .onChange(of: selectedSound) { _, newSound in
                SoundPlayer.playSound(named: newSound.rawValue)
                saveSettingsOnChange() // Anında kaydet
            }
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
     
    var appearanceSettingsSection: some View {
        Section(header: Text("settings_appearance").foregroundColor(.secondary)) {
            Picker("settings_appearance_mode", selection: $selectedAppearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    HStack {
                        Image(systemName: mode == .light ? "sun.max.fill" : mode == .dark ? "moon.fill" : "circle.lefthalf.filled")
                        Text(LocalizedStringKey(mode.displayKey))
                    }
                    .tag(mode)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedAppearance) { _, newMode in
                AppearanceManager.applyAppearanceMode(newMode)
                saveSettingsOnChange() // Anında kaydet
            }
            
            Picker("settings_theme", selection: $themeManager.currentTheme) {
                ForEach(Theme.allThemes) { theme in
                    Text(LocalizedStringKey(theme.id)).tag(theme)
                }
            }
            .pickerStyle(.menu)
            // Not: Tema değişikliği ThemeManager tarafından otomatik kaydedilir
            // ve 'saveSettingsOnChange' çağırmaz, ki bu doğru.
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
    
    @available(iOS 15.0, *)
    var focusModeSection: some View {
        Section(header: Text("Focus Mode").foregroundColor(.secondary)) {
            Toggle("Enable Focus Mode Integration", isOn: .constant(false))
                .disabled(true)
            
            Text("Focus Mode integration allows Clarity to automatically start timers when specific Focus Modes are activated.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
     
    var communitySection: some View {
        Section(header: Text("settings_support").foregroundColor(themeManager.currentTheme.primaryTextColor.opacity(0.6))) {
            // Feedback & Support (Mail)
            Button {
                let subject = "Clarity Feedback"
                let body = "Merhaba,\n\nGeri bildirimim: "
                let to = "clarityfocus.app@gmail.com"
                let mailto = "mailto:\(to)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body)"
                if let url = URL(string: mailto), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("settings_feedback_support", systemImage: "envelope.fill")
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
            }

            // Uygulamayı Puanla (App Store)
            Button {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else if let url = URL(string: "itms-apps://itunes.apple.com/app/id6754528820?action=write-review"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("settings_rate_app", systemImage: "star.fill")
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
            }

            // Tavsiye Et (Paylaş)
            if let shareURL = URL(string: "https://apps.apple.com/app/id6754528820") {
                ShareLink(item: shareURL, subject: Text("settings_share_subject"), message: Text("settings_share_message")) {
                    Label("settings_recommend", systemImage: "square.and.arrow.up")
                        .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                }
            }
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
     
    var resetSection: some View {
        Section {
            Button(action: {
                showResetAlert = true
            }) {
                HStack {
                    Spacer()
                    Text("settings_reset_stats")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        .listRowBackground(themeManager.currentTheme.inactiveColor.opacity(0.5))
    }
}
