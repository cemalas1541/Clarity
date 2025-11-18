import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Uygulamaya "Bildirimleri ben yöneteceğim" diyoruz
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - Bildirimleri Yakalama
    
    // 1. Kullanıcı bildirime TIKLADIĞINDA (uygulama kapalı/arka planda iken)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        #if DEBUG
        print("🔔 BİLDİRİM TIKLANDI: Uygulama açılıyor/ön plana geliyor.")
        #endif
        
        // Kullanıcı bildirime tıkladığı için uygulama "active" olacak.
        // PomodoroViewModel'deki "didBecomeActiveNotification" gözlemcisi
        // bizim için tüm işi (syncTimerWithEndTime -> changeState -> autoStart) yapacak.
        
        completionHandler()
    }
    
    // 2. Uygulama ÖN PLANDAYKEN bildirim geldiğinde
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        #if DEBUG
        print("🔔 BİLDİRİM GELDİ (Uygulama Zaten Ön Planda)")
        #endif
        
        // PomodoroViewModel'deki zamanlayıcı (cancellable.sink)
        // zaten "timeRemaining <= 0" olduğunu algılayıp changeState()
        // fonksiyonunu çağırmış olmalı.
        
        // Bildirimin yine de (banner/ses olarak) gösterilmesine izin ver
        completionHandler([.banner, .sound])
    }
    
}
