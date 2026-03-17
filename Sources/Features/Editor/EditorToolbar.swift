import SwiftUI

struct EditorToolbar: View {
    @Bindable var viewModel: EditorViewModel
    var onColorPickerTap: () -> Void = {}

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Row 1: Undo/Redo + Color + LED Mode
            HStack(spacing: Spacing.sm) {
                Button(action: viewModel.undo) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!viewModel.editHistory.canUndo)

                Button(action: viewModel.redo) {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!viewModel.editHistory.canRedo)

                Divider().frame(height: 24)

                // Selected color preview
                Button(action: onColorPickerTap) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel.selectedColor.displayColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.gridBorder, lineWidth: 1)
                        )
                }

                Divider().frame(height: 24)

                // LED Mode picker
                Picker("LED Mode", selection: $viewModel.selectedLEDMode) {
                    ForEach(LEDMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 240)

                Spacer()
            }

            // Row 2: Selection tools + BPM
            HStack(spacing: Spacing.sm) {
                Button {
                    viewModel.selectedPads.removeAll()
                } label: {
                    Label("Clear Selection", systemImage: "xmark.square")
                        .labelStyle(.iconOnly)
                }

                Divider().frame(height: 24)

                // BPM
                HStack(spacing: Spacing.xs) {
                    Text("BPM")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    TextField("BPM", value: Binding(
                        get: { viewModel.project.metadata.bpm },
                        set: { viewModel.project.metadata.bpm = max(20, min(300, $0)) }
                    ), format: .number)
                    .font(.numericDisplay)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                }

                Spacer()
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.surface1)
    }
}
