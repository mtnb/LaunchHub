import Foundation
import Observation

@Observable
@MainActor
final class EditHistory<State: Equatable & Sendable>: @unchecked Sendable {
    private(set) var undoStack: [State] = []
    private(set) var redoStack: [State] = []

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func record(_ state: State) {
        undoStack.append(state)
        redoStack.removeAll()
    }

    func undo(current: State) -> State? {
        guard let previous = undoStack.popLast() else { return nil }
        redoStack.append(current)
        return previous
    }

    func redo(current: State) -> State? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(current)
        return next
    }

    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
