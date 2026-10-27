import SwiftUI

@main
struct ARCraftLabApp: App {
    var body: some Scene {
        WindowGroup {
            LabView(initialScreen: LabScreen.fromLaunchArguments())
                .tint(LabPalette.blue)
        }
        #if os(visionOS)
        ImmersiveSpace(id: LiveSpaceView.spaceID) {
            LiveSpaceView()
        }
        #endif
    }
}

/// The colors of the lab, taken from the repository's blue palette.
enum LabPalette {
    static let blue = Color(red: 0x00 / 255, green: 0x71 / 255, blue: 0xE3 / 255)
    static let deep = Color(red: 0x00 / 255, green: 0x58 / 255, blue: 0xD4 / 255)
    static let navy = Color(red: 0x00 / 255, green: 0x3A / 255, blue: 0x85 / 255)
    static let sky = Color(red: 0x5A / 255, green: 0xC8 / 255, blue: 0xFA / 255)
    static let muted = Color(red: 0x5A / 255, green: 0x6B / 255, blue: 0x80 / 255)
}
