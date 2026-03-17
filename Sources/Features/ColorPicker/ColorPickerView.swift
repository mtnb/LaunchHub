import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: PadColor
    @Binding var selectedLEDMode: LEDMode
    @State private var viewModel = ColorPickerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Preview
                    colorPreview

                    // Mode selector
                    Picker("Mode", selection: $viewModel.mode) {
                        ForEach(ColorPickerViewModel.Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Spacing.md)

                    // Palette or RGB
                    switch viewModel.mode {
                    case .palette:
                        paletteGrid
                    case .rgb:
                        rgbSliders
                    }

                    // LED Mode
                    ledModeSection

                    // Recent colors
                    if !viewModel.recentColors.isEmpty {
                        recentColorsSection
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .background(Color.surface0)
            .navigationTitle("Color Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Preview

    private var colorPreview: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 12)
                .fill(selectedColor.displayColor)
                .frame(width: 64, height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gridBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                switch selectedColor {
                case .palette(let value):
                    Text("Palette: \(value)")
                        .font(.bodyText)
                        .foregroundStyle(Color.textPrimary)
                case .rgb(let r, let g, let b):
                    Text("RGB: \(r), \(g), \(b)")
                        .font(.bodyText)
                        .foregroundStyle(Color.textPrimary)
                }
                Text(selectedLEDMode.displayName)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Palette Grid (16x8)

    private var paletteGrid: some View {
        VStack(spacing: 2) {
            ForEach(0..<16, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { col in
                        let index = UInt8(row * 8 + col)
                        let color = LaunchpadPalette.color(for: index)

                        Rectangle()
                            .fill(index == 0 ? Color.gridOff : color)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                if case .palette(let v) = selectedColor, v == index {
                                    RoundedRectangle(cornerRadius: 2)
                                        .strokeBorder(Color.white, lineWidth: 2)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .onTapGesture {
                                selectedColor = .palette(index)
                                viewModel.addToRecent(.palette(index))
                            }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - RGB Sliders

    private var rgbSliders: some View {
        VStack(spacing: Spacing.md) {
            rgbSlider(label: "R", value: $viewModel.rgbRed, color: .red)
            rgbSlider(label: "G", value: $viewModel.rgbGreen, color: .green)
            rgbSlider(label: "B", value: $viewModel.rgbBlue, color: .blue)

            ActionButton(title: "Apply RGB", style: .primary) {
                let color = viewModel.currentRGBColor
                selectedColor = color
                viewModel.addToRecent(color)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func rgbSlider(label: String, value: Binding<Double>, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(label)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 20)

            Slider(value: value, in: 0...63, step: 1)
                .tint(color)

            Text("\(Int(value.wrappedValue))")
                .font(.caption.monospacedDigit())
                .foregroundStyle(Color.textSecondary)
                .frame(width: 30, alignment: .trailing)
        }
    }

    // MARK: - LED Mode

    private var ledModeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("LED Mode")
                .font(.sectionHeading)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.md)

            Picker("LED Mode", selection: $selectedLEDMode) {
                ForEach(LEDMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Recent Colors

    private var recentColorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent")
                .font(.sectionHeading)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.md)

            HStack(spacing: Spacing.sm) {
                ForEach(Array(viewModel.recentColors.enumerated()), id: \.offset) { _, color in
                    Rectangle()
                        .fill(color.displayColor)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}
