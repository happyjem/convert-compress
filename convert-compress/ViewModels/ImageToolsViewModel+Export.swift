import Foundation
import SwiftUI
import AppKit

extension ImageToolsViewModel {
    func buildPipeline() -> ProcessingPipeline {
        let keepStructure = UserDefaults.standard.bool(forKey: StorageKeys.Preferences.keepFolderStructure)
        return PipelineBuilder().build(
            configuration: currentConfiguration,
            exportDirectory: exportDirectory,
            folderStructureRoot: keepStructure ? sourceDirectory : nil
        )
    }

    /// Recommended concurrency for export, balancing CPU / memory / thermal state.
    func recommendedConcurrency() -> Int {
        ExportConcurrencyPolicy.recommended()
    }

    func applyPipelineAsync() {
        PaywallCoordinator.shared.requestAccess { [weak self] in
            self?.executeExport()
        }
    }

    private func executeExport() {
        let pipeline = buildPipeline()
        if let selectedFormat { bumpRecentFormats(selectedFormat) }
        let config = currentConfiguration
        let targets = images
        guard !targets.isEmpty else { return }

        if !preflightReplaceIfNecessary(pipeline: pipeline, targets: targets) {
            return
        }

        let directories = uniqueDestinationDirectories(for: targets, pipeline: pipeline)
        let cacheSnapshot = processedCache.snapshot()

        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            for directory in directories {
                let message = String(localized: "Allow \(AppConstants.localizedAppName) to save files in \(directory.lastPathComponent)?")
                let granted = await SandboxAccessManager.shared.requestAccessIfNeeded(to: directory, message: message)
                if !granted {
                    self.presentAccessDeniedAlert(for: directory)
                    return
                }
            }

            self.beginExport(total: targets.count)

            let runner = ExportRunner(
                pipeline: pipeline,
                configuration: config,
                cacheSnapshot: cacheSnapshot,
                maxConcurrent: self.recommendedConcurrency()
            )
            let updatedImages = await runner.run(
                targets: targets,
                initialImages: self.imagesSnapshot()
            ) {
                self.incrementExportProgress()
            }

            self.finishExport(with: updatedImages)
        }
    }
}

extension ImageToolsViewModel {
    private func beginExport(total: Int) {
        exportProgress.begin(total: total)
    }

    private func incrementExportProgress() {
        exportProgress.increment()
    }

    private func finishExport(with imagesToCommit: [ImageAsset]) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
            images = imagesToCommit
        }
        exportProgress.reset()

        let processedCount = imagesToCommit.filter { $0.isEdited }.count
        UsageTracker.shared.recordPipelineApplied(imageCount: processedCount)
        RatingCoordinator.shared.checkAndShowIfNeeded()

        if UserDefaults.standard.object(forKey: StorageKeys.Preferences.revealExportInFinder) as? Bool ?? true {
            let urlsToReveal = imagesToCommit.compactMap { $0.isEdited ? $0.workingURL : nil }
            if !urlsToReveal.isEmpty {
                NSWorkspace.shared.activateFileViewerSelecting(urlsToReveal)
            }
        }
    }

    private func imagesSnapshot() -> [ImageAsset] {
        images
    }

    /// Returns true if export should proceed, false if user cancelled.
    private func preflightReplaceIfNecessary(pipeline: ProcessingPipeline, targets: [ImageAsset]) -> Bool {
        guard !targets.isEmpty else { return true }
        let planned: [URL] = targets.map { pipeline.plannedDestinationURL(for: $0) }
        let uniquePlanned = Array(Set(planned))
        let fm = FileManager.default
        let conflicts = uniquePlanned.filter { fm.fileExists(atPath: $0.path) }
        guard !conflicts.isEmpty else { return true }

        let parentDirs = Set(conflicts.map { $0.deletingLastPathComponent().path })
        let folderHintPath = parentDirs.count == 1 ? parentDirs.first! : nil
        let message = String(localized: "Replace existing files?")
        let count = conflicts.count
        var info = ""
        if let folderPath = folderHintPath {
            let folderName = FileManager.default.displayName(atPath: folderPath)
            if count == 1 {
                info = String(format: String(localized: "1 file already exists in \"%@\". Replacing will overwrite it."), folderName)
            } else {
                info = String(format: String(localized: "%d files already exist in \"%@\". Replacing will overwrite them."), count, folderName)
            }
        } else {
            if count == 1 {
                info = String(localized: "1 file with the same name already exists. Replacing will overwrite it.")
            } else {
                info = String(format: String(localized: "%d files with the same name already exist. Replacing will overwrite them."), count)
            }
        }

        func presentAlert() -> Bool {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = message
            alert.informativeText = info

            let replaceButton = alert.addButton(withTitle: String(localized: "Replace"))
            replaceButton.hasDestructiveAction = true

            alert.addButton(withTitle: String(localized: "Cancel"))
            if let icon = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil) {
                alert.icon = icon
            }
            let resp = alert.runModal()
            return resp == .alertFirstButtonReturn
        }

        return presentAlert()
    }

    func uniqueDestinationDirectories(for targets: [ImageAsset], pipeline: ProcessingPipeline) -> [URL] {
        let destinations = targets.map { pipeline.plannedDestinationURL(for: $0).deletingLastPathComponent().standardizedFileURL }
        var seen: Set<URL> = []
        var result: [URL] = []
        for directory in destinations {
            if !seen.contains(directory) {
                seen.insert(directory)
                result.append(directory)
            }
        }
        return result
    }

    @MainActor
    func presentAccessDeniedAlert(for directory: URL) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = String(localized: "Permission needed")
        alert.informativeText = String(localized: "\(AppConstants.localizedAppName) needs access to save files in \(directory.lastPathComponent). Please choose Allow when prompted.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.runModal()
    }
}
