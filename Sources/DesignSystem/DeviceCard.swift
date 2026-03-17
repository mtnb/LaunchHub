import SwiftUI

struct DeviceCard: View {
    let modelName: String
    let connectionState: String
    let connectionType: String
    let firmwareVersion: String?
    let isConnected: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(isConnected ? Color.accentSuccess : Color.textTertiary)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(modelName)
                    .font(.sectionHeading)
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: Spacing.sm) {
                    Text(connectionType)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    if let fw = firmwareVersion {
                        Text("FW \(fw)")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }

                    Text(connectionState)
                        .font(.caption)
                        .foregroundStyle(isConnected ? Color.accentSuccess : Color.textSecondary)
                }
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        DeviceCard(
            modelName: "Launchpad X",
            connectionState: "Connected",
            connectionType: "USB-MIDI",
            firmwareVersion: "2.03",
            isConnected: true
        )
        DeviceCard(
            modelName: "Launchpad MK2",
            connectionState: "Available",
            connectionType: "USB-MIDI",
            firmwareVersion: nil,
            isConnected: false
        )
    }
    .padding()
    .background(Color.surface0)
}
