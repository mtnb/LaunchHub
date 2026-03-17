import Foundation

/// Controls Launchpad LEDs via MIDI messages
@MainActor
final class LEDController {
    private let midiService: MIDIService

    var deviceModel: LaunchpadModel = .x

    init(midiService: MIDIService) {
        self.midiService = midiService
    }

    // MARK: - Single LED

    /// Set a single pad LED color using palette
    func setLED(note: UInt8, color: PadColor, mode: LEDMode) {
        switch color {
        case .palette(let velocity):
            // Use Note On with channel for mode
            midiService.sendNoteOn(channel: mode.midiChannel, note: note, velocity: velocity)
        case .rgb(let r, let g, let b):
            // Use SysEx for RGB
            let header = deviceModel.sysExHeader
            let bytes: [UInt8] = [0xF0] + header + [0x0B, note, r, g, b, 0xF7]
            midiService.sendSysEx(bytes)
        }
    }

    /// Set a CC button LED color
    func setCCButton(cc: UInt8, color: PadColor) {
        switch color {
        case .palette(let velocity):
            midiService.sendCC(channel: 0, cc: cc, value: velocity)
        case .rgb(let r, let g, let b):
            let header = deviceModel.sysExHeader
            let bytes: [UInt8] = [0xF0] + header + [0x0B, cc, r, g, b, 0xF7]
            midiService.sendSysEx(bytes)
        }
    }

    // MARK: - Batch LED

    /// Set multiple LEDs at once using SysEx batch palette message
    func setLEDBatch(_ pads: [(note: UInt8, velocity: UInt8)]) {
        guard !pads.isEmpty else { return }
        let header = deviceModel.sysExHeader
        var bytes: [UInt8] = [0xF0] + header + [0x0A]
        for pad in pads {
            bytes += [pad.note, pad.velocity]
        }
        bytes.append(0xF7)
        midiService.sendSysEx(bytes)
    }

    /// Set multiple LEDs with RGB using SysEx batch RGB message
    func setLEDBatchRGB(_ pads: [(note: UInt8, r: UInt8, g: UInt8, b: UInt8)]) {
        guard !pads.isEmpty else { return }
        let header = deviceModel.sysExHeader
        var bytes: [UInt8] = [0xF0] + header + [0x0B]
        for pad in pads {
            bytes += [pad.note, pad.r, pad.g, pad.b]
        }
        bytes.append(0xF7)
        midiService.sendSysEx(bytes)
    }

    // MARK: - Clear

    /// Turn off all LEDs
    func clearAll() {
        let header = deviceModel.sysExHeader
        let bytes: [UInt8] = [0xF0] + header + [0x0E, 0x00, 0xF7]
        midiService.sendSysEx(bytes)
    }

    // MARK: - Mode Control

    /// Enter Programmer Mode
    func enterProgrammerMode() {
        let bytes = deviceModel.programmerModeSysEx
        midiService.sendSysEx(bytes)
    }

    /// Exit Programmer Mode (return to Live Mode)
    func exitProgrammerMode() {
        let bytes = deviceModel.liveModeSysEx
        midiService.sendSysEx(bytes)
    }

    // MARK: - Frame

    /// Send a complete frame to the device
    func sendFrame(_ frame: Frame) {
        // Clear first
        clearAll()

        // Send palette pads in batch
        var palettePads: [(note: UInt8, velocity: UInt8)] = []
        var rgbPads: [(note: UInt8, r: UInt8, g: UInt8, b: UInt8)] = []

        for pad in frame.pads {
            switch pad.colorValue {
            case .palette(let vel):
                palettePads.append((pad.note, vel))
            case .rgb(let r, let g, let b):
                rgbPads.append((pad.note, r, g, b))
            }
        }

        if !palettePads.isEmpty {
            setLEDBatch(palettePads)
        }
        if !rgbPads.isEmpty {
            setLEDBatchRGB(rgbPads)
        }

        // Send CC buttons
        for button in frame.ccButtons {
            setCCButton(cc: button.cc, color: button.colorValue)
        }

        // Send scene (side) buttons
        for button in frame.sceneButtons {
            setLED(note: button.note, color: button.colorValue, mode: button.ledMode)
        }
    }
}
