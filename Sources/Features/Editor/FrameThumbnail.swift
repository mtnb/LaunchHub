import SwiftUI

struct FrameThumbnail: View {
    let frame: Frame
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            // Mini 8x8 grid
            VStack(spacing: 1) {
                ForEach((0..<8).reversed(), id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<8, id: \.self) { col in
                            let note = PadGrid.gridNotes[row][col]
                            let padData = frame.pads.first { $0.note == note }
                            let color = padData?.colorValue.displayColor ?? .gridOff

                            Rectangle()
                                .fill(color)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .padding(2)
            .background(Color.surface0)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            Text("F\(frame.index + 1)")
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)

            Text("\(frame.durationMs)ms")
                .font(.caption2)
                .foregroundStyle(Color.textTertiary)
        }
        .padding(Spacing.xs)
        .background(isSelected ? Color.accentPrimary.opacity(0.2) : Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isSelected ? Color.accentPrimary : Color.clear,
                    lineWidth: 2
                )
        )
    }
}
