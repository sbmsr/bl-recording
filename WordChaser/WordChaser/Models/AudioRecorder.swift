import AVFoundation
import Foundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordedFiles: [URL] = []
    private var recordingStartTime: Date?
    
    private let audioManager = AudioManager.shared

    func startRecording() -> Result<Void, Error> {
        print("AudioRecorder: Starting Recording...")
        recordingStartTime = Date()
        let newFileName = generateAudioFilename()
        
        let settings = AudioSettings.defaultSettings
        
        return Result {
            print("AudioRecorder: Attempting to start recording at: \(newFileName.path)")
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
                try AVAudioSession.sharedInstance().setActive(true)
                print("AudioRecorder: Audio Session Configured for Recording.")
            } catch {
                print("Failed to Configure Audio Session for Recording: \(error)")
                throw error
            }
            
            audioRecorder = try AVAudioRecorder(url: newFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            recordedFiles.append(newFileName)
            print("AudioRecorder: Recording Started")
        }
    }

    func stopRecording() -> Result<Void, Error> {
        print("AudioRecorder: Stop Recoding...")
        audioRecorder?.stop()
        audioRecorder = nil

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
    
}

