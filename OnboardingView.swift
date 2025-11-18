import SwiftUI

// Her bir tanÄ±tÄ±m sayfasÄ±nÄ±n verisini tutan yapÄ±
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let titleKey: String
    let descriptionKey: String
}

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // TanÄ±tÄ±m bittiÄŸinde ana uygulamaya haber vermek iÃ§in bir fonksiyon
    var onComplete: () -> Void
    
    // TanÄ±tÄ±m sayfalarÄ±mÄ±zÄ±n verileri
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "brain.head.profile",
            titleKey: "onboarding_title_1",
            descriptionKey: "onboarding_desc_1"
        ),
        OnboardingPage(
            imageName: "chart.line.uptrend.xyaxis",
            titleKey: "onboarding_title_2",
            descriptionKey: "onboarding_desc_2"
        ),
        OnboardingPage(
            imageName: "paintpalette.fill",
            titleKey: "onboarding_title_3",
            descriptionKey: "onboarding_desc_3"
        )
    ]
    
    // Hangi sayfada olduÄŸumuzu takip etmek iÃ§in
    @State private var selection = 0
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        themeManager.currentTheme.backgroundColor,
                        themeManager.currentTheme.accentColor.opacity(0.08),
                        themeManager.currentTheme.backgroundColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2), value: themeManager.currentTheme.id)
                
                VStack(spacing: 0) {
                    // Header with skip button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticsManager.generateFeedback()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                onComplete()
                            }
                        }) {
                            Text(LocalizedStringKey("skip"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(themeManager.currentTheme.accentColor.opacity(0.15))
                                )
                        }
                        .opacity(selection == pages.count - 1 ? 0 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 40) {
                        // KaydÄ±rÄ±labilir sayfalarÄ± oluÅŸturan TabView
                        TabView(selection: $selection) {
                            ForEach(pages.indices, id: \.self) { index in
                                OnboardingCardView(
                                    page: pages[index],
                                    isActive: selection == index
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: geometry.size.height * 0.55)
                        
                        // Custom page indicator
                        HStack(spacing: 12) {
                            ForEach(pages.indices, id: \.self) { index in
                                Capsule()
                                    .fill(selection == index ? themeManager.currentTheme.accentColor : themeManager.currentTheme.inactiveColor.opacity(0.4))
                                    .frame(width: selection == index ? 32 : 8, height: 8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selection)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            // Next/Start button
                            Button(action: {
                                HapticsManager.generateFeedback()
                                if selection < pages.count - 1 {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        selection += 1
                                    }
                                } else {
                                    HapticsManager.generateSuccessFeedback()
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        onComplete()
                                    }
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text(selection == pages.count - 1 ? "onboarding_start_button" : LocalizedStringKey("next"))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: selection == pages.count - 1 ? "checkmark" : "arrow.right")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    themeManager.currentTheme.accentColor,
                                                    themeManager.currentTheme.accentColor.opacity(0.85)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(
                                    color: themeManager.currentTheme.accentColor.opacity(0.4),
                                    radius: 12,
                                    y: 6
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Previous button (only show if not on first page)
                            if selection > 0 {
                                Button(action: {
                                    HapticsManager.generateFeedback()
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        selection -= 1
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.left")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text(LocalizedStringKey("previous"))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.currentTheme.inactiveColor.opacity(0.3))
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// Her bir kartÄ±n nasÄ±l gÃ¶rÃ¼neceÄŸini belirleyen geliÅŸmiÅŸ alt View
struct OnboardingCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let page: OnboardingPage
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0.0
    @State private var cardOffset: CGFloat = 50
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 50) {
            // Icon section with enhanced design - TÃœM SAYFALARDA AYNI RENK
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                themeManager.currentTheme.accentColor.opacity(0.3),
                                themeManager.currentTheme.accentColor.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 60,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .opacity(pulseAnimation ? 0.6 : 0.4)
                
                // Main circle background - TEMA RENGÄ° KULLANILIYOR
                Circle()
                    .fill(themeManager.currentTheme.accentColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 3)
                    )
                    .shadow(color: themeManager.currentTheme.accentColor.opacity(0.2), radius: 20, y: 10)
                
                // Icon
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.accentColor,
                                themeManager.currentTheme.accentColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(iconScale)
            }
            .scaleEffect(isActive ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
            
            // Text content section
            VStack(spacing: 16) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.primaryTextColor)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(LocalizedStringKey(page.descriptionKey))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .opacity(textOpacity)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .offset(y: cardOffset)
        }
        .padding(.horizontal, 20)
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            } else {
                resetAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOpacity = 1.0
            cardOffset = 0
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func resetAnimations() {
        withAnimation(.easeIn(duration: 0.3)) {
            iconScale = 0.8
            textOpacity = 0.0
            cardOffset = 50
            pulseAnimation = false
        }
    }
}
