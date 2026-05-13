import SwiftUI

struct SingleLineOverlayBadge: View {
    let text: String
    var cornerRadius: CGFloat = 6
    var padding: CGFloat = 6

    var body: some View {
        Text(text)
            .font(Theme.Fonts.captionMono)
            .monospaced(true)
            .padding(padding)
            .background(OverlayBackground(cornerRadius: cornerRadius))
    }
}
