import Foundation

/// Cleans up temp files from the app's container temp directory on launch.
enum TemporaryFileManager {
    private static let removablePrefixes = ["paste_"]
    private static let removableMarkers = ["_tmp_"]
    
    /// Clean up accumulated temp files from the container temp directory.
    /// Call this on app launch to prevent buildup.
    static func cleanupTempFiles() {
        DispatchQueue.global(qos: .utility).async {
            let containerTempDir = FileManager.default.temporaryDirectory
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: containerTempDir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ) else { return }
            
            for url in contents {
                guard shouldRemove(url) else { continue }
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    AppLogger.processing.warning("Temp cleanup failed for \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    private static func shouldRemove(_ url: URL) -> Bool {
        let name = url.lastPathComponent
        return removablePrefixes.contains { name.hasPrefix($0) }
            || removableMarkers.contains { name.contains($0) }
    }
}
