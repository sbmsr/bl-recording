import AVFoundation
import Foundation
class AudioManager: NSObject {
    private var audioFileName: URL?
    private var recordingStartTime: Date?
    
    var onPlaybackFinished: (() -> Void)?
    
    override init() {
        super.init()
        configureAudioSession()
        requestMicrophonePermission()
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                print(granted ? "Microphone access granted." : "Microphone access denied.")
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print(granted ? "Microphone access granted." : "Microphone access denied.")
            }
        }
    }
}
