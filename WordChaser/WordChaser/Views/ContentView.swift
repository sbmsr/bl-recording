import SwiftUI

struct ContentView: View {
    @StateObject private var audioViewModel = AudioViewModel()

    var body: some View {
        NavigationView {
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
                }
                .padding()

                List(audioViewModel.recordedFiles, id: \.self) { file in
                    NavigationLink(destination: RecordingDetailView(recordingURL: file)) {
                        HStack {
                            Text(file.lastPathComponent)
                            Spacer()
                            Text(getFileSizeFormatted(for: file))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

func getFileSizeFormatted(for file: URL) -> String {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    } catch {
        return "Unknown"
    }
}
