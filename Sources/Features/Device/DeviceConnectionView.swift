import SwiftUI

struct DeviceConnectionView: View {
    @Bindable var viewModel: DeviceConnectionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Connected device
                if let device = viewModel.midiService.connectedDevice {
                    Section("Connected Device") {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            DeviceCard(
                                modelName: device.name,
                                connectionState: "Connected",
                                connectionType: device.connectionType.rawValue,
                                firmwareVersion: device.firmwareVersion,
                                isConnected: true
                            )

                            ActionButton(title: "Disconnect", style: .secondary) {
                                viewModel.disconnect()
                            }
                        }
                        .listRowBackground(Color.surface1)
                    }
                }

                // Available devices
                Section("Available Devices") {
                    if viewModel.midiService.discoveredDevices.isEmpty {
                        ContentUnavailableView {
                            Label("No Devices Found", systemImage: "pianokeys")
                        } description: {
                            Text("Connect a Launchpad via USB Camera Connection Kit or Bluetooth.")
                        }
                        .listRowBackground(Color.surface0)
                    } else {
                        ForEach(viewModel.midiService.discoveredDevices) { device in
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(device.name)
                                        .font(.bodyText)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(device.connectionType.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(Color.textSecondary)
                                }

                                Spacer()

                                Button("Connect") {
                                    viewModel.connect(to: device)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.accentPrimary)
                            }
                            .listRowBackground(Color.surface1)
                        }
                    }
                }

                // Scan status
                Section {
                    HStack {
                        if viewModel.isScanning {
                            ProgressView()
                                .padding(.trailing, Spacing.sm)
                            Text("Scanning...")
                                .foregroundStyle(Color.textSecondary)
                        } else {
                            Button("Scan for Devices") {
                                viewModel.startScanning()
                            }
                        }
                    }
                    .listRowBackground(Color.surface1)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.surface0)
            .navigationTitle("Device Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                viewModel.startScanning()
            }
        }
    }
}
