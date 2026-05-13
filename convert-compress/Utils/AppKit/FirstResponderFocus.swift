import AppKit

enum FirstResponderFocus {
    static var isTextInputFocused: Bool {
        guard let firstResponder = NSApp.keyWindow?.firstResponder else {
            return false
        }
        return firstResponder is NSText || firstResponder is NSTextField
    }
}

