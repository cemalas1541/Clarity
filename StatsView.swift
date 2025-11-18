import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var allSessions: [CompletedPomodoro] = []
    @State private var selectedTimeframe: Timeframe = .weekly
    @State private var selectedLabel: String?
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale.current
        return cal
    }
    
    private var selectedDataPoint: ChartDataPoint? {
        if let selectedLabel = selectedLabel {
            return chartData.first(where: { $0.label == selectedLabel })
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                customTimeframePicker
                modernSummaryCards
                chartSection
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            allSessions = StatsManager.loadSessions()
        }
        .onChange(of: selectedTimeframe) { oldState, newState in selectedLabel = nil }
    }
    
    // MARK: - CUSTOM TAB PICKER
    private var customTimeframePicker: some View {
        HStack(spacing: 8) {
            ForEach(Timeframe.allCases) { timeframe in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                    }
                } label: {
                    Text(LocalizedStringKey(timeframe.rawValue))
                        .font(.system(size: 12, weight: selectedTimeframe == timeframe ? .semibold : .medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : themeManager.currentTheme.secondaryTextColor)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedTimeframe == timeframe {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.currentTheme.accentColor)
                                        .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 8, y: 4)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.currentTheme.inactiveColor.opacity(0.5))
                                }
                            }
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    // MARK: - 2x2 GRID KARTLAR
    private var modernSummaryCards: some View {
        let minutesUnit = NSLocalizedString("minutes_short", comment: "")
        let totalMinutes = chartData.reduce(0) { $0 + $1.totalMinutes }
        
        let totalSessions: Int
        switch selectedTimeframe {
        case .daily:
            totalSessions = allSessions.filter { calendar.isDateInToday($0.date) }.count
        case .weekly:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            totalSessions = allSessions.filter { $0.date >= startOfWeek }.count
        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: Date())
            let startOfMonth = calendar.date(from: components)!
            totalSessions = allSessions.filter { $0.date >= startOfMonth }.count
        case .yearly:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
            totalSessions = allSessions.filter { $0.date >= startOfYear }.count
        }
        
        let streakCount = calculateStreak()
        
        // NOT: Lokalizasyon dosyanızdan ("summary_streak_days") okumak daha iyi olabilir,
        // ancak mevcut kodunuzu koruyorum.
        let streakText = Locale.current.language.languageCode?.identifier == "tr"
            ? "\(streakCount) gün"
            : "\(streakCount) day\(streakCount != 1 ? "s" : "")"
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ModernStatCard(
                title: "summary_total_time",
                value: "\(totalMinutes) \(minutesUnit)",
                icon: "clock.fill",
                iconColor: themeManager.currentTheme.accentColor,
                trend: nil
            )
            
            ModernStatCard(
                title: "summary_total_sessions",
                value: "\(totalSessions)",
                icon: "checkmark.circle.fill",
                iconColor: themeManager.currentTheme.accentColor,
                trend: nil
            )
            
            ModernStatCard(
                title: bestPeriodTitle,
                value: mostProductiveEntryFormatted,
                icon: "star.fill",
                iconColor: themeManager.currentTheme.accentColor,
                trend: nil
            )
            
            ModernStatCard(
                title: "summary_streak",
                value: streakText,
                icon: "flame.fill",
                iconColor: themeManager.currentTheme.accentColor,
                trend: nil
            )
        }
    }
    
    private var granularityForTimeframe: Calendar.Component {
        switch selectedTimeframe {
        case .daily:
            return .hour
        case .weekly:
            return .day
        case .monthly:
            return .day
        case .yearly:
            return .month
        }
    }
    
    private var bestPeriodTitle: String {
        switch selectedTimeframe {
        case .daily:
            return "summary_best_hour"
        case .weekly:
            return "summary_best_day"
        case .monthly:
            return "summary_best_date"
        case .yearly:
            return "summary_best_month"
        }
    }
    
    // MARK: - MODERN GRAFİK ALANI
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if chartData.isEmpty {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.accentColor.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                    
                    VStack(spacing: 8) {
                        Text("ready_to_start")
                            .font(.title3.bold())
                            .foregroundColor(themeManager.currentTheme.primaryTextColor)
                        
                        Text("start_first_session")
                            .font(.subheadline)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.currentTheme.inactiveColor.opacity(0.3))
                        
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.accentColor.opacity(0.08),
                                themeManager.currentTheme.accentColor.opacity(0.04),
                                themeManager.currentTheme.accentColor.opacity(0.02),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(20)
                        .blendMode(.overlay)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 1)
                    }
                )
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                
            } else {
                InteractiveAreaChart(
                    data: chartData,
                    selectedLabel: $selectedLabel
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // --- DÜZELTİLMİŞ chartData FONKSİYONU ---
    private var chartData: [ChartDataPoint] {
        guard !allSessions.isEmpty else { return [] }
        let now = Date()
        
        // MARK: - Formatlayıcılar
        // Tüm etiket formatlamalarını tek bir yerden yönetmek
        // ve Locale.current kullandıklarından emin olmak için
        // DateFormatter'lar oluşturuyoruz.
        
        // Haftalık için (Örn: Pzt, Sal)
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale.current
        // "E" -> Cihaz diline göre kısaltılmış gün adı
        weekdayFormatter.setLocalizedDateFormatFromTemplate("E")

        // Yıllık için (Örn: Oca, Şub)
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        // "MMM" -> Cihaz diline göre kısaltılmış ay adı
        monthFormatter.setLocalizedDateFormatFromTemplate("MMM")

        // StatsView.swift -> chartData fonksiyonu içinde

            // Günlük için (ÖRN: 09:00, 9:00 AM)
            let hourFormatter = DateFormatter()
            hourFormatter.locale = Locale.current
            // "hm" -> Cihaz diline göre tercih edilen saat:dakika formatı
            // tr_TR -> "09:00"
            // en_US -> "9:00 AM"
            hourFormatter.setLocalizedDateFormatFromTemplate("hm") // <--- DÜZELTİLDİ
        
        // MARK: - Veri İşleme
        
        switch selectedTimeframe {
        case .daily:
            // DÜZELTME: Sadece 'hour' bileşeni yerine tam bir tarih nesnesi oluşturuyoruz.
            let startOfToday = calendar.startOfDay(for: now)
            let todaySessions = allSessions.filter { calendar.isDateInToday($0.date) }
            let grouped = Dictionary(grouping: todaySessions) { calendar.component(.hour, from: $0.date) }
            
            return grouped.map { hour, sessions in
                // DÜZELTME 1: Bugünden başlayarak doğru saatle tam bir tarih oluştur.
                let date = calendar.date(byAdding: .hour, value: hour, to: startOfToday)!
                // DÜZELTME 2: Açıkça tanımlanmış formatlayıcıyı kullan.
                let label = hourFormatter.string(from: date)
                return ChartDataPoint(label: label, date: date, totalMinutes: sessions.totalMinutes)
            }.sorted { $0.date < $1.date }
            
        case .weekly:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let grouped = Dictionary(grouping: allSessions.filter { $0.date >= startOfWeek }) { calendar.component(.weekday, from: $0.date) }
            
            return grouped.map { weekday, sessions in
                // Bu tarih oluşturma mantığınız zaten doğruydu.
                var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                components.weekday = weekday
                let date = calendar.date(from: components)!
                
                // DÜZELTME: .formatted() yerine açıkça tanımlanmış formatlayıcıyı kullan.
                let label = weekdayFormatter.string(from: date)
                return ChartDataPoint(label: label, date: date, totalMinutes: sessions.totalMinutes)
            }.sorted { $0.date < $1.date }
            
        case .monthly:
            // Bu bölümdeki tarih oluşturma mantığınız zaten doğruydu.
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components)!
            let grouped = Dictionary(grouping: allSessions.filter { $0.date >= startOfMonth }) { calendar.component(.day, from: $0.date) }
            
            return grouped.map { day, sessions in
                var components = calendar.dateComponents([.year, .month], from: now)
                components.day = day
                let date = calendar.date(from: components)!
                
                // DÜZELTME: Hardcoded "\(day)" yerine lokalizasyona uygun .formatted() kullan.
                // Bu sadece sayıyı (örn: "8") cihazın diline uygun şekilde formatlar.
                let label = date.formatted(.dateTime.day())
                return ChartDataPoint(label: label, date: date, totalMinutes: sessions.totalMinutes)
            }.sorted { $0.date < $1.date }
            
        case .yearly:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let grouped = Dictionary(grouping: allSessions.filter { $0.date >= startOfYear }) { calendar.component(.month, from: $0.date) }
            
            return grouped.map { month, sessions in
                // DÜZELTME 1: Sadece 'month' bileşeni yerine tam bir tarih nesnesi oluştur.
                var components = calendar.dateComponents([.year], from: now) // Mevcut yıldan başla
                components.month = month // Ayı ayarla
                let date = calendar.date(from: components)! // Tam tarihi al
                
                // DÜZELTME 2: Açıkça tanımlanmış formatlayıcıyı kullan.
                let label = monthFormatter.string(from: date)
                return ChartDataPoint(label: label, date: date, totalMinutes: sessions.totalMinutes)
            }.sorted { $0.date < $1.date }
        }
    }
    
    // --- GERİ EKLENEN EKSİK FONKSİYONLAR ---
    
    private var mostProductiveEntryFormatted: String {
        // En yüksek veriye sahip veri noktasını bul
        guard let maxEntry = chartData.max(by: { $0.totalMinutes < $1.totalMinutes }), maxEntry.totalMinutes > 0 else { return "-" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        switch selectedTimeframe {
        case .daily, .weekly, .yearly:
            // Bu labeller (örn: "13:00", "Pzt", "Kas") zaten
            // chartData içinde yerelleştirildiği için direkt kullanabiliriz.
            return maxEntry.label
            
        case .monthly:
            // "En İyi Tarih" için sadece gün sayısını (örn: "8") göstermek
            // anlamsız olur. "8 Kas" gibi daha açıklayıcı bir format kullanalım.
            // "dMMM" -> Cihaz diline göre "8 Kas" formatını verir.
            formatter.setLocalizedDateFormatFromTemplate("dMMM")
            return formatter.string(from: maxEntry.date)
        }
    }
    
    private var dailyAverage: Int {
        // Grafikteki verilerin kaç farklı güne ait olduğunu bul
        let uniqueDays = Set(chartData.map { calendar.startOfDay(for: $0.date) }).count
        // Toplam dakikayı hesapla
        let totalMinutes = chartData.reduce(0) { $0 + $1.totalMinutes }
        // Ortalamayı al
        return uniqueDays > 0 ? totalMinutes / uniqueDays : 0
    }
    
    private func calculateStreak() -> Int {
        guard !allSessions.isEmpty else { return 0 }
        
        // Tüm seans tarihlerini al, günün başına yuvarla, Set ile tekilleştir
        // ve en yeniden en eskiye doğru sırala.
        let uniqueDays = Set(allSessions.map { calendar.startOfDay(for: $0.date) })
            .sorted(by: >)
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        
        // En son seans "bugün" ise...
        if uniqueDays[0] == today {
            streak = 1 // Seri 1'den başlar
            var checkDate = today
            
            // Listenin geri kalanını kontrol et
            for i in 1..<uniqueDays.count {
                let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                if uniqueDays[i] == previousDay { // Dün de çalışmış mı?
                    streak += 1
                    checkDate = previousDay // Kontrol gününü bir gün geri al
                } else {
                    break // Seri bozuldu
                }
            }
        // En son seans "bugün" DEĞİL, ama "dün" ise...
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                    uniqueDays[0] == yesterday {
            streak = 1 // Seri 1'den başlar
            var checkDate = yesterday
            
            // Listenin geri kalanını kontrol et
            for i in 1..<uniqueDays.count {
                let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                if uniqueDays[i] == previousDay {
                    streak += 1
                    checkDate = previousDay
                } else {
                    break
                }
            }
        }
        // Eğer en son seans dünden daha eskiyse, seri 0'dır.
        
        return streak
    }

} // <-- EKSİK OLAN KAPATMA PARANTEZİ


// MARK: - MODERN STAT CARD
struct ModernStatCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Spacer()
                
                if let trend = trend {
                    Text(trend == .up ? "↗" : "↘") // Ok karakterleri düzeltildi
                        .font(.title2)
                        .foregroundColor(trend == .up ? .green : .red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.primaryTextColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(height: 120)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(NSLocalizedString(title, comment: "")), \(value)")
        .dynamicTypeSize(.medium ... .accessibility3)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.currentTheme.inactiveColor.opacity(0.5))
                
                LinearGradient(
                    colors: [
                        iconColor.opacity(0.15),
                        iconColor.opacity(0.1),
                        iconColor.opacity(0.06),
                        iconColor.opacity(0.03),
                        iconColor.opacity(0.01)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(20)
                .blendMode(.overlay)
            }
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

// MARK: - SCALE BUTTON STYLE
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
