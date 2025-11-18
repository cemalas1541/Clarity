import AVFoundation

struct SoundPlayer {
    static var audioPlayer: AVAudioPlayer?
    
    static func playSound(named soundName: String) {
        // Dosya uzantısını (.mp3, .wav vb.) bulmaya çalış
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") ?? Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            // DÜZELTME: print() kaldırıldı.
            return
        }
        
        do {
            // Seslerin birbirini kesmemesi için önce durdur
            audioPlayer?.stop()
            // Yeni sesi çal
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            // DÜZELTME: print() kaldırıldı.
        }
    }
}
