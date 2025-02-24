import AVFoundation
import Foundation

class AudioService {
    private let audioManager = AudioManager.shared
    private let audioRecorder = AudioRecorder()
    private let audioPlayer = AudioPlayer()

    var onPlaybackFinished: (() -> Void)? {
        get { audioManager.onPlaybackFinished }
        set { audioManager.onPlaybackFinished = newValue }
    }

    func startRecording() -> Result<Void, Error> {
        print("AudioService: Starting recording...")
        return audioRecorder.startRecording()
    }

    func stopRecording() -> Result<Void, Error> {
        print("AudioService: Stopping recording...")
        return audioRecorder.stopRecording()
    }

    func startPlaying(url: URL) -> Result<Void, Error> {
        print("AudioService: Starting playback...")
        print("AudioService: Attempting to play: \(url.path)")
        return audioPlayer.startPlaying(at: url, delegate: audioManager)
    }

    func stopPlaying() {
        print("AudioService: Stopping playback...")
        audioPlayer.stopPlaying()
    }

    func getRecordedFiles() -> [URL] {
        print("AudioService: Retrieving recorded files...")
        return audioRecorder.getRecordedFiles()
    }
}
