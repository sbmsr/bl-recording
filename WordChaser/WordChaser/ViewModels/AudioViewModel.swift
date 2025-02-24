import Foundation

class AudioViewModel: ObservableObject {
    private let audioService = AudioService()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var errorMessage: String?
    @Published var recordedFiles: [URL] = []
    private var selectedRecordingURL: URL?

    init() {
        audioService.onPlaybackFinished = { [unowned self] in
            print("AudioViewModel: Playback Finished. Updating UI...")
            self.isPlaying = false
        }
        
        audioService.onNewChunkSaved = { [weak self] in
            print("AudioViewModel: New chunk saved, updating file list...")
            DispatchQueue.main.async {
                self?.recordedFiles = self?.audioService.getRecordedFiles() ?? []
            }
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

    func startPlaying(url: URL? = nil) {
        print("AudioViewModel: Starting playback...")
        let fileToPlay = url ?? recordedFiles.last
        
        guard let recordingURL = fileToPlay else {
            errorMessage = "No recording file available"
            print("Error: No recording file available")
            return
        }
        
        selectedRecordingURL = recordingURL
        
        if case .failure(let error) = audioService.startPlaying(url: recordingURL) {
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
