import SwiftUI
import SwiftData

struct TimetableWindowView: View {
    @Environment(\.modelContext) private var modelContext

    let timetableID: PersistentIdentifier?

    private var timetable: Timetable? {
        guard let timetableID else { return nil }
        return modelContext.model(for: timetableID) as? Timetable
    }

    var body: some View {
        Group {
            if let timetable, !timetable.isDeleted {
                ScheduleWorkspaceView(initialTimetableID: timetable.persistentModelID)
            } else {
                ContentUnavailableView {
                    Label("课程表不可用", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("这张课程表可能已经在其他窗口中删除。")
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #endif
    }
}
