import SwiftUI

struct HeaderView: View {
    @Binding var selectedTab: String
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    let tabs = ["tab_focus", "tab_stats", "tab_settings"]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    HapticsManager.generateFeedback()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.selectedTab = tab
                    }
                } label: {
                    Text(LocalizedStringKey(tab))
                        .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .medium))
                        .foregroundColor(
                            selectedTab == tab
                            ? .white
                            : themeManager.currentTheme.primaryTextColor.opacity(0.6)
                        )
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(
                                            colorScheme == .dark
                                            ? themeManager.currentTheme.accentColor.opacity(0.8)
                                            : themeManager.currentTheme.accentColor
                                        )
                                        .shadow(
                                            color: colorScheme == .dark
                                            ? themeManager.currentTheme.accentColor.opacity(0.3)
                                            : .black.opacity(0.1),
                                            radius: 8,
                                            y: 2
                                        )
                                } else {
                                    Capsule().fill(Color.clear)
                                }
                            }
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(6)
        // HeaderView'de zaten liquidGlass efekti uygulanmış durumda.
        .liquidGlassCapsule(opacity: 0.2)
        .overlay(
            Capsule()
                .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 1)
        )
        .frame(height: 50)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme.id)
    }
}
