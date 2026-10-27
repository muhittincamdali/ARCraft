import SwiftUI

/// The lab's screens. Each one runs ARCraft on recorded or synthetic data, so it works in the
/// simulator, on the Mac and in previews.
enum LabScreen: String, CaseIterable, Identifiable {
    case gestures
    case smoothing
    case placement
    case persistence

    var id: Self { self }

    var title: String {
        switch self {
        case .gestures: "Hand gestures"
        case .smoothing: "Smoothing"
        case .placement: "Placement"
        case .persistence: "Persistence"
        }
    }

    var symbol: String {
        switch self {
        case .gestures: "hand.pinch"
        case .smoothing: "waveform.path"
        case .placement: "square.grid.3x3.middle.filled"
        case .persistence: "externaldrive"
        }
    }

    /// `-screen <name>` opens a screen directly; the screenshot script uses it.
    static func fromLaunchArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> LabScreen? {
        guard let flag = arguments.firstIndex(of: "-screen"), arguments.indices.contains(flag + 1) else { return nil }
        return LabScreen(rawValue: arguments[flag + 1])
    }
}

struct LabView: View {
    @State private var path: [LabScreen]

    init(initialScreen: LabScreen? = nil) {
        _path = State(initialValue: initialScreen.map { [$0] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ForEach(LabScreen.allCases) { screen in
                        NavigationLink(value: screen) {
                            Label(screen.title, systemImage: screen.symbol)
                        }
                    }
                } footer: {
                    Text("Every screen runs the ARCraft package on synthetic or recorded data, so it works without a headset.")
                }
                #if os(visionOS)
                Section("On Apple Vision Pro") {
                    OpenLiveSpaceButton()
                }
                #endif
            }
            .navigationTitle("ARCraft Lab")
            .navigationDestination(for: LabScreen.self) { screen in
                destination(for: screen)
                    .navigationTitle(screen.title)
            }
        }
    }

    @ViewBuilder
    private func destination(for screen: LabScreen) -> some View {
        switch screen {
        case .gestures: GestureLabView()
        case .smoothing: SmoothingLabView()
        case .placement: PlacementLabView()
        case .persistence: PersistenceLabView()
        }
    }
}

#if os(visionOS)
private struct OpenLiveSpaceButton: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isOpen = false

    var body: some View {
        Button(isOpen ? "Close live space" : "Open live space: pinch to place cubes") {
            Task {
                if isOpen {
                    await dismissImmersiveSpace()
                    isOpen = false
                } else if case .opened = await openImmersiveSpace(id: LiveSpaceView.spaceID) {
                    isOpen = true
                }
            }
        }
    }
}
#endif

#Preview {
    LabView()
}
