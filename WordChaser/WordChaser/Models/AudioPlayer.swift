import AVFoundation
import Foundation

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    var onPlaybackFinished: (() -> Void)?
    
    private let audioManager = AudioManager.shared
    
    
    func startPlaying(at url: URL, delegate: AudioManager) -> Result<Void, Error> {
        print("AudioPlayer: Attempting to play: \(url.path)")
        
        delegate.resetAudioSession()
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Error: File does not exist.")
            return .failure(NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "File does not exist."]))
        }
        
        guard FileManager.default.isReadableFile(atPath: url.path) else {
            print("Error: File is not readable.")
            return .failure(NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "File is not readable."]))
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = delegate
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("AudioPlayer: Playback started successfully.")
            return .success(())
        } catch {
            print("AVAudioPlayer initialization failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    func stopPlaying() {
        print("AudioPlayer: Stopping Playback Mually & Cleaning up Resources...")
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("AudioPlayer: Audio Session Reset to .playAndRecord")
        } catch {
            print("AudioPlayer: Failed to Reset Audio Session: \(error)")
        }
        
        onPlaybackFinished?()
        print("AudioPlayer: Playback Stopped Manually & Resources Cleaned up.")
    }
}
