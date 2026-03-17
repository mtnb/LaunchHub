import Foundation
import Observation

@Observable
@MainActor
final class AppSettings {
    // MARK: - Device
    var autoConnect: Bool {
        didSet { UserDefaults.standard.set(autoConnect, forKey: Keys.autoConnect) }
    }
    var restoreLiveModeOnExit: Bool {
        didSet { UserDefaults.standard.set(restoreLiveModeOnExit, forKey: Keys.restoreLiveModeOnExit) }
    }

    // MARK: - MIDI
    var defaultBPM: Int {
        didSet { UserDefaults.standard.set(defaultBPM, forKey: Keys.defaultBPM) }
    }
    var sendMIDIClock: Bool {
        didSet { UserDefaults.standard.set(sendMIDIClock, forKey: Keys.sendMIDIClock) }
    }
    var defaultLEDMode: LEDMode {
        didSet { UserDefaults.standard.set(defaultLEDMode.rawValue, forKey: Keys.defaultLEDMode) }
    }
    var sysExPacketSize: Int {
        didSet { UserDefaults.standard.set(sysExPacketSize, forKey: Keys.sysExPacketSize) }
    }

    // MARK: - Display
    var showNoteNumbers: Bool {
        didSet { UserDefaults.standard.set(showNoteNumbers, forKey: Keys.showNoteNumbers) }
    }
    var hapticFeedback: Bool {
        didSet { UserDefaults.standard.set(hapticFeedback, forKey: Keys.hapticFeedback) }
    }
    var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme) }
    }

    init() {
        let defaults = UserDefaults.standard
        autoConnect = defaults.object(forKey: Keys.autoConnect) as? Bool ?? true
        restoreLiveModeOnExit = defaults.object(forKey: Keys.restoreLiveModeOnExit) as? Bool ?? true
        defaultBPM = defaults.object(forKey: Keys.defaultBPM) as? Int ?? 120
        sendMIDIClock = defaults.object(forKey: Keys.sendMIDIClock) as? Bool ?? true
        defaultLEDMode = LEDMode(rawValue: defaults.string(forKey: Keys.defaultLEDMode) ?? "") ?? .static
        sysExPacketSize = defaults.object(forKey: Keys.sysExPacketSize) as? Int ?? 256
        showNoteNumbers = defaults.object(forKey: Keys.showNoteNumbers) as? Bool ?? false
        hapticFeedback = defaults.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        theme = AppTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .dark
    }

    private enum Keys {
        static let autoConnect = "autoConnect"
        static let restoreLiveModeOnExit = "restoreLiveModeOnExit"
        static let defaultBPM = "defaultBPM"
        static let sendMIDIClock = "sendMIDIClock"
        static let defaultLEDMode = "defaultLEDMode"
        static let sysExPacketSize = "sysExPacketSize"
        static let showNoteNumbers = "showNoteNumbers"
        static let hapticFeedback = "hapticFeedback"
        static let theme = "theme"
    }
}

enum AppTheme: String, CaseIterable, Sendable {
    case dark
    case light
    case system

    var displayName: String {
        switch self {
        case .dark: "Dark"
        case .light: "Light"
        case .system: "System"
        }
    }
}
