import SwiftUI

struct LaunchpadGridView: View {
    @Bindable var viewModel: EditorViewModel
    var showNoteNumbers: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Top CC buttons
            topButtons

            // Main grid + side buttons
            HStack(spacing: Spacing.xs) {
                // 8x8 Grid
                mainGrid

                // Side (scene) buttons
                sideButtons
            }
        }
        .padding(Spacing.sm)
    }

    // MARK: - Top CC Buttons

    private var topButtons: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(PadGrid.topButtonCCs, id: \.self) { cc in
                let buttonData = viewModel.ccButtonData(for: cc)
                let color = buttonData?.colorValue.displayColor ?? .gridOff

                PadCell(
                    color: color,
                    ledMode: .static,
                    isSelected: false,
                    noteNumber: cc,
                    showNoteNumber: showNoteNumbers
                )
                .onTapGesture {
                    viewModel.tapCCButton(cc: cc)
                }
            }
        }
    }

    // MARK: - Main 8x8 Grid

    private var mainGrid: some View {
        VStack(spacing: Spacing.xs) {
            // Rows from top (row 8) to bottom (row 1)
            ForEach((0..<8).reversed(), id: \.self) { rowIndex in
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<8, id: \.self) { colIndex in
                        let note = PadGrid.gridNotes[rowIndex][colIndex]
                        let padData = viewModel.padData(for: note)
                        let color = padData?.colorValue.displayColor ?? .gridOff
                        let mode = padData?.ledMode ?? .static
                        let isSelected = viewModel.selectedPads.contains(note)

                        PadCell(
                            color: color,
                            ledMode: mode,
                            isSelected: isSelected,
                            noteNumber: note,
                            showNoteNumber: showNoteNumbers
                        )
                        .onTapGesture {
                            viewModel.tapPad(note: note)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    viewModel.tapPad(note: note)
                                }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Side (Scene) Buttons

    private var sideButtons: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(PadGrid.sideButtonNotes.reversed(), id: \.self) { note in
                let padData = viewModel.currentFrame.sceneButtons.first { $0.note == note }
                let color = padData?.colorValue.displayColor ?? .gridOff
                let mode = padData?.ledMode ?? .static

                PadCell(
                    color: color,
                    ledMode: mode,
                    isSelected: false,
                    noteNumber: note,
                    showNoteNumber: showNoteNumbers
                )
                .onTapGesture {
                    viewModel.tapSceneButton(note: note)
                }
            }
        }
    }
}
