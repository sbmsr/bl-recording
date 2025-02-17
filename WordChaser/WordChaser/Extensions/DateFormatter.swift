import Foundation

// MARK: - Date Formatting for Audio Files
// Provides a standardized way to format dates for audio filenames
extension DateFormatter {
    // Shared date formatter configured for audio file naming
    // Currently it supports only starting time, however:
    // -! We might want to add the ending time for audio chunk manipulation
    // -!! Counterpoint: we might use the AudioFile struct to handle it through metadata
    static var audioFilenameFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HHmmss"
        return formatter
    }
}
