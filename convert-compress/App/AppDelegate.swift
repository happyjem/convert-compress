import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var sharedViewModel: ImageToolsViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.servicesProvider = self
        TemporaryFileManager.cleanupTempFiles()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let viewModel = AppDelegate.sharedViewModel else { return }
        let expandedURLs = urls.flatMap { IngestionCoordinator.expandToSupportedImageURLs(from: $0) }
        viewModel.addURLs(expandedURLs)
    }

    @objc func handleFinderService(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return
        }

        let expandedURLs = urls.flatMap { url -> [URL] in
            IngestionCoordinator.expandToSupportedImageURLs(from: url.standardizedFileURL)
        }

        self.application(NSApp, open: expandedURLs)
    }
}
