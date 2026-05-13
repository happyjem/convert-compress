import AppKit
import SwiftUI

struct ImageThumbnail: View {
    let thumbnail: NSImage

    var body: some View {
        Image(nsImage: thumbnail)
            .resizable()
            .scaledToFit()
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
