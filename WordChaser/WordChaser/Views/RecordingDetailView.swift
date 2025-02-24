import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let recordingURL: URL
    @StateObject private var audioViewModel = AudioViewModel()
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            Text(recordingURL.lastPathComponent)
                .font(.headline)
                .padding()
            
            // Placeholder for waveform/scrobble view
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .padding()
            
            // Time and Progress
            VStack(spacing: 8) {
                Slider(value: $audioViewModel.progress) { editing in
                    if editing {
                        audioViewModel.startScrubbing()
                    } else {
                        audioViewModel.endScrubbing()
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text(timeString(from: audioViewModel.currentTime))
                        .font(.caption)
                        .monospacedDigit()
                    Spacer()
                    Text(timeString(from: audioViewModel.duration))
                        .font(.caption)
                        .monospacedDigit()
                }
                .padding(.horizontal)
            }
            
            // Playback Controls
            HStack(spacing: 20) {
                Spacer()
                
                Button(action: {
                    if audioViewModel.isPlaying {
                        audioViewModel.pausePlaying()
                    } else {
                        audioViewModel.startPlaying(url: recordingURL)
                    }
                }) {
                    Image(systemName: audioViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
            }
            .padding()
            
            if let errorMessage = audioViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
