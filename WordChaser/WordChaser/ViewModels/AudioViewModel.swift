import Foundation

class AudioViewModel: ObservableObject {
    private let audioService = AudioService()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var errorMessage: String?
    @Published var recordedFiles: [URL] = []

    init() {
        audioService.onPlaybackFinished = { [unowned self] in
            print("AudioViewModel: Playback Finished. Updating UI...")
            self.isPlaying = false
        }
    }

    func startRecording() {
        print("AudioViewModel: Starting recording...")
        if case .failure(let error) = audioService.startRecording() {
            errorMessage = error.localizedDescription
            print("Error starting recording: \(error.localizedDescription)")
        } else {
            isRecording = true
            errorMessage = nil
            print("AudioViewModel: Recording Started")
        }
    }

    func stopRecording() {
        print("AudioViewModel: Stopping recording...")
        if case .failure(let error) = audioService.stopRecording() {
            errorMessage = error.localizedDescription
            print("Error stopping recording: \(error.localizedDescription)")
        } else {
            isRecording = false
            errorMessage = nil
            recordedFiles = audioService.getRecordedFiles()
            print("AudioViewModel: Recording stopped successfully. Recorded files: \(recordedFiles.count)")
        }
    }

    func startPlaying() {
        print("AudioViewModel: Starting playback...")
        if case .failure(let error) = audioService.startPlaying() {
            errorMessage = error.localizedDescription
            print("Error starting playback: \(error.localizedDescription)")
        } else {
            isPlaying = true
            errorMessage = nil
            print("AudioViewModel: Playback started successfully.")
        }
    }

    func stopPlaying() {
        print("AudioViewModel: Stopping playback...")
        audioService.stopPlaying()
        isPlaying = false
        print("AudioViewModel: Playback stopped Manually.")
    }
}
