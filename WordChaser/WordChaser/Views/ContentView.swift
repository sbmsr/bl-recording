//
//  ContentView.swift
//  WordChaser
//
//  Created by Gus on 15/02/25.
//

import SwiftUI
import AVFoundation
import Foundation

class AudioManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isRecording = false
    @Published var isPlaying = false
    
    private var audioFileName: URL?
    
    override init() {
        super.init()

        // Set the audio session category to playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Request microphone permission
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { response in
                if response {
                    print("Microphone access granted.")
                } else {
                    print("Microphone access denied.")
                }
            }
        } else {
            // Fallback for earlier versions
            AVAudioSession.sharedInstance().requestRecordPermission { response in
                if response {
                    print("Microphone access granted.")
                } else {
                    print("Microphone access denied.")
                }
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        audioFileName = audioFilename
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            print("Recording started at: \(audioFilename.path)")
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let audioFilename = audioFileName {
            if FileManager.default.fileExists(atPath: audioFilename.path) {
                print("Recording saved successfully at: \(audioFilename.path)")
            } else {
                print("Recording file not found.")
            }
        }
    }
    
    func startPlaying() {
        guard let audioFilename = audioFileName else {
            print("No audio file to play")
            return
        }
        
        if !FileManager.default.fileExists(atPath: audioFilename.path) {
            print("Audio file does not exist at path: \(audioFilename.path)")
            return
        }
        
        do {
            // Verify file size
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize == 0 {
                print("Audio file is empty.")
                return
            }
            
            // Set audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Initialize and play audio
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            print("Playback started successfully.")
        } catch {
            print("Error starting playback: \(error)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AudioManager: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.")
        } else {
            print("Recording failed.")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Playback finished successfully.")
        } else {
            print("Playback failed.")
        }
        isPlaying = false
    }
}

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        VStack {
            Text("Audio Recorder")
                .font(.largeTitle)
                .padding()

            HStack {
                Button(action: {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    } else {
                        audioManager.startRecording()
                    }
                }) {
                    Text(audioManager.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(audioManager.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.stopPlaying()
                    } else {
                        audioManager.startPlaying()
                    }
                }) {
                    Text(audioManager.isPlaying ? "Stop Playing" : "Play Recording")
                        .padding()
                        .background(audioManager.isPlaying ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
