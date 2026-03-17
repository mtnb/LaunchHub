import SwiftUI
import Observation

@Observable
@MainActor
final class EditorViewModel {
    var project: Project
    var selectedFrameIndex: Int = 0
    var selectedColor: PadColor = .palette(5)
    var selectedLEDMode: LEDMode = .static
    var selectedPads: Set<UInt8> = []
    var isPlaying: Bool = false

    private(set) var editHistory = EditHistory<[Frame]>()

    private let storageService: ProjectStorageService
    private let ledController: LEDController?

    init(project: Project, storageService: ProjectStorageService, ledController: LEDController? = nil) {
        self.project = project
        self.storageService = storageService
        self.ledController = ledController
    }

    var currentFrame: Frame {
        get { project.frames[selectedFrameIndex] }
        set { project.frames[selectedFrameIndex] = newValue }
    }

    var frameCount: Int { project.frames.count }

    // MARK: - Pad Operations

    func tapPad(note: UInt8) {
        recordForUndo()

        if let existingIndex = currentFrame.pads.firstIndex(where: { $0.note == note }) {
            currentFrame.pads[existingIndex].colorValue = selectedColor
            currentFrame.pads[existingIndex].ledMode = selectedLEDMode
        } else {
            let pad = PadData(note: note, colorValue: selectedColor, ledMode: selectedLEDMode)
            currentFrame.pads.append(pad)
        }

        selectedPads.insert(note)

        // Send to device
        ledController?.setLED(note: note, color: selectedColor, mode: selectedLEDMode)
    }

    func padData(for note: UInt8) -> PadData? {
        currentFrame.pads.first { $0.note == note }
    }

    func ccButtonData(for cc: UInt8) -> CCButtonData? {
        currentFrame.ccButtons.first { $0.cc == cc }
    }

    func tapCCButton(cc: UInt8) {
        recordForUndo()

        if let existingIndex = currentFrame.ccButtons.firstIndex(where: { $0.cc == cc }) {
            currentFrame.ccButtons[existingIndex].colorValue = selectedColor
        } else {
            let button = CCButtonData(cc: cc, colorValue: selectedColor)
            currentFrame.ccButtons.append(button)
        }

        ledController?.setCCButton(cc: cc, color: selectedColor)
    }

    func tapSceneButton(note: UInt8) {
        recordForUndo()

        if let existingIndex = currentFrame.sceneButtons.firstIndex(where: { $0.note == note }) {
            currentFrame.sceneButtons[existingIndex].colorValue = selectedColor
            currentFrame.sceneButtons[existingIndex].ledMode = selectedLEDMode
        } else {
            let pad = PadData(note: note, colorValue: selectedColor, ledMode: selectedLEDMode)
            currentFrame.sceneButtons.append(pad)
        }

        ledController?.setLED(note: note, color: selectedColor, mode: selectedLEDMode)
    }

    // MARK: - Frame Operations

    func addFrame() {
        recordForUndo()
        let newFrame = Frame.blank(index: project.frames.count, durationMs: currentFrame.durationMs)
        project.frames.append(newFrame)
        selectedFrameIndex = project.frames.count - 1
    }

    func deleteFrame() {
        guard project.frames.count > 1 else { return }
        recordForUndo()
        project.frames.remove(at: selectedFrameIndex)
        reindexFrames()
        if selectedFrameIndex >= project.frames.count {
            selectedFrameIndex = project.frames.count - 1
        }
        sendCurrentFrameToDevice()
    }

    func duplicateFrame() {
        recordForUndo()
        var copy = currentFrame
        copy.index = project.frames.count
        project.frames.insert(copy, at: selectedFrameIndex + 1)
        reindexFrames()
        selectedFrameIndex += 1
    }

    func selectFrame(at index: Int) {
        guard index >= 0, index < project.frames.count else { return }
        selectedFrameIndex = index
        sendCurrentFrameToDevice()
    }

    // MARK: - Undo/Redo

    func undo() {
        if let previous = editHistory.undo(current: project.frames) {
            project.frames = previous
            if selectedFrameIndex >= project.frames.count {
                selectedFrameIndex = project.frames.count - 1
            }
            sendCurrentFrameToDevice()
        }
    }

    func redo() {
        if let next = editHistory.redo(current: project.frames) {
            project.frames = next
            sendCurrentFrameToDevice()
        }
    }

    private func recordForUndo() {
        editHistory.record(project.frames)
    }

    // MARK: - Save

    func save() {
        project.metadata.modified = Date()
        try? storageService.save(project)
    }

    // MARK: - Playback

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startPlayback()
        }
    }

    private func startPlayback() {
        Task { [weak self] in
            guard let self else { return }
            for i in 0..<project.frames.count {
                guard isPlaying else { break }
                selectFrame(at: i)
                try? await Task.sleep(for: .milliseconds(project.frames[i].durationMs))
            }
            isPlaying = false
        }
    }

    // MARK: - Helpers

    private func reindexFrames() {
        for i in project.frames.indices {
            project.frames[i].index = i
        }
    }

    private func sendCurrentFrameToDevice() {
        ledController?.sendFrame(currentFrame)
    }
}
