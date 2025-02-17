import AVFoundation
import Foundation

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    var onPlaybackFinished: (() -> Void)?
    
    func startPlaying(at url: URL, delegate: AudioManager) -> Result<Void, Error> {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .failure(NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "File does not exist."]))
        }
        
        return Result {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = delegate 
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playback started.")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        onPlaybackFinished?()
    }
}
