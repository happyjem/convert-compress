import Foundation
import AppKit

struct ComparisonSelection: Equatable {
    let assetID: UUID
}

struct ComparisonPreviewState {
    var originalImage: NSImage?
    var processedImage: NSImage?
    var isLoading: Bool
    var errorMessage: String?
    var cropRegion: CGRect?
    var originalSize: CGSize?
    var processedSize: CGSize?

    static let empty = ComparisonPreviewState(
        originalImage: nil,
        processedImage: nil,
        isLoading: false,
        errorMessage: nil,
        cropRegion: nil,
        originalSize: nil,
        processedSize: nil
    )
}
