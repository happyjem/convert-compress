import SwiftUI

struct TwoLineOverlayBadge: View {
    let topText: String
    let bottomText: String
    var alignment: HorizontalAlignment = .leading
    var cornerRadius: CGFloat = 6
    var padding: CGFloat = 6

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(topText).foregroundStyle(.secondary)
            Text(bottomText).foregroundStyle(.primary)
        }
        .font(Theme.Fonts.captionMono)
        .monospaced(true)
        .padding(padding)
        .background(OverlayBackground(cornerRadius: cornerRadius))
    }
}
