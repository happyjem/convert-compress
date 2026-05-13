import SwiftUI
import AppKit

/// A view modifier that handles trackpad pan and mouse wheel zoom for comparison view
struct ComparisonScrollHandler: ViewModifier {
    let zoomPanState: ZoomPanState
    let isEnabled: Bool
    
    @State private var scrollMonitor: LocalEventMonitor?
    
    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                isHovering && isEnabled ? installScrollMonitor() : removeScrollMonitor()
            }
            .onDisappear {
                removeScrollMonitor()
            }
    }
    
    private func installScrollMonitor() {
        removeScrollMonitor()
        scrollMonitor = LocalEventMonitor(mask: .scrollWheel) { [zoomPanState] event in
            // Trackpad has phase, mouse wheel doesn't
            let isTrackpad = event.phase != .init(rawValue: 0) || event.momentumPhase != .init(rawValue: 0)
            
            if isTrackpad {
                // Trackpad two-finger scroll - use for panning
                if event.phase == .began || event.phase == .changed || event.momentumPhase == .changed {
                    zoomPanState.pan(by: CGSize(width: event.scrollingDeltaX, height: event.scrollingDeltaY))
                    return nil
                }
            } else {
                // Mouse wheel with Option key - zoom from center
                if event.modifierFlags.contains(.option) && abs(event.scrollingDeltaY) > 0.1 {
                    let zoomFactor = 1.0 + (event.scrollingDeltaY * 0.01)
                    let center = CGPoint(
                        x: zoomPanState.containerSize.width / 2,
                        y: zoomPanState.containerSize.height / 2
                    )
                    zoomPanState.zoom(by: zoomFactor, at: center)
                    return nil
                }
            }
            
            return event
        }
        scrollMonitor?.start()
    }
    
    private func removeScrollMonitor() {
        scrollMonitor?.stop()
        scrollMonitor = nil
    }
}

extension View {
    /// Adds trackpad pan and mouse wheel zoom support for comparison view
    func comparisonScrollHandler(
        zoomPanState: ZoomPanState,
        isEnabled: Bool = true
    ) -> some View {
        modifier(ComparisonScrollHandler(
            zoomPanState: zoomPanState,
            isEnabled: isEnabled
        ))
    }
}

