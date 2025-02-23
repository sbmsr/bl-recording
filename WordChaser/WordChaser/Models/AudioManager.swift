import AVFoundation

class AudioManager: NSObject {
    private var audioFileName: URL?
    private var recordingStartTime: Date?
    
    static let shared = AudioManager()
    
    var onPlaybackFinished: (() -> Void)?
    
    override init() {
        super.init()
        print("AudioManager initialized: \(Unmanaged.passUnretained(self).toOpaque())")
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
    
    func resetAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("AudioManager: Audio Session Reset Successfully.")
        } catch {
            print("AudioManager: Failed to Reset Audio Session: \(error)")
        }
    }
    
    private func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                print("Microphone Access Granted: \(granted)")
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print("Microphone Access Granted: \(granted)")
            }
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
}

