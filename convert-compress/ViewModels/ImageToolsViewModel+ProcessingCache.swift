import Foundation
import Combine
import UniformTypeIdentifiers

extension ImageToolsViewModel {

    // MARK: - Preview

    func previewInfo(for asset: ImageAsset) -> PreviewInfo {
        PreviewEstimator.estimate(
            for: asset,
            resizeMode: resizeMode,
            resizeWidth: resizeWidth,
            resizeHeight: resizeHeight,
            resizeLongEdge: resizeLongEdge,
            compressionPercent: compressionPercent,
            selectedFormat: selectedFormat
        )
    }

    // MARK: - Cache Accessors

    func estimatedByteCount(for assetID: UUID) -> Int? {
        guard let cached = processedCache[assetID],
              cached.configuration == currentConfiguration else {
            return nil
        }
        return cached.data.count
    }

    func cachedProcessedData(for assetID: UUID) -> ProcessedImageData? {
        guard let cached = processedCache[assetID],
              cached.configuration == currentConfiguration else {
            return nil
        }
        return cached
    }

    // MARK: - Background Processing

    func updateVisibleAssets(_ ids: Set<UUID>) {
        visibleAssetIDs = ids
        scheduleProcessing()
    }

    func scheduleProcessing() {
        processingDebouncer.schedule(after: .milliseconds(150)) { [weak self] in
            self?.runProcessing()
        }
    }

    /// Re-processes visible assets when the configuration has changed.
    func setupProcessingCacheObservation() {
        var lastConfig = currentConfiguration
        objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let config = self.currentConfiguration
                guard config != lastConfig else { return }
                lastConfig = config
                self.scheduleProcessing()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private

    private func runProcessing() {
        processingTask?.cancel()
        let config = currentConfiguration
        let assetsToProcess = images
            .filter { visibleAssetIDs.contains($0.id) }
            .filter { processedCache[$0.id]?.configuration != config }
        guard !assetsToProcess.isEmpty else { return }

        processingTask = Task(priority: .utility) { [weak self] in
            guard let self else { return }
            let results = await TrueSizeEstimator.estimate(
                assets: assetsToProcess,
                configuration: config
            )
            guard !Task.isCancelled else { return }
            self.processedCache.merge(results) { _, new in new }
        }
    }
}
