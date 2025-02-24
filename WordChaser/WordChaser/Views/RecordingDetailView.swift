import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let recordingURL: URL
    @StateObject private var audioViewModel = AudioViewModel()
    
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
            
            HStack {
                Button(action: {
                    if audioViewModel.isPlaying {
                        audioViewModel.stopPlaying()
                    } else {
                        audioViewModel.startPlaying(url: recordingURL)
                    }
                }) {
                    Image(systemName: audioViewModel.isPlaying ? "stop.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(audioViewModel.isPlaying ? Color.red : Color.blue)
                        .clipShape(Circle())
                }
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
