import SwiftUI

@main
struct LaunchHubApp: App {
    @State private var midiService = MIDIService()
    @State private var storageService = ProjectStorageService()
    @State private var appSettings = AppSettings()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(midiService)
                .environment(storageService)
                .environment(appSettings)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                if appSettings.autoConnect {
                    midiService.startScanning()
                }
            case .background:
                if appSettings.restoreLiveModeOnExit,
                   let model = midiService.connectedDevice?.model {
                    let controller = LEDController(midiService: midiService)
                    controller.deviceModel = model
                    controller.exitProgrammerMode()
                }
            default:
                break
            }
        }
    }
}
