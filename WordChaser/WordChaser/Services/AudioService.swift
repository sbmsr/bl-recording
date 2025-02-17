import AVFoundation
import Foundation

class AudioService {
    private let audioManager = AudioManager()
    private let audioRecorder = AudioRecorder()
    private let audioPlayer = AudioPlayer()
    
    private var lastRecordedFile: URL?
    
    var onPlaybackFinished: (() -> Void)? {
        get { audioManager.onPlaybackFinished }
        set { audioManager.onPlaybackFinished = newValue }
    }
    
    func startRecording() -> Result<Void, Error> {
        let result = audioRecorder.startRecording()
        if case .success = result {
            lastRecordedFile = audioRecorder.audioFileName
        }
        return result
    }
    
    func stopRecording() -> Result<Void, Error> {
        return audioRecorder.stopRecording()
    }
    
    func startPlaying() -> Result<Void, Error> {
        guard let url = lastRecordedFile else {
            return .failure(NSError(domain: "AudioService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recorded file found."]))
        }
        return audioPlayer.startPlaying(at: url, delegate: audioManager)
    }
    
    func stopPlaying() {
        audioPlayer.stopPlaying()
    }
}
