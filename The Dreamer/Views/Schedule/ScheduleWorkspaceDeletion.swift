import SwiftUI
import SwiftData

struct ScheduleWorkspaceDeletionRequest: Identifiable {
    enum Kind {
        case timetable(Timetable)
        case course(Course)
        case period(ClassPeriod)
        case schedule(CourseSchedule)
        case scheduleOverride(ScheduleOverride)
    }

    let id = UUID()
    let kind: Kind

    static func timetable(_ timetable: Timetable) -> Self {
        Self(kind: .timetable(timetable))
    }

    static func course(_ course: Course) -> Self {
        Self(kind: .course(course))
    }

    static func period(_ period: ClassPeriod) -> Self {
        Self(kind: .period(period))
    }

    static func schedule(_ schedule: CourseSchedule) -> Self {
        Self(kind: .schedule(schedule))
    }

    static func scheduleOverride(_ scheduleOverride: ScheduleOverride) -> Self {
        Self(kind: .scheduleOverride(scheduleOverride))
    }

    var title: String {
        switch kind {
        case .timetable: "删除课程表？"
        case .course: "删除课程？"
        case .period: "删除节次？"
        case .schedule: "删除课程安排？"
        case .scheduleOverride: "删除日期调整？"
        }
    }

    var deleteButtonTitle: String {
        switch kind {
        case .timetable: "删除课程表"
        case .course: "删除课程"
        case .period: "删除节次"
        case .schedule: "删除课程安排"
        case .scheduleOverride: "删除日期调整"
        }
    }

    var calendarRecords: [CalendarExportRecord] {
        switch kind {
        case .timetable(let timetable):
            timetable.schedules.flatMap(\.calendarExportRecords)
        case .period(let period):
            period.schedules.flatMap(\.calendarExportRecords)
        case .schedule(let schedule):
            schedule.calendarExportRecords
        case .course, .scheduleOverride:
            []
        }
    }

    var canRemoveCalendarEvents: Bool {
        switch kind {
        case .timetable, .period, .schedule: true
        case .course, .scheduleOverride: false
        }
    }

    func message(hasCalendarRecords: Bool) -> String {
        switch kind {
        case .timetable:
            hasCalendarRecords
                ? "节次、课程安排和日期调整会一起删除。你可以保留已导出的系统日历事件。"
                : "节次、课程安排和日期调整会一起删除，课程本身会保留。"
        case .course:
            "课程安排会保留，但不再关联这门课程。"
        case .period:
            hasCalendarRecords
                ? "使用该节次的课程安排也会删除。你可以保留已导出的系统日历事件。"
                : "使用该节次的课程安排也会删除。"
        case .schedule:
            hasCalendarRecords ? "你可以保留已导出的系统日历事件。" : ""
        case .scheduleOverride:
            "删除后，这一天会恢复课程表原有安排。"
        }
    }
}

struct ScheduleWorkspaceDeletionModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Query private var timetables: [Timetable]

    @Binding var request: ScheduleWorkspaceDeletionRequest?
    @Binding var sidebarSelection: ScheduleWorkspaceSidebarSelection?
    @Binding var itemSelection: ScheduleWorkspaceItem?

    @State private var saveError: String?

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                request?.title ?? "确认删除？",
                isPresented: Binding(
                    get: { request != nil },
                    set: { if !$0 { request = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let request {
                    deletionActions(for: request)
                }
            } message: {
                if let request {
                    Text(request.message(hasCalendarRecords: !request.calendarRecords.isEmpty))
                }
            }
            .alert("无法删除", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("好") {}
            } message: {
                Text(saveError ?? "未知错误")
            }
    }

    @ViewBuilder
    private func deletionActions(for request: ScheduleWorkspaceDeletionRequest) -> some View {
        if request.canRemoveCalendarEvents && !request.calendarRecords.isEmpty {
            Button("同时删除日历事件", role: .destructive) {
                delete(request, removingCalendarEvents: true)
            }
            Button("只删除应用数据", role: .destructive) {
                delete(request, removingCalendarEvents: false)
            }
        } else {
            Button(request.deleteButtonTitle, role: .destructive) {
                delete(request, removingCalendarEvents: false)
            }
        }
        Button("取消", role: .cancel) {}
    }

    private func delete(
        _ request: ScheduleWorkspaceDeletionRequest,
        removingCalendarEvents: Bool
    ) {
        switch request.kind {
        case .timetable(let timetable):
            delete(timetable, records: request.calendarRecords, removingCalendarEvents: removingCalendarEvents)
        case .course(let course):
            delete(course)
        case .period(let period):
            guard let timetable = period.timetable else { return }
            delete(
                period,
                from: timetable,
                records: request.calendarRecords,
                removingCalendarEvents: removingCalendarEvents
            )
        case .schedule(let schedule):
            guard let timetable = schedule.timetable else { return }
            delete(
                schedule,
                from: timetable,
                records: request.calendarRecords,
                removingCalendarEvents: removingCalendarEvents
            )
        case .scheduleOverride(let scheduleOverride):
            guard let timetable = scheduleOverride.timetable else { return }
            delete(scheduleOverride, from: timetable)
        }
    }

    private func delete(
        _ timetable: Timetable,
        records: [CalendarExportRecord],
        removingCalendarEvents: Bool
    ) {
        let identifier = timetable.persistentModelID
        let wasCurrent = timetable.isCurrent
        let nextTimetable = timetables.first { $0.persistentModelID != identifier }
        let notificationTimetable = wasCurrent
            ? nextTimetable
            : timetables.first(where: { $0.isCurrent })

        Task {
            do {
                if removingCalendarEvents {
                    try await CalendarExportService.removeEvents(for: records, modelContext: modelContext)
                }
                modelContext.delete(timetable)
                if wasCurrent {
                    nextTimetable?.isCurrent = true
                }
                try modelContext.save()
                try await CourseNotificationService.refresh(timetable: notificationTimetable)
                sidebarSelection = nextTimetable.map {
                    .timetable($0.persistentModelID)
                } ?? .courses
                itemSelection = nextTimetable.map {
                    .timetable($0.persistentModelID)
                }
                request = nil
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func delete(_ course: Course) {
        let identifier = course.persistentModelID
        let affectedTimetables = uniqueTimetables(course.schedules.compactMap(\.timetable))
        let notificationTimetable = timetables.first(where: { $0.isCurrent }) ?? timetables.first

        modelContext.delete(course)
        do {
            try modelContext.save()
            if itemSelection == .course(identifier) {
                itemSelection = nil
            }
            request = nil
        } catch {
            saveError = error.localizedDescription
            return
        }

        Task {
            do {
                for timetable in affectedTimetables {
                    try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                }
                try await CourseNotificationService.refresh(timetable: notificationTimetable)
            } catch {
                saveError = "数据已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private func delete<T: PersistentModel>(
        _ model: T,
        from timetable: Timetable,
        records: [CalendarExportRecord],
        removingCalendarEvents: Bool
    ) {
        Task {
            do {
                if removingCalendarEvents {
                    try await CalendarExportService.removeEvents(for: records, modelContext: modelContext)
                }
                modelContext.delete(model)
                try modelContext.save()
                try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                try await CourseNotificationService.refresh(timetable: timetable)
                itemSelection = nil
                request = nil
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func delete(_ scheduleOverride: ScheduleOverride, from timetable: Timetable) {
        modelContext.delete(scheduleOverride)
        do {
            try modelContext.save()
            itemSelection = nil
            request = nil
        } catch {
            saveError = error.localizedDescription
            return
        }

        Task {
            do {
                try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                try await CourseNotificationService.refresh(timetable: timetable)
            } catch {
                saveError = "数据已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private func uniqueTimetables(_ values: [Timetable]) -> [Timetable] {
        var identifiers = Set<PersistentIdentifier>()
        return values.filter { identifiers.insert($0.persistentModelID).inserted }
    }
}

extension View {
    func scheduleWorkspaceDeletion(
        request: Binding<ScheduleWorkspaceDeletionRequest?>,
        sidebarSelection: Binding<ScheduleWorkspaceSidebarSelection?>,
        itemSelection: Binding<ScheduleWorkspaceItem?>
    ) -> some View {
        modifier(ScheduleWorkspaceDeletionModifier(
            request: request,
            sidebarSelection: sidebarSelection,
            itemSelection: itemSelection
        ))
    }
}
