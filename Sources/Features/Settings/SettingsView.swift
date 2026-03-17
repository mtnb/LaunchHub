import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @State var viewModel: SettingsViewModel
    var onShowDeviceConnection: () -> Void

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            List {
                // Device section
                Section("Device") {
                    Button("Device Management") {
                        onShowDeviceConnection()
                    }
                    Toggle("Auto-connect", isOn: $settings.autoConnect)
                    Toggle("Restore Live Mode on Exit", isOn: $settings.restoreLiveModeOnExit)
                }
                .listRowBackground(Color.surface1)

                // MIDI section
                Section("MIDI") {
                    HStack {
                        Text("Default BPM")
                        Spacer()
                        TextField("BPM", value: $settings.defaultBPM, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Send MIDI Clock", isOn: $settings.sendMIDIClock)
                    Picker("Default LED Mode", selection: $settings.defaultLEDMode) {
                        ForEach(LEDMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    Picker("SysEx Packet Size", selection: $settings.sysExPacketSize) {
                        Text("128 bytes").tag(128)
                        Text("256 bytes").tag(256)
                    }
                }
                .listRowBackground(Color.surface1)

                // Display section
                Section("Display") {
                    Picker("Theme", selection: $settings.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    Toggle("Show Note Numbers on Grid", isOn: $settings.showNoteNumbers)
                    Toggle("Haptic Feedback", isOn: $settings.hapticFeedback)
                }
                .listRowBackground(Color.surface1)

                // Data section
                Section("Data") {
                    Button("Delete All Data", role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    }
                }
                .listRowBackground(Color.surface1)

                // Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .listRowBackground(Color.surface1)
            }
            .scrollContentBackground(.hidden)
            .background(Color.surface0)
            .navigationTitle("Settings")
            .alert("Delete All Data", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all projects. This action cannot be undone.")
            }
        }
    }
}
