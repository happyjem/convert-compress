import Foundation
import UniformTypeIdentifiers

/// Encapsulates all settings for image processing operations
struct ProcessingConfiguration: Codable, Equatable {
    let resizeMode: ResizeMode
    let resizeWidth: String
    let resizeHeight: String
    let resizeLongEdge: String
    let selectedFormat: ImageFormat?
    let compressionPercent: Double
    let flipV: Bool
    let removeMetadata: Bool
    let removeBackground: Bool
}

/// Cached result of a fully processed image (encoded data + format).
/// Stored alongside the configuration that produced it so consumers
/// can validate freshness before reuse.
struct ProcessedImageData {
    let data: Data
    let uti: UTType
    let configuration: ProcessingConfiguration
}

