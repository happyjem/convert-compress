import SwiftUI

struct ClearButton: View {
    @EnvironmentObject private var vm: ImageToolsViewModel

    private var clearOldMode: Bool { vm.hasExportedAndNewImages }

    var body: some View {
        PillButton(role: .destructive) {
            if clearOldMode {
                vm.clearExported()
            } else {
                vm.clearAll()
            }
        } label: {
            Text(clearOldMode
                 ? String(localized: "Clear old")
                 : String(localized: "Clear"))
            .contentTransition(.interpolate)
        }
        .help(clearOldMode
              ? String(localized: "Clear exported images")
              : String(localized: "Clear all images"))
        .disabled(vm.images.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: clearOldMode)
    }
}
