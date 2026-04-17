import Foundation
import Combine

extension ImageToolsViewModel {
    private typealias Keys = StorageKeys.Pipeline

    /// Installs Combine sinks that persist pipeline settings as they change.
    func setupPersistenceObservation() {
        let defaults = UserDefaults.standard

        $exportDirectory.dropFirst().sink { dir in
            if let dir { defaults.set(dir.path, forKey: Keys.exportDirectory) }
            else { defaults.removeObject(forKey: Keys.exportDirectory) }
        }.store(in: &cancellables)

        $resizeMode.dropFirst().sink { mode in
            defaults.set(mode == .resize ? "resize" : "crop", forKey: Keys.resizeMode)
        }.store(in: &cancellables)

        $resizeWidth.dropFirst().sink { width in
            defaults.set(width, forKey: Keys.resizeWidth)
        }.store(in: &cancellables)

        $resizeHeight.dropFirst().sink { height in
            defaults.set(height, forKey: Keys.resizeHeight)
        }.store(in: &cancellables)

        $resizeLongEdge.dropFirst().sink { longEdge in
            defaults.set(longEdge, forKey: Keys.resizeLongEdge)
        }.store(in: &cancellables)

        $selectedFormat.dropFirst().sink { [weak self] newFormat in
            defaults.set(newFormat?.id, forKey: Keys.selectedFormat)
            self?.onSelectedFormatChanged(newFormat)
        }.store(in: &cancellables)

        $recentFormats.dropFirst().sink { formats in
            defaults.set(formats.map { $0.id }, forKey: Keys.recentFormats)
        }.store(in: &cancellables)

        $compressionPercent.dropFirst().sink { percent in
            defaults.set(percent, forKey: Keys.compressionPercent)
        }.store(in: &cancellables)

        $flipV.dropFirst().sink { flip in
            defaults.set(flip, forKey: Keys.flipV)
        }.store(in: &cancellables)

        $removeBackground.dropFirst().sink { remove in
            defaults.set(remove, forKey: Keys.removeBackground)
        }.store(in: &cancellables)

        $removeMetadata.dropFirst().sink { remove in
            defaults.set(remove, forKey: Keys.removeMetadata)
        }.store(in: &cancellables)
    }

    func loadPersistedState() {
        let defaults = UserDefaults.standard

        if let exportPath = defaults.string(forKey: Keys.exportDirectory) {
            exportDirectory = URL(fileURLWithPath: exportPath)
        }

        if let modeRaw = defaults.string(forKey: Keys.resizeMode) {
            resizeMode = (modeRaw == "resize") ? .resize : .crop
        }
        if let width = defaults.string(forKey: Keys.resizeWidth) {
            resizeWidth = width
        }
        if let height = defaults.string(forKey: Keys.resizeHeight) {
            resizeHeight = height
        }
        if let longEdge = defaults.string(forKey: Keys.resizeLongEdge) {
            resizeLongEdge = longEdge
        }

        if let selRaw = defaults.string(forKey: Keys.selectedFormat),
           let fmt = ImageIOCapabilities.shared.format(forIdentifier: selRaw) {
            if ImageIOCapabilities.shared.supportsWriting(utType: fmt.utType) {
                selectedFormat = fmt
            }
        }
        if let raw = defaults.array(forKey: Keys.recentFormats) as? [String] {
            let mapped = raw.compactMap { ImageIOCapabilities.shared.format(forIdentifier: $0) }
            if !mapped.isEmpty {
                recentFormats = Array(mapped.prefix(3))
            }
        }

        if defaults.object(forKey: Keys.compressionPercent) != nil {
            compressionPercent = defaults.double(forKey: Keys.compressionPercent)
        }
        if defaults.object(forKey: Keys.flipV) != nil {
            flipV = defaults.bool(forKey: Keys.flipV)
        }
        if defaults.object(forKey: Keys.removeBackground) != nil {
            removeBackground = defaults.bool(forKey: Keys.removeBackground)
        }
        if defaults.object(forKey: Keys.removeMetadata) != nil {
            removeMetadata = defaults.bool(forKey: Keys.removeMetadata)
        }
    }
}
