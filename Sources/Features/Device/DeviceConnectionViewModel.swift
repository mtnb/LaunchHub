import Foundation
import Observation

@Observable
@MainActor
final class DeviceConnectionViewModel {
    let midiService: MIDIService
    let ledController: LEDController

    var isScanning: Bool {
        midiService.connectionState == .scanning
    }

    var isConnected: Bool {
        midiService.connectionState == .connected
    }

    init(midiService: MIDIService, ledController: LEDController) {
        self.midiService = midiService
        self.ledController = ledController
    }

    func startScanning() {
        midiService.startScanning()
    }

    func connect(to device: DiscoveredDevice) {
        midiService.connect(to: device)
        if midiService.connectionState == .connected {
            if let model = midiService.connectedDevice?.model {
                ledController.deviceModel = model
            }
            ledController.enterProgrammerMode()
        }
    }

    func disconnect() {
        ledController.exitProgrammerMode()
        midiService.disconnect()
    }
}
