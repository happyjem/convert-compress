import Foundation
import CoreGraphics

struct ResizeMath {
    static func targetSize(for original: CGSize, input: ResizeInput, noUpscale: Bool) -> CGSize {
        guard original.width > 0, original.height > 0 else { return CGSize(width: 0, height: 0) }

        switch input {
        case .percent(let p):
            let minScale = 0.01
            let unclamped = max(p, minScale)
            let scale = noUpscale ? min(unclamped, 1.0) : unclamped
            let w = max(1, (original.width * scale).rounded())
            let h = max(1, (original.height * scale).rounded())
            return CGSize(width: w, height: h)

        case .pixels(let widthOption, let heightOption):
            if let width = widthOption, heightOption == nil {
                let ratio = original.height / original.width
                let targetWidth = CGFloat(width)
                let cappedWidth = noUpscale ? min(targetWidth, original.width) : targetWidth
                let height = max(1, (cappedWidth * ratio).rounded())
                let finalWidth = max(1, cappedWidth.rounded())
                return CGSize(width: finalWidth, height: height)
            } else if let height = heightOption, widthOption == nil {
                let ratio = original.width / original.height
                let targetHeight = CGFloat(height)
                let cappedHeight = noUpscale ? min(targetHeight, original.height) : targetHeight
                let width = max(1, (cappedHeight * ratio).rounded())
                let finalHeight = max(1, cappedHeight.rounded())
                return CGSize(width: width, height: finalHeight)
            } else {
                var width = CGFloat(widthOption ?? Int(original.width))
                var height = CGFloat(heightOption ?? Int(original.height))
                if noUpscale {
                    width = min(width, original.width)
                    height = min(height, original.height)
                }
                return CGSize(width: max(1, width.rounded()), height: max(1, height.rounded()))
            }
            
        case .longEdge(let targetLongEdge):
            let isWidthLonger = original.width >= original.height
            let targetSize = CGFloat(targetLongEdge)
            let cappedTarget = noUpscale ? min(targetSize, max(original.width, original.height)) : targetSize
            
            if isWidthLonger {
                // Width is the long side
                let ratio = original.height / original.width
                let w = max(1, cappedTarget.rounded())
                let h = max(1, (cappedTarget * ratio).rounded())
                return CGSize(width: w, height: h)
            } else {
                // Height is the long side
                let ratio = original.width / original.height
                let h = max(1, cappedTarget.rounded())
                let w = max(1, (cappedTarget * ratio).rounded())
                return CGSize(width: w, height: h)
            }
        }
    }
}


