import SwiftUI

struct ProgressCircleView: View {
    var progress: Double
    let backgroundColor: Color
    let foregroundGradient: Gradient
    let lineWidth: CGFloat = 15
    let pomodoroState: PomodoroState
    
    // MARK: - Computed Style Properties
    
    /// Duruma göre gradyan başlangıç noktasını belirler
    private var gradientStartPoint: UnitPoint {
        switch pomodoroState {
        case .working:
            return .topLeading
        case .shortBreak:
            return .leading
        case .longBreak:
            return .bottomLeading
        }
    }
    
    /// Duruma göre gradyan bitiş noktasını belirler
    private var gradientEndPoint: UnitPoint {
        switch pomodoroState {
        case .working:
            return .bottomTrailing
        case .shortBreak:
            return .trailing
        case .longBreak:
            return .topTrailing
        }
    }
    
    /// Duruma göre çizgi stilini (düz veya kesikli) belirler
    private var customStrokeStyle: StrokeStyle {
        switch pomodoroState {
        case .working:
            // Çalışma durumunda düz, yuvarlak kenarlı çizgi
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        case .shortBreak, .longBreak:
            // Mola durumlarında kesikli çizgi
            return StrokeStyle(lineWidth: lineWidth, lineCap: .butt, dash: [10])
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 1. Arka Plan Halkası
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            // 2. İlerleme Halkası - State'e göre stil
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: foregroundGradient,
                        // DÜZELTME: Artık yerel computed property'leri kullanıyor
                        startPoint: gradientStartPoint,
                        endPoint: gradientEndPoint
                    ),
                    // DÜZELTME: Artık yerel computed property'i kullanıyor
                    style: customStrokeStyle
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 1.0), value: progress) // Progress değişimini anime et
        }
        .padding()
        // Durum (state) değiştiğinde stilin yumuşak geçiş yapmasını sağlar
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: pomodoroState)
        .accessibilityElement()
        .accessibilityLabel("Timer progress")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
    }
}
