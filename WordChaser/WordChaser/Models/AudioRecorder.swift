import AVFoundation
import Foundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordedFiles: [URL] = []
    private var recordingStartTime: Date?
    private var chunkTimer: Timer?
    private let chunkDuration: TimeInterval = 10 // 10 second chunks
    private var isSessionConfigured = false
    private var currentRecordingURL: URL?
    private var shouldStartNewChunk = false
    private var isStopping = false  // New flag to track stopping state
    
    private let audioManager = AudioManager.shared
    var onNewChunkSaved: (() -> Void)?

    func startRecording() -> Result<Void, Error> {
        print("AudioRecorder: Starting Recording...")
        recordedFiles = []  // Reset files list when starting new recording
        
        // Configure audio session only once at the start
        if !isSessionConfigured {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
                try AVAudioSession.sharedInstance().setActive(true)
                isSessionConfigured = true
                print("AudioRecorder: Audio Session Configured for Recording.")
            } catch {
                print("Failed to Configure Audio Session for Recording: \(error)")
                return .failure(error)
            }
        }
        
        return startNewChunk()
    }

    private func startNewChunk() -> Result<Void, Error> {
        recordingStartTime = Date()
        let newFileName = generateAudioFilename()
        currentRecordingURL = newFileName
        shouldStartNewChunk = false
        
        let settings = AudioSettings.defaultSettings
        
        return Result {
            print("AudioRecorder: Attempting to start recording at: \(newFileName.path)")
            
            audioRecorder = try AVAudioRecorder(url: newFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("AudioRecorder: Recording Started")
            
            // Start timer for next chunk
            chunkTimer?.invalidate()
            chunkTimer = Timer.scheduledTimer(withTimeInterval: chunkDuration, repeats: false) { [weak self] _ in
                self?.handleChunkTimeout()
            }
        }
    }
    
    private func handleChunkTimeout() {
        print("AudioRecorder: Chunk timeout, preparing for next chunk...")
        shouldStartNewChunk = true
        audioRecorder?.stop()  // This will trigger audioRecorderDidFinishRecording
    }
    
    private func startNextChunk() {
        print("AudioRecorder: Starting next chunk...")
        if case .failure(let error) = startNewChunk() {
            print("AudioRecorder: Failed to start new chunk: \(error)")
        }
    }

    func stopRecording() -> Result<Void, Error> {
        print("AudioRecorder: Stop Recording...")
        chunkTimer?.invalidate()
        chunkTimer = nil
        shouldStartNewChunk = false
        isStopping = true  // Set stopping flag
        
        // Stop the current recording - this will trigger audioRecorderDidFinishRecording
        audioRecorder?.stop()
        
        return .success(())
    }

    func getRecordedFiles() -> [URL] {
        print("AudioRecorder: Total Retrieved Files \(recordedFiles.count)")
        return recordedFiles
    }

    private func generateAudioFilename() -> URL {
        let filename = "record-\(DateFormatter.audioFilenameFormatter.string(from: Date())).m4a"
        let fileURL = FileManagerService.getDocumentsDirectory().appendingPathComponent(filename)
        print("AudioRecorder: Generated new filename: \(fileURL.path)")
        return fileURL
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("AudioRecorder: Recording chunk finished with success: \(flag)")
        
        if flag, let url = currentRecordingURL {
            // Give the file system a moment to finish writing
            Thread.sleep(forTimeInterval: 0.1)
            
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                print("AudioRecorder: Chunk file size: \(fileSize) bytes")
                
                if fileSize > 0 {
                    recordedFiles.append(url)
                    onNewChunkSaved?()
                    print("AudioRecorder: Successfully saved chunk: \(url.lastPathComponent)")
                    
                    if shouldStartNewChunk {
                        startNextChunk()
                    } else if isStopping {
                        // Clean up only after the final chunk is saved
                        audioRecorder = nil
                        isSessionConfigured = false
                        currentRecordingURL = nil
                        isStopping = false
                        
                        // Deactivate audio session
                        do {
                            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("Warning: Failed to deactivate audio session: \(error)")
                        }
                    }
                } else {
                    print("AudioRecorder: Skipping empty chunk")
                    if shouldStartNewChunk {
                        startNextChunk()
                    }
                }
            } catch {
                print("AudioRecorder: Error checking chunk file: \(error)")
                if shouldStartNewChunk {
                    startNextChunk()
                }
            }
        } else {
            print("AudioRecorder: Recording failed or no current URL")
            if shouldStartNewChunk {
                startNextChunk()
            }
        }
    }
}

