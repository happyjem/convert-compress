import Foundation

extension ImageToolsViewModel {
    func updateRestrictions(for format: ImageFormat?) {
        let caps = ImageIOCapabilities.shared
        if let format, let sizes = caps.sizeRestrictions(forUTType: format.utType) {
            allowedSquareSizes = sizes.sorted()
        } else {
            allowedSquareSizes = nil
        }
    }

    func onSelectedFormatChanged(_ format: ImageFormat?) {
        updateRestrictions(for: format)
        guard allowedSquareSizes != nil else { return }
        
        // Choose a reference size from first asset (prefer cached value)
        guard let firstImage = images.first else { return }
        let sourceSize = firstImage.originalPixelSize ?? .zero
        
        let caps = ImageIOCapabilities.shared
        if let format, !caps.isValidPixelSize(sourceSize, for: format.utType) {
            // Force resize mode and prefill suggestion
            resizeMode = .resize
            if let side = caps.suggestedSquareSide(for: format.utType, source: sourceSize) {
                resizeWidth = String(side)
                resizeHeight = String(side)
            }
        }
    }
}
