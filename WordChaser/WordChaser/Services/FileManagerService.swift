import Foundation

class FileManagerService {
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func listAudioFiles() -> [URL] {
        let documentsDirectory = getDocumentsDirectory()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "m4a" }
        } catch {
            print("Failed to list files: \(error)")
            return []
        }
    }

    static func generateAudioFilename() -> URL {
        let filename = "record-\(DateFormatter.audioFilenameFormatter.string(from: Date())).m4a"
        return getDocumentsDirectory().appendingPathComponent(filename)
    }
}
