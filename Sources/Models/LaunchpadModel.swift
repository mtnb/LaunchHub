import Foundation

enum LaunchpadModel: String, Codable, Sendable, CaseIterable {
    case mk2 = "launchpad_mk2"
    case pro = "launchpad_pro"
    case proMk3 = "launchpad_pro_mk3"
    case miniMk3 = "launchpad_mini_mk3"
    case x = "launchpad_x"

    var displayName: String {
        switch self {
        case .mk2: "Launchpad MK2"
        case .pro: "Launchpad Pro"
        case .proMk3: "Launchpad Pro MK3"
        case .miniMk3: "Launchpad Mini MK3"
        case .x: "Launchpad X"
        }
    }

    /// SysEx header bytes (without F0 prefix and F7 suffix)
    var sysExHeader: [UInt8] {
        switch self {
        case .mk2: [0x00, 0x20, 0x29, 0x02, 0x18]
        case .pro: [0x00, 0x20, 0x29, 0x02, 0x10]
        case .proMk3: [0x00, 0x20, 0x29, 0x02, 0x0E]
        case .miniMk3: [0x00, 0x20, 0x29, 0x02, 0x0D]
        case .x: [0x00, 0x20, 0x29, 0x02, 0x0C]
        }
    }

    /// SysEx message to enter Programmer Mode
    var programmerModeSysEx: [UInt8] {
        switch self {
        case .mk2:
            // Layout 0x01 (User 1) — MK2 uses layout change
            [0xF0] + sysExHeader + [0x22, 0x00, 0xF7]
        case .pro:
            // Pro uses standalone mode
            [0xF0] + sysExHeader + [0x21, 0x01, 0xF7]
        case .proMk3, .miniMk3, .x:
            // mode 1 = Programmer Mode
            [0xF0] + sysExHeader + [0x0E, 0x01, 0xF7]
        }
    }

    /// SysEx message to exit Programmer Mode (return to Live/Session Mode)
    var liveModeSysEx: [UInt8] {
        switch self {
        case .mk2:
            [0xF0] + sysExHeader + [0x22, 0x00, 0xF7]
        case .pro:
            [0xF0] + sysExHeader + [0x21, 0x00, 0xF7]
        case .proMk3, .miniMk3, .x:
            [0xF0] + sysExHeader + [0x0E, 0x00, 0xF7]
        }
    }

    /// Device Inquiry identification byte
    var deviceInquiryByte: UInt8 {
        switch self {
        case .mk2: 0x69
        case .pro: 0x51
        case .proMk3: 0x0C
        case .miniMk3: 0x0D
        case .x: 0x13
        }
    }

    static func fromInquiryByte(_ byte: UInt8) -> LaunchpadModel? {
        allCases.first { $0.deviceInquiryByte == byte }
    }
}
