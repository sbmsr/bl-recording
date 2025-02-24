import Foundation
import AVFoundation

class AudioViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private let audioService = AudioService()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var errorMessage: String?
    @Published var recordedFiles: [URL] = []
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Double = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var selectedRecordingURL: URL?
    private var isPaused: Bool = false
    private var isScrubbing: Bool = false
    private var wasPlayingBeforeScrub: Bool = false

    override init() {
        super.init()
        
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
        
        if isPaused && selectedRecordingURL == recordingURL {
            player?.play()
            isPlaying = true
            startTimer()
            isPaused = false
            return
        }
        
        selectedRecordingURL = recordingURL
        
        do {
            player = try AVAudioPlayer(contentsOf: recordingURL)
            duration = player?.duration ?? 0
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            isPaused = false
            errorMessage = nil
            startTimer()
            print("AudioViewModel: Playback started successfully.")
        } catch {
            errorMessage = error.localizedDescription
            print("Error starting playback: \(error.localizedDescription)")
        }
    }

    func pausePlaying() {
        print("AudioViewModel: Pausing playback...")
        player?.pause()
        isPlaying = false
        isPaused = true
        stopTimer()
        print("AudioViewModel: Playback paused at: \(currentTime)")
    }

    func stopPlaying() {
        print("AudioViewModel: Stopping playback...")
        player?.stop()
        player = nil
        isPlaying = false
        isPaused = false
        stopTimer()
        currentTime = 0
        progress = 0
        print("AudioViewModel: Playback stopped and reset.")
    }

    func seek(to progress: Double) {
        guard let player = player else { return }
        
        if !player.isPlaying && !isPaused {
            player.prepareToPlay()
        }
        
        let time = progress * player.duration
        player.currentTime = time
        currentTime = time
        self.progress = progress
        
        if wasPlayingBeforeScrub {
            player.play()
            isPlaying = true
            startTimer()
        }
        
        print("AudioViewModel: Seeked to position: \(time)")
    }

    func startScrubbing() {
        wasPlayingBeforeScrub = isPlaying
        if isPlaying {
            player?.pause()
            stopTimer()
            isPlaying = false
        }
        isScrubbing = true
    }

    func endScrubbing() {
        isScrubbing = false
        seek(to: progress)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.player,
                  !self.isScrubbing else { return }
            
            self.currentTime = player.currentTime
            self.progress = player.currentTime / player.duration
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlaying()
            print("AudioViewModel: Playback finished naturally")
        }
    }
}
