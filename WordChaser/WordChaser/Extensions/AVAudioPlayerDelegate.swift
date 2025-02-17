import AVFoundation

// MARK: - Audio Playback Delegate
// Handles events related to audio playback completion
extension AudioManager: AVAudioPlayerDelegate {
    // Called when audio playback finishes (either when the audio reaches the end or manual interruption)
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Playback finished: \(flag ? "success" : "failure")")
        
        onPlaybackFinished?()
    }
}
