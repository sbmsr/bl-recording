import AVFoundation
import Foundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    var audioFileName: URL?
    private var recordingStartTime: Date?
    
    func startRecording() -> Result<Void, Error> {
        recordingStartTime = Date()
        audioFileName = generateAudioFilename()
        
        let settings = AudioSettings.defaultSettings
        
        return Result {
            audioRecorder = try AVAudioRecorder(url: audioFileName!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("Recording started at: \(audioFileName!.path)")
        }
    }
    
    func stopRecording() -> Result<Void, Error> {
        audioRecorder?.stop()
        audioRecorder = nil
        
        guard let audioFilename = audioFileName else {
            return .failure(NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "No file to save."]))
        }
        
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            print("Recording saved at: \(audioFilename.path)")
            return .success(())
        } else {
            return .failure(NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found."]))
        }
    }
    
    private func generateAudioFilename() -> URL {
        let filename = "record-\(DateFormatter.audioFilenameFormatter.string(from: Date())).m4a"
        return FileManagerService.getDocumentsDirectory().appendingPathComponent(filename)
    }
}

