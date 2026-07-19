import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CompactScheduleManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Timetable.startDate, order: .reverse) private var timetables: [Timetable]
    @Query(sort: \Course.name) private var courses: [Course]

    @State private var editorRequest: ScheduleEditorRequest?
    @State private var timetableToDelete: Timetable?
    @State private var courseToDelete: Course?
    @State private var saveError: String?

    private var activeTimetable: Timetable? {
        timetables.first(where: { $0.isCurrent }) ?? timetables.first
    }

    var body: some View {
        List {
            Section("课程表") {
                if timetables.isEmpty {
                    Button("新建课程表", systemImage: "calendar.badge.plus") {
                        editorRequest = .timetable(nil)
                    }
                } else {
                    ForEach(timetables) { timetable in
                        NavigationLink {
                            TimetableManagementDetailView(timetable: timetable)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(timetable.name)
                                    if timetable.isCurrent {
                                        Text("当前")
                                            .font(.caption)
                                            .foregroundStyle(.tint)
                                    }
                                }
                                Text("\(timetable.startDate.formatted(date: .abbreviated, time: .omitted)) - \(timetable.endDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                timetableToDelete = timetable
                            } label: {
                                Label("删除", systemImage: "trash")
                            }

                            Button {
                                editorRequest = .timetable(timetable)
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)

                            Button {
                                duplicate(timetable)
                            } label: {
                                Label("复制", systemImage: "doc.on.doc")
                            }
                            .tint(.indigo)
                        }
                    }
                }
            }

            Section("课程") {
                if courses.isEmpty {
                    Button("新建课程", systemImage: "book.closed") {
                        editorRequest = .course(nil)
                    }
                } else {
                    ForEach(courses) { course in
                        Button {
                            editorRequest = .course(course)
                        } label: {
                            HStack {
                                Label(course.name, systemImage: course.systemImage)
                                Spacer()
                                if !course.schedules.isEmpty {
                                    Text("\(course.schedules.count) 个安排")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                courseToDelete = course
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if let timetable = activeTimetable {
                Section("\(timetable.name)的安排") {
                    if timetable.schedules.isEmpty {
                        Button("添加课程安排", systemImage: "plus") {
                            editorRequest = .arrangement(timetable, nil)
                        }
                        .disabled(timetable.periods.isEmpty || courses.isEmpty)
                    } else {
                        ForEach(sortedSchedules(in: timetable)) { schedule in
                            Button {
                                editorRequest = .arrangement(timetable, schedule)
                            } label: {
                                ScheduleManagementRow(schedule: schedule)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("课程管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("新建课程表", systemImage: "calendar.badge.plus") {
                        editorRequest = .timetable(nil)
                    }
                    Button("新建课程", systemImage: "book.closed") {
                        editorRequest = .course(nil)
                    }
                    if let timetable = activeTimetable {
                        Button("复制当前课程表", systemImage: "doc.on.doc") {
                            duplicate(timetable)
                        }
                        Button("添加节次", systemImage: "clock.badge.plus") {
                            editorRequest = .period(timetable, nil)
                        }
                        Button("添加课程安排", systemImage: "plus") {
                            editorRequest = .arrangement(timetable, nil)
                        }
                        .disabled(timetable.periods.isEmpty || courses.isEmpty)
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .help("新增")
            }
        }
        .sheet(item: $editorRequest) { request in
            ScheduleEditorSheet(request: request)
        }
        .confirmationDialog(
            "删除课程表？",
            isPresented: Binding(
                get: { timetableToDelete != nil },
                set: { if !$0 { timetableToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let timetableToDelete, !calendarRecords(for: timetableToDelete).isEmpty {
                Button("同时删除日历事件", role: .destructive) {
                    delete(timetableToDelete, removingCalendarEvents: true)
                }
                Button("只删除应用数据", role: .destructive) {
                    delete(timetableToDelete, removingCalendarEvents: false)
                }
            } else {
                Button("删除课程表", role: .destructive) {
                    if let timetableToDelete {
                        delete(timetableToDelete, removingCalendarEvents: false)
                    }
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            if let timetableToDelete, !calendarRecords(for: timetableToDelete).isEmpty {
                Text("节次、课程安排和日期调整会一起删除。你可以保留已导出的系统日历事件。")
            } else {
                Text("节次、课程安排和日期调整会一起删除，课程本身会保留。")
            }
        }
        .confirmationDialog(
            "删除课程？",
            isPresented: Binding(
                get: { courseToDelete != nil },
                set: { if !$0 { courseToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("删除课程", role: .destructive) {
                if let courseToDelete {
                    delete(courseToDelete)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("课程安排会保留，但不再关联这门课程。")
        }
        .alert("无法保存", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("好") {}
        } message: {
            Text(saveError ?? "未知错误")
        }
    }

    private func sortedSchedules(in timetable: Timetable) -> [CourseSchedule] {
        timetable.schedules.sorted { lhs, rhs in
            if lhs.weekday != rhs.weekday { return lhs.weekday < rhs.weekday }
            return (lhs.period?.startMinute ?? Int.max) < (rhs.period?.startMinute ?? Int.max)
        }
    }

    private func calendarRecords(for timetable: Timetable) -> [CalendarExportRecord] {
        timetable.schedules.flatMap(\.calendarExportRecords)
    }

    private func delete(_ timetable: Timetable, removingCalendarEvents: Bool) {
        let timetableID = timetable.persistentModelID
        let wasCurrent = timetable.isCurrent
        let nextTimetable = timetables.first { $0.persistentModelID != timetableID }
        let timetableForNotifications = wasCurrent ? nextTimetable : activeTimetable
        let records = calendarRecords(for: timetable)

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
                try await CourseNotificationService.refresh(timetable: timetableForNotifications)
                timetableToDelete = nil
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func delete(_ course: Course) {
        let affectedTimetables = uniqueTimetables(course.schedules.compactMap(\.timetable))
        let timetableForNotifications = activeTimetable
        modelContext.delete(course)
        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
            return
        }

        Task {
            do {
                for timetable in affectedTimetables {
                    try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                }
                try await CourseNotificationService.refresh(timetable: timetableForNotifications)
                courseToDelete = nil
            } catch {
                saveError = "数据已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private func duplicate(_ timetable: Timetable) {
        do {
            _ = try TimetableCopyService.copyTimetable(timetable, in: modelContext)
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func uniqueTimetables(_ values: [Timetable]) -> [Timetable] {
        var identifiers = Set<PersistentIdentifier>()
        return values.filter { identifiers.insert($0.persistentModelID).inserted }
    }
}

struct TimetableManagementDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timetables: [Timetable]
    @Query private var courses: [Course]
    @Query private var subjects: [Subject]
    let timetable: Timetable

    @State private var editorRequest: ScheduleEditorRequest?
    @State private var periodToDelete: ClassPeriod?
    @State private var scheduleToDelete: CourseSchedule?
    @State private var overrideToDelete: ScheduleOverride?
    @State private var isCopyingDay = false
    @State private var archiveDocument: TimetableArchiveDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var importedTimetableName: String?
    @State private var saveError: String?

    private var sortedPeriods: [ClassPeriod] {
        timetable.periods.sorted { lhs, rhs in
            if lhs.startMinute == rhs.startMinute { return lhs.orderIndex < rhs.orderIndex }
            return lhs.startMinute < rhs.startMinute
        }
    }

    private var sortedSchedules: [CourseSchedule] {
        timetable.schedules.sorted { lhs, rhs in
            if lhs.weekday != rhs.weekday { return lhs.weekday < rhs.weekday }
            return (lhs.period?.startMinute ?? Int.max) < (rhs.period?.startMinute ?? Int.max)
        }
    }

    private var sortedOverrides: [ScheduleOverride] {
        timetable.overrides.sorted { lhs, rhs in
            if lhs.date == rhs.date {
                return (lhs.replacementStartMinute ?? lhs.schedule?.period?.startMinute ?? Int.max)
                    < (rhs.replacementStartMinute ?? rhs.schedule?.period?.startMinute ?? Int.max)
            }
            return lhs.date < rhs.date
        }
    }

    var body: some View {
        List {
            Section("课程表") {
                Button {
                    editorRequest = .timetable(timetable)
                } label: {
                    LabeledContent("名称", value: timetable.name)
                }
                .buttonStyle(.plain)
                LabeledContent("日期") {
                    Text("\(timetable.startDate.formatted(date: .abbreviated, time: .omitted)) - \(timetable.endDate.formatted(date: .abbreviated, time: .omitted))")
                }
                LabeledContent("首周", value: timetable.firstWeekParity.displayName)
                if !timetable.isCurrent {
                    Button("设为当前课程表") {
                        setAsCurrent()
                    }
                }
            }

            Section("节次") {
                if sortedPeriods.isEmpty {
                    Button("添加节次", systemImage: "clock.badge.plus") {
                        editorRequest = .period(timetable, nil)
                    }
                } else {
                    ForEach(sortedPeriods) { period in
                        Button {
                            editorRequest = .period(timetable, period)
                        } label: {
                            HStack {
                                Text(period.name)
                                Spacer()
                                Text("\(minuteText(period.startMinute)) - \(minuteText(period.endMinute))")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                periodToDelete = period
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            Section("课程安排") {
                if sortedSchedules.isEmpty {
                    Button("添加课程安排", systemImage: "plus") {
                        editorRequest = .arrangement(timetable, nil)
                    }
                    .disabled(sortedPeriods.isEmpty)
                } else {
                    ForEach(sortedSchedules) { schedule in
                        Button {
                            editorRequest = .arrangement(timetable, schedule)
                        } label: {
                            ScheduleManagementRow(schedule: schedule)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                scheduleToDelete = schedule
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            Section("指定日期调整") {
                if sortedOverrides.isEmpty {
                    Button("添加日期调整", systemImage: "calendar.badge.clock") {
                        editorRequest = .scheduleOverride(timetable, nil)
                    }
                } else {
                    ForEach(sortedOverrides) { scheduleOverride in
                        Button {
                            editorRequest = .scheduleOverride(timetable, scheduleOverride)
                        } label: {
                            ScheduleOverrideManagementRow(scheduleOverride: scheduleOverride)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                overrideToDelete = scheduleOverride
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(timetable.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("编辑课程表", systemImage: "pencil") {
                        editorRequest = .timetable(timetable)
                    }
                    Button("添加节次", systemImage: "clock.badge.plus") {
                        editorRequest = .period(timetable, nil)
                    }
                    Button("添加课程安排", systemImage: "plus") {
                        editorRequest = .arrangement(timetable, nil)
                    }
                    .disabled(sortedPeriods.isEmpty)
                    Button("添加日期调整", systemImage: "calendar.badge.clock") {
                        editorRequest = .scheduleOverride(timetable, nil)
                    }
                    Button("复制一天安排", systemImage: "doc.on.doc") {
                        isCopyingDay = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("导出课程表", systemImage: "square.and.arrow.up") {
                        prepareExport()
                    }
                    Button("导入课程表", systemImage: "square.and.arrow.down") {
                        isImporting = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $editorRequest) { request in
            ScheduleEditorSheet(request: request)
        }
        .sheet(isPresented: $isCopyingDay) {
            DayScheduleCopyView(timetable: timetable)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: archiveDocument,
            contentType: .json,
            defaultFilename: "\(timetable.name).json"
        ) { result in
            if case .failure(let error) = result {
                saveError = error.localizedDescription
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: importContentTypes,
            allowsMultipleSelection: false
        ) { result in
            importTimetable(result)
        }
        .confirmationDialog(
            "删除节次？",
            isPresented: Binding(
                get: { periodToDelete != nil },
                set: { if !$0 { periodToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let periodToDelete, !calendarRecords(for: periodToDelete).isEmpty {
                Button("同时删除日历事件", role: .destructive) {
                    delete(periodToDelete, removingCalendarEvents: true)
                }
                Button("只删除应用数据", role: .destructive) {
                    delete(periodToDelete, removingCalendarEvents: false)
                }
            } else {
                Button("删除节次", role: .destructive) {
                    if let periodToDelete { delete(periodToDelete, removingCalendarEvents: false) }
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            if let periodToDelete, !calendarRecords(for: periodToDelete).isEmpty {
                Text("使用该节次的课程安排也会删除。你可以保留已导出的系统日历事件。")
            } else {
                Text("使用该节次的课程安排也会删除。")
            }
        }
        .confirmationDialog(
            "删除课程安排？",
            isPresented: Binding(
                get: { scheduleToDelete != nil },
                set: { if !$0 { scheduleToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let scheduleToDelete, !scheduleToDelete.calendarExportRecords.isEmpty {
                Button("同时删除日历事件", role: .destructive) {
                    delete(scheduleToDelete, removingCalendarEvents: true)
                }
                Button("只删除应用数据", role: .destructive) {
                    delete(scheduleToDelete, removingCalendarEvents: false)
                }
            } else {
                Button("删除课程安排", role: .destructive) {
                    if let scheduleToDelete { delete(scheduleToDelete, removingCalendarEvents: false) }
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            if let scheduleToDelete, !scheduleToDelete.calendarExportRecords.isEmpty {
                Text("你可以保留已导出的系统日历事件。")
            }
        }
        .confirmationDialog(
            "删除日期调整？",
            isPresented: Binding(
                get: { overrideToDelete != nil },
                set: { if !$0 { overrideToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("删除日期调整", role: .destructive) {
                if let overrideToDelete { delete(overrideToDelete) }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("无法保存", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("好") {}
        } message: {
            Text(saveError ?? "未知错误")
        }
        .alert("导入完成", isPresented: Binding(
            get: { importedTimetableName != nil },
            set: { if !$0 { importedTimetableName = nil } }
        )) {
            Button("好") {}
        } message: {
            Text("已创建“\(importedTimetableName ?? "导入的课程表")”。原课程表没有被覆盖。")
        }
    }

    private var importContentTypes: [UTType] {
        var values: [UTType] = [.json]
        if let yaml = UTType(filenameExtension: "yaml") { values.append(yaml) }
        if let yml = UTType(filenameExtension: "yml") { values.append(yml) }
        return values
    }

    private func prepareExport() {
        do {
            archiveDocument = TimetableArchiveDocument(
                data: try TimetableArchiveService.exportData(for: timetable)
            )
            isExporting = true
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func importTimetable(_ result: Result<[URL], Error>) {
        do {
            let url = try result.get().first
            guard let url else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed { url.stopAccessingSecurityScopedResource() }
            }
            let data = try Data(contentsOf: url)
            let imported = try TimetableArchiveService.importData(
                data,
                fileExtension: url.pathExtension,
                referenceTimetable: timetable,
                existingTimetables: timetables,
                existingCourses: courses,
                subjects: subjects,
                modelContext: modelContext
            )
            importedTimetableName = imported.name
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func setAsCurrent() {
        let descriptor = FetchDescriptor<Timetable>()
        do {
            for item in try modelContext.fetch(descriptor) {
                item.isCurrent = item.persistentModelID == timetable.persistentModelID
                item.updatedAt = Date()
            }
            try modelContext.save()
            Task {
                do {
                    try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                    try await CourseNotificationService.refresh(timetable: timetable)
                } catch {
                    saveError = "当前课程表已更新，但系统同步失败：\(error.localizedDescription)"
                }
            }
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func calendarRecords(for period: ClassPeriod) -> [CalendarExportRecord] {
        period.schedules.flatMap(\.calendarExportRecords)
    }

    private func delete(_ period: ClassPeriod, removingCalendarEvents: Bool) {
        delete(
            period,
            removing: calendarRecords(for: period),
            removingCalendarEvents: removingCalendarEvents
        )
    }

    private func delete(_ schedule: CourseSchedule, removingCalendarEvents: Bool) {
        delete(
            schedule,
            removing: schedule.calendarExportRecords,
            removingCalendarEvents: removingCalendarEvents
        )
    }

    private func delete(_ scheduleOverride: ScheduleOverride) {
        modelContext.delete(scheduleOverride)
        saveAndRefreshNotifications()
        overrideToDelete = nil
    }

    private func saveAndRefreshNotifications() {
        do {
            try modelContext.save()
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

    private func delete<T: PersistentModel>(
        _ model: T,
        removing records: [CalendarExportRecord],
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
                periodToDelete = nil
                scheduleToDelete = nil
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    private func minuteText(_ minute: Int) -> String {
        String(format: "%02d:%02d", minute / 60, minute % 60)
    }
}

struct ScheduleOverrideManagementRow: View {
    let scheduleOverride: ScheduleOverride

    private var title: String {
        switch scheduleOverride.action {
        case .cancel:
            "停课 · \(scheduleOverride.schedule?.course?.name ?? "未关联课程")"
        case .replace:
            "换课 · \(scheduleOverride.replacementCourse?.name ?? "未关联课程")"
        case .add:
            "加课 · \(scheduleOverride.replacementCourse?.name ?? "未关联课程")"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: scheduleOverride.action.systemImage)
                .foregroundStyle(.tint)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                Text(scheduleOverride.date, format: .dateTime.year().month().day().weekday(.abbreviated))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

struct ScheduleManagementRow: View {
    let schedule: CourseSchedule

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: schedule.course?.systemImage ?? "book.closed")
                .foregroundStyle(.tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(schedule.course?.name ?? "未关联课程")
                HStack(spacing: 6) {
                    Text(schedule.weekday.displayName)
                    if let period = schedule.period {
                        Text(period.name)
                    }
                    Text(schedule.repeatRule.displayName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

struct ScheduleEditorRequest: Identifiable {
    enum Kind {
        case timetable(Timetable?)
        case course(Course?)
        case period(Timetable, ClassPeriod?)
        case arrangement(Timetable, CourseSchedule?)
        case scheduleOverride(Timetable, ScheduleOverride?)
    }

    let id = UUID()
    let kind: Kind

    static func timetable(_ timetable: Timetable?) -> Self {
        Self(kind: .timetable(timetable))
    }

    static func course(_ course: Course?) -> Self {
        Self(kind: .course(course))
    }

    static func period(_ timetable: Timetable, _ period: ClassPeriod?) -> Self {
        Self(kind: .period(timetable, period))
    }

    static func arrangement(_ timetable: Timetable, _ schedule: CourseSchedule?) -> Self {
        Self(kind: .arrangement(timetable, schedule))
    }

    static func scheduleOverride(_ timetable: Timetable, _ scheduleOverride: ScheduleOverride?) -> Self {
        Self(kind: .scheduleOverride(timetable, scheduleOverride))
    }
}

struct ScheduleEditorSheet: View {
    let request: ScheduleEditorRequest

    var body: some View {
        switch request.kind {
        case .timetable(let timetable):
            TimetableEditView(timetable: timetable)
        case .course(let course):
            CourseEditView(course: course)
        case .period(let timetable, let period):
            ClassPeriodEditView(timetable: timetable, period: period)
        case .arrangement(let timetable, let schedule):
            CourseScheduleEditView(timetable: timetable, schedule: schedule)
        case .scheduleOverride(let timetable, let scheduleOverride):
            ScheduleOverrideEditView(timetable: timetable, scheduleOverride: scheduleOverride)
        }
    }
}

extension WeekParity {
    var displayName: String {
        switch self {
        case .odd: "单周"
        case .even: "双周"
        }
    }
}

extension CourseRepeatRule {
    var displayName: String {
        switch self {
        case .weekly: "每周"
        case .oddWeeks: "单周"
        case .evenWeeks: "双周"
        }
    }
}

extension ScheduleOverrideAction {
    var displayName: String {
        switch self {
        case .cancel: "停课"
        case .replace: "换课"
        case .add: "临时加课"
        }
    }

    var systemImage: String {
        switch self {
        case .cancel: "calendar.badge.minus"
        case .replace: "calendar.badge.clock"
        case .add: "calendar.badge.plus"
        }
    }
}

extension Int {
    var displayName: String {
        switch self {
        case 1: "周一"
        case 2: "周二"
        case 3: "周三"
        case 4: "周四"
        case 5: "周五"
        case 6: "周六"
        case 7: "周日"
        default: "未知"
        }
    }
}
