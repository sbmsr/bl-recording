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

    func startPlaying() -> Result<Void, Error> {
        print("AudioService: Starting playback...")
        let recordedFiles = audioRecorder.getRecordedFiles()

        guard let latestFile = recordedFiles.last else {
            print("Error: No recorded files found in the array.")
            return .failure(NSError(domain: "AudioService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recorded file found."]))
        }
        print("AudioService: Attempting to play: \(latestFile.path)")
        return audioPlayer.startPlaying(at: latestFile, delegate: audioManager)
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
