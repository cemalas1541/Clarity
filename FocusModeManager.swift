import Foundation

@available(iOS 15.0, *)
class FocusModeManager {
    static let shared = FocusModeManager()
    
    private init() {}
    
    // MARK: - Timer Başladığında Focus Mode Aç
    
    /// Timer başladığında Focus Mode'u açar (iOS 16+)
    /// Not: iOS'ta Focus Mode'u programatik olarak açmak için doğrudan bir API yok
    /// Bu fonksiyon, kullanıcıya Shortcuts'ta otomasyon oluşturması için bilgi verir
    /// Gerçek implementasyon için Shortcuts entegrasyonu gereklidir
    @available(iOS 16.0, *)
    func activateFocusModeOnTimerStart() {
        // iOS'ta Focus Mode'u programatik olarak açmak için doğrudan bir API yok
        // Kullanıcının Shortcuts uygulamasında bir otomasyon oluşturması gerekir
        
        // Bilgilendirme: Kullanıcıya Shortcuts'ta otomasyon oluşturması gerektiğini hatırlat
        print("💡 Focus Mode'u otomatik açmak için:")
        print("   1. Shortcuts uygulamasını açın")
        print("   2. 'Otomasyonlar' sekmesine gidin")
        print("   3. 'Uygulama Açıldığında' tetikleyicisi ekleyin")
        print("   4. Clarity uygulamasını seçin")
        print("   5. 'Focus' eylemini ekleyin ve istediğiniz Focus Mode'u seçin")
        
        // Alternatif: NotificationCenter ile Shortcuts'a sinyal gönder
        // (Eğer kullanıcı bir otomasyon oluşturmuşsa)
        NotificationCenter.default.post(
            name: NSNotification.Name("RequestFocusModeActivation"),
            object: nil
        )
    }
    
    /// Timer durduğunda Focus Mode'u kapatır (iOS 16+)
    @available(iOS 16.0, *)
    func deactivateFocusModeOnTimerStop() {
        // Focus Mode'u kapatmak için de Shortcuts otomasyonu gereklidir
        print("💡 Focus Mode'u otomatik kapatmak için Shortcuts'ta otomasyon oluşturun")
        
        // NotificationCenter ile Shortcuts'a sinyal gönder
        NotificationCenter.default.post(
            name: NSNotification.Name("RequestFocusModeDeactivation"),
            object: nil
        )
    }
    
    // MARK: - Focus Mode Durumunu Kontrol Et
    
    /// Aktif Focus Mode'u kontrol eder
    func getActiveFocusMode() -> String? {
        // iOS 15+ için Focus Mode API'si
        // Not: iOS 15'te doğrudan Focus Mode API'si yok,
        // ancak Intent Framework ile entegre edilebilir
        
        // iOS 16+ için daha gelişmiş entegrasyon mümkün
        if #available(iOS 16.0, *) {
            // Focus Mode durumunu kontrol et
            return checkFocusModeStatus()
        }
        
        return nil
    }
    
    @available(iOS 16.0, *)
    private func checkFocusModeStatus() -> String? {
        // Focus Mode durumunu kontrol etmek için
        // Intent Framework kullanılabilir
        // Bu örnek basit bir implementasyon
        
        // Gerçek implementasyon için:
        // - INFocusStatusCenter kullanılabilir (iOS 16+)
        // - Veya kullanıcıdan manuel olarak Focus Mode seçimi istenebilir
        
        return nil
    }
    
    // MARK: - Focus Mode ile Timer Başlatma
    
    /// Belirli bir Focus Mode aktif olduğunda timer'ı başlatır
    func startTimerForFocusMode(_ focusMode: String, completion: @escaping (Bool) -> Void) {
        // Focus Mode aktif mi kontrol et
        if let activeMode = getActiveFocusMode(), activeMode == focusMode {
            // Timer'ı başlat
            NotificationCenter.default.post(
                name: NSNotification.Name("StartTimerForFocusMode"),
                object: nil,
                userInfo: ["focusMode": focusMode]
            )
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Focus Mode Ayarları
    
    struct FocusModeSettings: Codable {
        var focusModeName: String
        var workDuration: Int
        var shortBreakDuration: Int
        var longBreakDuration: Int
        var autoStart: Bool
    }
    
    /// Focus Mode için özel ayarları kaydet
    func saveFocusModeSettings(_ settings: FocusModeSettings) {
        let key = "focusMode_\(settings.focusModeName)"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    /// Focus Mode için özel ayarları yükle
    func loadFocusModeSettings(_ focusModeName: String) -> FocusModeSettings? {
        let key = "focusMode_\(focusModeName)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(FocusModeSettings.self, from: data)
    }
    
    // MARK: - Focus Mode Entegrasyonu için Intent
    
    @available(iOS 16.0, *)
    func setupFocusModeIntegration() {
        // Focus Mode ile entegrasyon için Intent ayarları
        // Bu, kullanıcının Focus Mode ayarlarından
        // Clarity uygulamasını seçmesine olanak tanır
    }
}

// MARK: - Focus Mode Intent Handler

@available(iOS 16.0, *)
extension FocusModeManager {
    /// Focus Mode değiştiğinde çağrılır
    func handleFocusModeChange(_ focusMode: String?, isActive: Bool) {
        guard let focusMode = focusMode, isActive else { return }
        
        // Bu Focus Mode için özel ayarlar var mı kontrol et
        if let settings = loadFocusModeSettings(focusMode) {
            if settings.autoStart {
                // Otomatik olarak timer'ı başlat
                startTimerForFocusMode(focusMode) { success in
                    if success {
                        print("✅ Timer started for Focus Mode: \(focusMode)")
                    }
                }
            }
        }
    }
}

