import SwiftUI

struct AppCommands: Commands {
    @AppStorage(StorageKeys.Preferences.revealExportInFinder) private var revealExportInFinder = true
    @AppStorage(StorageKeys.Preferences.keepFolderStructure) private var keepFolderStructure = false
    
    var body: some Commands {
        CommandGroup(after: .appSettings) {
            Toggle(isOn: $revealExportInFinder) {
                Label("Select Images after Export", systemImage: "folder")
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Toggle(isOn: $keepFolderStructure) {
                Label("Keep Folder Structure", systemImage: "folder.badge.gearshape")
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
        }
    }
}

