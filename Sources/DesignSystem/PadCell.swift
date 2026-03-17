import SwiftUI

struct PadCell: View {
    let color: Color
    let ledMode: LEDMode
    let isSelected: Bool
    var noteNumber: UInt8?
    var showNoteNumber: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.accentPrimary : Color.gridBorder,
                            lineWidth: isSelected ? 2 : 1
                        )
                )

            if showNoteNumber, let note = noteNumber {
                Text("\(note)")
                    .font(.padLabel)
                    .foregroundStyle(Color.textSecondary)
            }

            if ledMode == .pulsing {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.5))
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: ledMode
                    )
            }
        }
        .opacity(ledMode == .flashing ? 0.7 : 1.0)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HStack {
        PadCell(color: .red, ledMode: .static, isSelected: false)
        PadCell(color: .blue, ledMode: .pulsing, isSelected: true, noteNumber: 45, showNoteNumber: true)
        PadCell(color: .gridOff, ledMode: .static, isSelected: false)
    }
    .padding()
    .background(Color.surface0)
}
