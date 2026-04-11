import Foundation
import Combine
import UniformTypeIdentifiers

extension ImageToolsViewModel {

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
        processingDebounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.runProcessing()
        }
        processingDebounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: work)
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
