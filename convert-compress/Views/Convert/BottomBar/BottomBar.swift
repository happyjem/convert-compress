import SwiftUI

struct BottomBar: View {
    @EnvironmentObject private var vm: ImageToolsViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                ClearControl()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SaveControl()
            
            HStack(spacing: 8) {
                ExportDirectoryControl(
                    directory: $vm.exportDirectory,
                    sourceDirectory: vm.sourceDirectory,
                    hasActiveImages: !vm.images.isEmpty
                )
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .animation(Theme.Animations.spring(), value: vm.isExportingToSource)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}
