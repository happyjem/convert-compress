import CoreGraphics
import Foundation

struct ImageChangeInfo {
    let resolutionChanged: Bool
    let fileSizeChanged: Bool
    let formatChanged: Bool
    let originalPixelSize: CGSize?
    let targetPixelSize: CGSize?
    let originalFileSize: Int?
    let estimatedOutputSize: Int?
    let originalFormat: ImageFormat?
    let targetFormat: ImageFormat?

    var hasChanges: Bool {
        resolutionChanged || fileSizeChanged || formatChanged
    }

    @MainActor
    init(asset: ImageAsset, vm: ImageToolsViewModel) {
        let preview = vm.previewInfo(for: asset)

        self.originalPixelSize = asset.originalPixelSize
        self.targetPixelSize = preview.targetPixelSize
        self.originalFileSize = asset.originalFileSizeBytes
        self.estimatedOutputSize = vm.estimatedByteCount(for: asset.id)
        self.originalFormat = ImageExporter.inferFormat(from: asset.originalURL)
        self.targetFormat = vm.selectedFormat ?? originalFormat

        self.resolutionChanged = Self.hasResolutionChange(
            from: originalPixelSize,
            to: targetPixelSize
        )
        self.fileSizeChanged = Self.hasFileSizeChange(
            from: originalFileSize,
            to: estimatedOutputSize
        )
        self.formatChanged = (originalFormat != targetFormat)
    }

    private static func hasResolutionChange(from original: CGSize?, to target: CGSize?) -> Bool {
        guard let original, let target else {
            return false
        }
        return Int(original.width) != Int(target.width) || Int(original.height) != Int(target.height)
    }

    private static func hasFileSizeChange(from original: Int?, to target: Int?) -> Bool {
        guard let original, let target else {
            return false
        }
        return original != target
    }
}
