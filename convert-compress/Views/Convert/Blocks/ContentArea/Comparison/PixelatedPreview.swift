import SwiftUI

/// Shows a breathing pixelated preview of the source image while
/// the processed result is being rendered. Uses a Metal shader for
/// GPU-accelerated pixelation — no CPU-side image work at all.
struct PixelatedPreview: View {
    let sourceImage: NSImage
    let cropRegion: CGRect?
    let displaySize: CGSize
    let displayOffset: CGPoint
    let imageFrameSize: CGSize
    let sliderPosition: CGFloat
    @ObservedObject var zoomPanState: ZoomPanState

    private let maxPixelSize: CGFloat = 48
    private let minPixelSize: CGFloat = 4
    private let cycleDuration: TimeInterval = 5

    @State private var startDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let t = (1 - cos(elapsed * 2 * .pi / cycleDuration)) / 2
            let pixelSize = minPixelSize + (maxPixelSize - minPixelSize) * t

            GeometryReader { geo in
                imageContent
                    .distortionEffect(
                        ShaderLibrary.pixelate(
                            .float(Float(pixelSize)),
                            .float2(Float(displaySize.width / 2), Float(displaySize.height / 2))
                        ),
                        maxSampleOffset: CGSize(width: maxPixelSize, height: maxPixelSize)
                    )
                    .clipped()
                    .overlay {
                        if cropRegion != nil {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .strokeBorder(.secondary, lineWidth: 0.5)
                        }
                    }
                    .offset(x: displayOffset.x, y: displayOffset.y)
                    .scaleEffect(zoomPanState.scale, anchor: .center)
                    .offset(x: zoomPanState.offset.x, y: zoomPanState.offset.y)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .drawingGroup(opaque: false, colorMode: .nonLinear)
                    .mask(alignment: .trailing) {
                        Rectangle()
                            .frame(width: (1.0 - sliderPosition) * geo.size.width)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    }
            }
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let cropRegion {
            Image(nsImage: sourceImage)
                .resizable()
                .scaledToFit()
                .frame(width: imageFrameSize.width, height: imageFrameSize.height)
                .offset(
                    x: imageFrameSize.width * (0.5 - cropRegion.midX),
                    y: imageFrameSize.height * (0.5 - cropRegion.midY)
                )
                .frame(width: displaySize.width, height: displaySize.height)
        } else {
            Image(nsImage: sourceImage)
                .resizable()
                .scaledToFit()
                .frame(width: displaySize.width, height: displaySize.height)
        }
    }
}
