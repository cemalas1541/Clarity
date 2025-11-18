import SwiftUI

// MARK: - iOS 18+ Liquid Glass Effect Helper
extension View {
    /// iOS 18+ için liquid glass efekti ekler, eski sürümlerde normal blur kullanır
    @ViewBuilder
    func liquidGlassBackground(opacity: Double = 0.3) -> some View {
        if #available(iOS 18.0, *) {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        } else {
            self.background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
        }
    }
    
    /// iOS 18+ için liquid glass efekti ekler (Capsule şekli için)
    @ViewBuilder
    func liquidGlassCapsule(opacity: Double = 0.3) -> some View {
        if #available(iOS 18.0, *) {
            self.background(.regularMaterial, in: Capsule())
        } else {
            self.background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
        }
    }
}
