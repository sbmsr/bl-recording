import Foundation
class AudioViewModel: ObservableObject {
    private let audioService = AudioService()
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var errorMessage: String?
    
    init() {
        audioService.onPlaybackFinished = { [weak self] in
            self?.isPlaying = false
        }
    }
    
    func startRecording() {
        if case .failure(let error) = audioService.startRecording() {
            errorMessage = error.localizedDescription
        } else {
            isRecording = true
            errorMessage = nil
        }
    }
    
    func stopRecording() {
        if case .failure(let error) = audioService.stopRecording() {
            errorMessage = error.localizedDescription
        } else {
            isRecording = false
            errorMessage = nil
        }
    }
    
    func startPlaying() {
        if case .failure(let error) = audioService.startPlaying() {
            errorMessage = error.localizedDescription
        } else {
            isPlaying = true
            errorMessage = nil
        }
    }
    
    func stopPlaying() {
        audioService.stopPlaying()
        isPlaying = false
    }
}
