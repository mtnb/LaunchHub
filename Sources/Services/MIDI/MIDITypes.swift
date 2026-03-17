import Foundation

struct DiscoveredDevice: Sendable, Identifiable, Equatable {
    let id: String
    let name: String
    let model: LaunchpadModel?
    let connectionType: ConnectionType
}

struct ConnectedDevice: Sendable, Identifiable, Equatable {
    let id: String
    let name: String
    let model: LaunchpadModel
    let connectionType: ConnectionType
    let firmwareVersion: String?
}

enum ConnectionType: String, Sendable, CaseIterable {
    case usb = "USB-MIDI"
    case ble = "BLE-MIDI"
    case wifi = "Wi-Fi MIDI"
}

enum ConnectionState: String, Sendable {
    case disconnected
    case scanning
    case connecting
    case connected
    case error
}
