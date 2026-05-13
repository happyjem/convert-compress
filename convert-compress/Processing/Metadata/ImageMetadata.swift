import Foundation
import ImageIO

struct ImageMetadata {
    static func pixelSize(for data: Data) -> CGSize? {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let widthNumber = properties[kCGImagePropertyPixelWidth] as? NSNumber,
           let heightNumber = properties[kCGImagePropertyPixelHeight] as? NSNumber {
            return CGSize(width: CGFloat(truncating: widthNumber), height: CGFloat(truncating: heightNumber))
        }
        return nil
    }
}


