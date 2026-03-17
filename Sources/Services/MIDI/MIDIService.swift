import Foundation
import CoreMIDI
import Observation

@Observable
@MainActor
final class MIDIService {
    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var discoveredDevices: [DiscoveredDevice] = []
    private(set) var connectedDevice: ConnectedDevice?

    private var midiClient: MIDIClientRef = 0
    private var outputPort: MIDIPortRef = 0
    private var inputPort: MIDIPortRef = 0
    private var connectedEndpoint: MIDIEndpointRef = 0

    init() {
        setupMIDI()
    }

    // MARK: - Setup

    private func setupMIDI() {
        let status = MIDIClientCreateWithBlock("LaunchHub" as CFString, &midiClient) { [weak self] notification in
            Task { @MainActor in
                self?.handleMIDINotification(notification)
            }
        }
        guard status == noErr else { return }

        MIDIOutputPortCreate(midiClient, "LaunchHub Output" as CFString, &outputPort)
        MIDIInputPortCreateWithProtocol(
            midiClient,
            "LaunchHub Input" as CFString,
            ._1_0,
            &inputPort
        ) { [weak self] eventList, _ in
            Task { @MainActor in
                self?.handleMIDIInput(eventList)
            }
        }
    }

    // MARK: - Scanning

    func startScanning() {
        connectionState = .scanning
        discoveredDevices.removeAll()

        let sourceCount = MIDIGetNumberOfSources()
        let destCount = MIDIGetNumberOfDestinations()

        for i in 0..<destCount {
            let endpoint = MIDIGetDestination(i)
            if let device = deviceFromEndpoint(endpoint) {
                if !discoveredDevices.contains(where: { $0.id == device.id }) {
                    discoveredDevices.append(device)
                }
            }
        }

        for i in 0..<sourceCount {
            let endpoint = MIDIGetSource(i)
            if let device = deviceFromEndpoint(endpoint) {
                if !discoveredDevices.contains(where: { $0.id == device.id }) {
                    discoveredDevices.append(device)
                }
            }
        }

        if discoveredDevices.isEmpty {
            connectionState = .disconnected
        }
    }

    // MARK: - Connection

    func connect(to device: DiscoveredDevice) {
        connectionState = .connecting

        let destCount = MIDIGetNumberOfDestinations()
        for i in 0..<destCount {
            let endpoint = MIDIGetDestination(i)
            let name = endpointName(endpoint)
            if name == device.name {
                connectedEndpoint = endpoint

                // Connect input
                let sourceCount = MIDIGetNumberOfSources()
                for j in 0..<sourceCount {
                    let source = MIDIGetSource(j)
                    if endpointName(source) == device.name {
                        MIDIPortConnectSource(inputPort, source, nil)
                        break
                    }
                }

                connectedDevice = ConnectedDevice(
                    id: device.id,
                    name: device.name,
                    model: device.model ?? .x,
                    connectionType: device.connectionType,
                    firmwareVersion: nil
                )
                connectionState = .connected

                // Send Device Inquiry
                sendDeviceInquiry()
                return
            }
        }
        connectionState = .error
    }

    func disconnect() {
        if connectedEndpoint != 0 {
            let sourceCount = MIDIGetNumberOfSources()
            for i in 0..<sourceCount {
                let source = MIDIGetSource(i)
                MIDIPortDisconnectSource(inputPort, source)
            }
        }
        connectedEndpoint = 0
        connectedDevice = nil
        connectionState = .disconnected
    }

    // MARK: - MIDI Send

    func sendSysEx(_ bytes: [UInt8]) {
        guard connectedEndpoint != 0 else { return }
        let count = bytes.count
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        buf.initialize(from: bytes, count: count)
        var request = MIDISysexSendRequest(
            destination: connectedEndpoint,
            data: buf,
            bytesToSend: UInt32(count),
            complete: false,
            reserved: (0, 0, 0),
            completionProc: { req in
                req.pointee.data.deallocate()
            },
            completionRefCon: nil
        )
        MIDISendSysex(&request)
    }

    func sendNoteOn(channel: UInt8, note: UInt8, velocity: UInt8) {
        guard connectedEndpoint != 0 else { return }
        let status: UInt8 = 0x90 | (channel & 0x0F)
        sendShortMessage([status, note, velocity])
    }

    func sendNoteOff(channel: UInt8, note: UInt8) {
        guard connectedEndpoint != 0 else { return }
        let status: UInt8 = 0x80 | (channel & 0x0F)
        sendShortMessage([status, note, 0])
    }

    func sendCC(channel: UInt8, cc: UInt8, value: UInt8) {
        guard connectedEndpoint != 0 else { return }
        let status: UInt8 = 0xB0 | (channel & 0x0F)
        sendShortMessage([status, cc, value])
    }

    // MARK: - Private Helpers

    private func sendShortMessage(_ bytes: [UInt8]) {
        var packetList = MIDIPacketList()
        let packet = MIDIPacketListInit(&packetList)
        MIDIPacketListAdd(&packetList, 1024, packet, 0, bytes.count, bytes)
        MIDISend(outputPort, connectedEndpoint, &packetList)
    }

    private func sendDeviceInquiry() {
        let inquiry: [UInt8] = [0xF0, 0x7E, 0x7F, 0x06, 0x01, 0xF7]
        sendSysEx(inquiry)
    }

    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgSetupChanged:
            startScanning()
        default:
            break
        }
    }

    private func handleMIDIInput(_ eventList: UnsafePointer<MIDIEventList>) {
        // Process incoming MIDI for device inquiry responses
    }

    private func deviceFromEndpoint(_ endpoint: MIDIEndpointRef) -> DiscoveredDevice? {
        let name = endpointName(endpoint)
        guard !name.isEmpty else { return nil }

        let model = LaunchpadModel.allCases.first { name.localizedCaseInsensitiveContains($0.displayName) }

        return DiscoveredDevice(
            id: "\(endpoint)",
            name: name,
            model: model,
            connectionType: .usb // Simplified; real detection would inspect endpoint properties
        )
    }

    private func endpointName(_ endpoint: MIDIEndpointRef) -> String {
        var name: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDisplayName, &name)
        return (name?.takeRetainedValue() as String?) ?? ""
    }
}
