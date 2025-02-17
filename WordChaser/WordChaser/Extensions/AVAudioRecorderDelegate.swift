import AVFoundation
// MARK: - Audio Recording Delegate
// Handles events related to audio recording completion
extension AudioManager: AVAudioRecorderDelegate {
    // Called when audio recording finishes (either stopped manually or due to an error)
    // -! Soon it will be stopped manually, or due to an error, or automatic generation of a new audio chunk
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Recording finished: \(flag ? "success" : "failure")")
        // We will need to define it better soon, but the practical logic will be here
        // Currently we will deal with debugging mostly
    }
}
