import SwiftUI

// MARK: - Main Theme Structure
struct Theme: Identifiable, Codable, Equatable, Hashable {
    let id: String
    
    // Renklerin kendisini değil, Asset Catalog'daki isimlerini tutuyoruz.
    let accentColorName: String
    let backgroundColorName: String
    let primaryTextColorName: String
    let inactiveColorName: String
    
    // Bu computed property'ler, isimleri kullanarak anlık olarak doğru Color'ı oluşturur.
    // Sistem, o anki moda göre doğru rengi otomatik olarak seçecektir.
    var accentColor: Color { Color(accentColorName) }
    var backgroundColor: Color { Color(backgroundColorName) }
    var primaryTextColor: Color { Color(primaryTextColorName) }
    var inactiveColor: Color { Color(inactiveColorName) }
    
    // secondaryTextColor genellikle sabit olduğu için onu direkt tanımlayabiliriz.
    var secondaryTextColor: Color { .gray }
    
    // MARK: - Equatable & Hashable Conformance
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Pre-defined Themes
extension Theme {
    static let defaultTheme = Theme(
        id: "theme_mint_green",
        accentColorName: "MintGreen_Accent",
        backgroundColorName: "MintGreen_Background",
        primaryTextColorName: "MintGreen_PrimaryText",
        inactiveColorName: "MintGreen_Inactive"
    )
    
    static let lavenderTheme = Theme(
        id: "theme_lavender",
        accentColorName: "Lavender_Accent",
        backgroundColorName: "Lavender_Background",
        primaryTextColorName: "Lavender_PrimaryText",
        inactiveColorName: "Lavender_Inactive"
    )
    
    static let sunsetTheme = Theme(
        id: "theme_sunset",
        accentColorName: "Sunset_Accent",
        backgroundColorName: "Sunset_Background",
        primaryTextColorName: "Sunset_PrimaryText",
        inactiveColorName: "Sunset_Inactive"
    )
    
    static let forestTheme = Theme(
        id: "theme_forest",
        accentColorName: "Forest_Accent",
        backgroundColorName: "Forest_Background",
        primaryTextColorName: "Forest_PrimaryText",
        inactiveColorName: "Forest_Inactive"
    )
    
    static let oceanBreezeTheme = Theme(
        id: "theme_ocean_breeze",
        accentColorName: "Ocean_Accent",
        backgroundColorName: "Ocean_Background",
        primaryTextColorName: "Ocean_PrimaryText",
        inactiveColorName: "Ocean_Inactive"
    )
    
    static let allThemes: [Theme] = [defaultTheme, lavenderTheme, sunsetTheme, forestTheme, oceanBreezeTheme]
}

// Bu yardımcı extension'a artık bu dosyada ihtiyacımız yok.
// extension Color { ... }
