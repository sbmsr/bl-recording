import SwiftUI

struct ContentView: View {
    @StateObject private var audioViewModel = AudioViewModel()
    
    var body: some View {
        VStack {
            Text("Audio Recorder")
                .font(.largeTitle)
                .padding()

            if let errorMessage = audioViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            HStack {
                Button(action: {
                    if audioViewModel.isRecording {
                        audioViewModel.stopRecording()
                    } else {
                        audioViewModel.startRecording()
                    }
                }) {
                    Text(audioViewModel.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(audioViewModel.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if audioViewModel.isPlaying {
                        audioViewModel.stopPlaying()
                    } else {
                        audioViewModel.startPlaying()
                    }
                }) {
                    Text(audioViewModel.isPlaying ? "Stop Playing" : "Play Recording")
                        .padding()
                        .background(audioViewModel.isPlaying ? Color.red : Color.blue)
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
