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
        
        // Register for audio session interruption notifications
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleAudioSessionInterruption),
                                             name: AVAudioSession.interruptionNotification,
                                             object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,
                                  mode: .default,
                                  options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
            print("Audio session configured successfully for background recording.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session interrupted (e.g., phone call)
            print("Audio session interrupted")
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended - resume audio session
                try? AVAudioSession.sharedInstance().setActive(true)
                print("Audio session resumed after interruption")
            }
        @unknown default:
            break
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
