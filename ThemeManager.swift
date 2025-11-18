import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = Theme.defaultTheme {
        didSet {
            saveThemeToUserDefaults()
        }
    }
    
    private let themeKey = "selectedThemeKey"
    
    init() {
        loadTheme()
    }
    
    private func saveThemeToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encodedData, forKey: themeKey)
            // DÜZELTME: print() kaldırıldı.
        }
    }
    
    func loadTheme() {
        if let data = UserDefaults.standard.data(forKey: themeKey) {
            if let decodedTheme = try? JSONDecoder().decode(Theme.self, from: data) {
                self.currentTheme = decodedTheme
                return
            }
        }
        self.currentTheme = Theme.defaultTheme
    }
}
