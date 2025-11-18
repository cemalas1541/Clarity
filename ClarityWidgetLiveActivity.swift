import ActivityKit
import WidgetKit
import SwiftUI

struct ClarityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClarityActivityAttributes.self) { context in
            // MARK: - Lock Screen (Kilit Ekranı) Görünümü
            VStack(spacing: 12) {
                HStack {
                    // İkon ve Başlık
                    Image(systemName: iconName(for: context.state.stateName))
                        .foregroundColor(Color("AccentColor")) // Asset catalog rengi
                        .font(.title2)
                    
                    Text(context.state.stateName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Kusursuz Geri Sayım
                    Text(timerInterval: Date()...context.state.estimatedEndDate, countsDown: true)
                        .font(.system(.title2, design: .rounded).monospacedDigit().bold())
                        .foregroundColor(Color("AccentColor"))
                }
                
                // Progress Bar
                ProgressView(
                    value: max(0, min(1, (Date().timeIntervalSince1970 - (context.state.estimatedEndDate.timeIntervalSince1970 - context.state.totalDuration)) / context.state.totalDuration)),
                    total: 1.0
                )
                .tint(Color("AccentColor"))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                
                // Kontrol Butonları
                HStack {
                    // Bitir butonu
                    Button(intent: ResetTimerIntent()) {
                        Label("Bitir", systemImage: "xmark.circle.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Spacer()
                    
                    // Uygulamayı Aç butonu
                    Link(destination: URL(string: "clarity://open")!) {
                        Label("Uygulamayı Aç", systemImage: "arrow.up.forward.app.fill")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color("WidgetBackground").opacity(0.8))
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            // MARK: - Dynamic Island Görünümleri
            DynamicIsland {
                // --- Expanded (Genişletilmiş) ---
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: iconName(for: context.state.stateName))
                            .foregroundColor(Color("AccentColor"))
                            .font(.title2)
                        Text(context.state.stateName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                    .padding(.top, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.estimatedEndDate, countsDown: true)
                        .font(.system(.title2, design: .rounded).monospacedDigit().bold())
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 8)
                        .padding(.top, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        ProgressView(
                            value: max(0, min(1, (Date().timeIntervalSince1970 - (context.state.estimatedEndDate.timeIntervalSince1970 - context.state.totalDuration)) / context.state.totalDuration)),
                            total: 1.0
                        )
                        .tint(Color("AccentColor"))
                        .padding(.vertical, 6)
                        
                        HStack {
                            Button(intent: ResetTimerIntent()) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .padding(8)
                            }
                            .background(Circle().fill(.gray.opacity(0.3)))
                            
                            Spacer()
                            
                            Link(destination: URL(string: "clarity://open")!) {
                                Label("Uygulamaya Dön", systemImage: "arrow.up.forward.app")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().stroke(.white.opacity(0.3)))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
            } compactLeading: {
                // --- Compact Leading ---
                Image(systemName: iconName(for: context.state.stateName))
                    .foregroundColor(Color("AccentColor"))
                    .padding(.leading, 4)
                
            } compactTrailing: {
                // --- Compact Trailing ---
                Text(timerInterval: Date()...context.state.estimatedEndDate, countsDown: true)
                    .monospacedDigit()
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("AccentColor"))
                    .frame(maxWidth: 50)
                    .padding(.trailing, 4)
                
            } minimal: {
                // --- Minimal ---
                Image(systemName: iconName(for: context.state.stateName))
                    .foregroundColor(Color("AccentColor"))
            }
            .keylineTint(Color("AccentColor"))
        }
    }
    
    func iconName(for state: String) -> String {
        if state.contains("Mola") {
            return "cup.and.saucer.fill"
        } else {
            return "brain.head.profile"
        }
    }
}
