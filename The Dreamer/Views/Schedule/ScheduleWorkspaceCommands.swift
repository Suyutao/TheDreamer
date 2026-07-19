import SwiftUI

private struct ScheduleNewActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

private struct ScheduleSaveActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

private struct ScheduleDeleteActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var scheduleNewAction: (() -> Void)? {
        get { self[ScheduleNewActionKey.self] }
        set { self[ScheduleNewActionKey.self] = newValue }
    }

    var scheduleSaveAction: (() -> Void)? {
        get { self[ScheduleSaveActionKey.self] }
        set { self[ScheduleSaveActionKey.self] = newValue }
    }

    var scheduleDeleteAction: (() -> Void)? {
        get { self[ScheduleDeleteActionKey.self] }
        set { self[ScheduleDeleteActionKey.self] = newValue }
    }
}

struct ScheduleWorkspaceCommands: Commands {
    @FocusedValue(\.scheduleNewAction) private var newAction
    @FocusedValue(\.scheduleSaveAction) private var saveAction
    @FocusedValue(\.scheduleDeleteAction) private var deleteAction

    var body: some Commands {
        CommandMenu("课程表") {
            Button("新建", systemImage: "plus") {
                newAction?()
            }
            .keyboardShortcut("n", modifiers: .command)
            .disabled(newAction == nil)

            Button("保存", systemImage: "square.and.arrow.down") {
                saveAction?()
            }
            .keyboardShortcut("s", modifiers: .command)
            .disabled(saveAction == nil)

            Divider()

            Button("删除", systemImage: "trash", role: .destructive) {
                deleteAction?()
            }
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(deleteAction == nil)
        }
    }
}
