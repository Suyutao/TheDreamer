import SwiftData

enum ScheduleWorkspaceSidebarSelection: Hashable {
    case timetable(PersistentIdentifier)
    case courses
}

enum ScheduleWorkspaceCategory: String, CaseIterable, Hashable, Identifiable {
    case arrangements
    case periods
    case overrides

    var id: Self { self }

    var title: String {
        switch self {
        case .arrangements: "课程安排"
        case .periods: "节次"
        case .overrides: "日期调整"
        }
    }

    var systemImage: String {
        switch self {
        case .arrangements: "calendar.day.timeline.left"
        case .periods: "clock"
        case .overrides: "calendar.badge.clock"
        }
    }
}

enum ScheduleWorkspaceItem: Hashable {
    case timetable(PersistentIdentifier)
    case course(PersistentIdentifier)
    case period(PersistentIdentifier)
    case schedule(PersistentIdentifier)
    case scheduleOverride(PersistentIdentifier)
}
