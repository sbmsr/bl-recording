import AVFoundation
import Foundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordedFiles: [URL] = []
    private var recordingStartTime: Date?
    private var chunkTimer: Timer?
    private let chunkDuration: TimeInterval = 10 // 10 second chunks
    private var isSessionConfigured = false
    
    private let audioManager = AudioManager.shared

    func startRecording() -> Result<Void, Error> {
        print("AudioRecorder: Starting Recording...")
        
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
        
        let settings = AudioSettings.defaultSettings
        
        return Result {
            print("AudioRecorder: Attempting to start recording at: \(newFileName.path)")
            
            audioRecorder = try AVAudioRecorder(url: newFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            recordedFiles.append(newFileName)
            print("AudioRecorder: Recording Started")
            
            // Start timer for next chunk
            chunkTimer?.invalidate()
            chunkTimer = Timer.scheduledTimer(withTimeInterval: chunkDuration, repeats: false) { [weak self] _ in
                self?.startNextChunk()
            }
        }
    }
    
    private func startNextChunk() {
        print("AudioRecorder: Starting new chunk...")
        if let recorder = audioRecorder {
            recorder.stop()
            if case .failure(let error) = startNewChunk() {
                print("AudioRecorder: Failed to start new chunk: \(error)")
            }
        }
    }

    func stopRecording() -> Result<Void, Error> {
        print("AudioRecorder: Stop Recording...")
        chunkTimer?.invalidate()
        chunkTimer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        isSessionConfigured = false

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Warning: Failed to deactivate audio session: \(error)")
        }

        Thread.sleep(forTimeInterval: 0.5)

        guard let lastFile = recordedFiles.last else {
            print("Error: No recorded files found.")
            return .failure(NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "No file to save."]))
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: lastFile.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("AudioRecorder: File size: \(fileSize) bytes")
            guard fileSize > 0 else {
                print("Error: File is empty.")
                return .failure(NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "File is empty."]))
            }
        } catch {
            print("Error Checking File Attributes: \(error)")
            return .failure(error)
        }

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
    }
}

