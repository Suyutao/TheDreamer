import SwiftUI
import SwiftData

struct ScheduleManagementView: View {
    var body: some View {
        #if os(macOS)
        ScheduleWorkspaceView()
        #else
        ViewThatFits(in: .horizontal) {
            ScheduleWorkspaceView()
                .frame(minWidth: 720)
            CompactScheduleManagementView()
        }
        #endif
    }
}

struct ScheduleWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \Timetable.startDate, order: .reverse) private var timetables: [Timetable]
    @Query(sort: \Course.name) private var courses: [Course]

    @State private var sidebarSelection: ScheduleWorkspaceSidebarSelection?
    @State private var category: ScheduleWorkspaceCategory = .arrangements
    @State private var itemSelection: ScheduleWorkspaceItem?
    @State private var editorRequest: ScheduleEditorRequest?

    init(initialTimetableID: PersistentIdentifier? = nil) {
        _sidebarSelection = State(
            initialValue: initialTimetableID.map(ScheduleWorkspaceSidebarSelection.timetable)
        )
        _itemSelection = State(
            initialValue: initialTimetableID.map(ScheduleWorkspaceItem.timetable)
        )
    }

    private var selectedTimetable: Timetable? {
        guard case .timetable(let identifier) = sidebarSelection else { return nil }
        return modelContext.model(for: identifier) as? Timetable
    }

    var body: some View {
        NavigationSplitView {
            ScheduleWorkspaceSidebar(
                timetables: timetables,
                selection: $sidebarSelection,
                createTimetable: { editorRequest = .timetable(nil) },
                createCourse: { editorRequest = .course(nil) }
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 320)
        } content: {
            ScheduleWorkspaceContent(
                timetable: selectedTimetable,
                courses: courses,
                sidebarSelection: sidebarSelection,
                category: $category,
                itemSelection: $itemSelection,
                createItem: createItem
            )
            .navigationSplitViewColumnWidth(min: 320, ideal: 440, max: 620)
        } detail: {
            ScheduleWorkspaceDetail(selection: itemSelection)
                .id(itemSelection)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if let selectedTimetable {
                    Button("在新窗口中打开", systemImage: "macwindow.badge.plus") {
                        openWindow(
                            id: "timetable-workspace",
                            value: selectedTimetable.persistentModelID
                        )
                    }
                    .help("在新窗口中打开")
                }

                Menu {
                    Button("新建课程表", systemImage: "calendar.badge.plus") {
                        editorRequest = .timetable(nil)
                    }
                    Button("新建课程", systemImage: "book.closed") {
                        editorRequest = .course(nil)
                    }
                    if let selectedTimetable {
                        Button("添加节次", systemImage: "clock.badge.plus") {
                            editorRequest = .period(selectedTimetable, nil)
                        }
                        Button("添加课程安排", systemImage: "plus") {
                            editorRequest = .arrangement(selectedTimetable, nil)
                        }
                        .disabled(selectedTimetable.periods.isEmpty || courses.isEmpty)
                        Button("添加日期调整", systemImage: "calendar.badge.clock") {
                            editorRequest = .scheduleOverride(selectedTimetable, nil)
                        }
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
        .onAppear(perform: selectInitialDestination)
        .onChange(of: sidebarSelection, handleSidebarSelection)
        .onChange(of: timetables.map(\.persistentModelID), handleTimetableChanges)
    }

    private func selectInitialDestination() {
        guard sidebarSelection == nil else { return }
        if let timetable = timetables.first(where: { $0.isCurrent }) ?? timetables.first {
            sidebarSelection = .timetable(timetable.persistentModelID)
        } else {
            sidebarSelection = .courses
        }
    }

    private func handleSidebarSelection(
        _ oldValue: ScheduleWorkspaceSidebarSelection?,
        _ newValue: ScheduleWorkspaceSidebarSelection?
    ) {
        switch newValue {
        case .timetable(let identifier):
            itemSelection = .timetable(identifier)
        case .courses:
            itemSelection = courses.first.map { .course($0.persistentModelID) }
        case nil:
            itemSelection = nil
        }
    }

    private func handleTimetableChanges(
        _ oldValue: [PersistentIdentifier],
        _ newValue: [PersistentIdentifier]
    ) {
        guard case .timetable(let identifier) = sidebarSelection,
              !newValue.contains(identifier)
        else { return }
        sidebarSelection = newValue.first.map(ScheduleWorkspaceSidebarSelection.timetable) ?? .courses
    }

    private func createItem() {
        if case .courses = sidebarSelection {
            editorRequest = .course(nil)
            return
        }
        guard let selectedTimetable else { return }
        switch category {
        case .arrangements:
            editorRequest = .arrangement(selectedTimetable, nil)
        case .periods:
            editorRequest = .period(selectedTimetable, nil)
        case .overrides:
            editorRequest = .scheduleOverride(selectedTimetable, nil)
        }
    }
}

private struct ScheduleWorkspaceSidebar: View {
    let timetables: [Timetable]
    @Binding var selection: ScheduleWorkspaceSidebarSelection?
    let createTimetable: () -> Void
    let createCourse: () -> Void

    var body: some View {
        List(selection: $selection) {
            Section("课程表") {
                ForEach(timetables) { timetable in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(timetable.name)
                            Text(timetable.startDate, format: .dateTime.year().month().day())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: timetable.isCurrent ? "calendar.circle.fill" : "calendar")
                            .foregroundStyle(timetable.isCurrent ? Color.accentColor : Color.secondary)
                    }
                    .tag(ScheduleWorkspaceSidebarSelection.timetable(timetable.persistentModelID))
                    .contextMenu {
                        Button("编辑课程表", systemImage: "pencil") {
                            selection = .timetable(timetable.persistentModelID)
                        }
                    }
                }

                Button("新建课程表", systemImage: "calendar.badge.plus", action: createTimetable)
                    .buttonStyle(.plain)
            }

            Section("资料") {
                Label("课程库", systemImage: "books.vertical")
                    .tag(ScheduleWorkspaceSidebarSelection.courses)
                Button("新建课程", systemImage: "book.closed", action: createCourse)
                    .buttonStyle(.plain)
            }
        }
        .navigationTitle("课程管理")
    }
}

private struct ScheduleWorkspaceContent: View {
    let timetable: Timetable?
    let courses: [Course]
    let sidebarSelection: ScheduleWorkspaceSidebarSelection?
    @Binding var category: ScheduleWorkspaceCategory
    @Binding var itemSelection: ScheduleWorkspaceItem?
    let createItem: () -> Void

    private var sortedSchedules: [CourseSchedule] {
        guard let timetable else { return [] }
        return timetable.schedules.sorted {
            if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
            return ($0.period?.startMinute ?? Int.max) < ($1.period?.startMinute ?? Int.max)
        }
    }

    private var sortedPeriods: [ClassPeriod] {
        timetable?.periods.sorted {
            if $0.startMinute != $1.startMinute { return $0.startMinute < $1.startMinute }
            return $0.orderIndex < $1.orderIndex
        } ?? []
    }

    private var sortedOverrides: [ScheduleOverride] {
        timetable?.overrides.sorted { $0.date < $1.date } ?? []
    }

    var body: some View {
        Group {
            if case .courses = sidebarSelection {
                courseList
            } else if let timetable {
                timetableContent(timetable)
            } else {
                ContentUnavailableView("选择课程表", systemImage: "calendar")
            }
        }
        .navigationTitle(contentTitle)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("新增", systemImage: "plus", action: createItem)
            }
        }
    }

    private var contentTitle: String {
        if case .courses = sidebarSelection { return "课程库" }
        return timetable?.name ?? "课程表"
    }

    private var courseList: some View {
        List(courses, selection: $itemSelection) { course in
            Label(course.name, systemImage: course.systemImage)
                .tag(ScheduleWorkspaceItem.course(course.persistentModelID))
        }
        .overlay {
            if courses.isEmpty {
                ContentUnavailableView("尚无课程", systemImage: "books.vertical")
            }
        }
    }

    private func timetableContent(_ timetable: Timetable) -> some View {
        VStack(spacing: 0) {
            Picker("内容", selection: $category) {
                ForEach(ScheduleWorkspaceCategory.allCases) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()

            Divider()

            switch category {
            case .arrangements:
                arrangementCollection
            case .periods:
                periodList
            case .overrides:
                overrideList
            }
        }
    }

    @ViewBuilder
    private var arrangementCollection: some View {
        #if os(macOS)
        MacScheduleTable(schedules: sortedSchedules, selection: $itemSelection)
        #else
        List(sortedSchedules, selection: $itemSelection) { schedule in
            ScheduleManagementRow(schedule: schedule)
                .tag(ScheduleWorkspaceItem.schedule(schedule.persistentModelID))
        }
        .overlay {
            if sortedSchedules.isEmpty {
                ContentUnavailableView("尚无课程安排", systemImage: "calendar.day.timeline.left")
            }
        }
        #endif
    }

    private var periodList: some View {
        List(sortedPeriods, selection: $itemSelection) { period in
            LabeledContent(period.name) {
                Text("\(minuteText(period.startMinute)) - \(minuteText(period.endMinute))")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .tag(ScheduleWorkspaceItem.period(period.persistentModelID))
        }
        .overlay {
            if sortedPeriods.isEmpty {
                ContentUnavailableView("尚无节次", systemImage: "clock")
            }
        }
    }

    private var overrideList: some View {
        List(sortedOverrides, selection: $itemSelection) { scheduleOverride in
            ScheduleOverrideManagementRow(scheduleOverride: scheduleOverride)
                .tag(ScheduleWorkspaceItem.scheduleOverride(scheduleOverride.persistentModelID))
        }
        .overlay {
            if sortedOverrides.isEmpty {
                ContentUnavailableView("尚无日期调整", systemImage: "calendar.badge.clock")
            }
        }
    }

    private func minuteText(_ minute: Int) -> String {
        String(format: "%02d:%02d", minute / 60, minute % 60)
    }
}

private struct MacScheduleTable: View {
    let schedules: [CourseSchedule]
    @Binding var selection: ScheduleWorkspaceItem?

    private var scheduleSelection: Binding<PersistentIdentifier?> {
        Binding {
            guard case .schedule(let identifier) = selection else { return nil }
            return identifier
        } set: { identifier in
            selection = identifier.map(ScheduleWorkspaceItem.schedule)
        }
    }

    var body: some View {
        Table(schedules, selection: scheduleSelection) {
            TableColumn("星期") { schedule in
                Text(schedule.weekday.displayName)
            }
            .width(min: 54, ideal: 64)

            TableColumn("时间") { schedule in
                if let period = schedule.period {
                    Text("\(minuteText(period.startMinute))-\(minuteText(period.endMinute))")
                        .monospacedDigit()
                }
            }
            .width(min: 88, ideal: 100)

            TableColumn("课程") { schedule in
                Text(schedule.course?.name ?? "未关联课程")
            }

            TableColumn("教师", value: \.teacher)
            TableColumn("地点", value: \.location)
            TableColumn("重复") { schedule in
                Text(schedule.repeatRule.displayName)
            }
            .width(min: 54, ideal: 64)
        }
        .overlay {
            if schedules.isEmpty {
                ContentUnavailableView("尚无课程安排", systemImage: "calendar.day.timeline.left")
            }
        }
    }

    private func minuteText(_ minute: Int) -> String {
        String(format: "%02d:%02d", minute / 60, minute % 60)
    }
}

private struct ScheduleWorkspaceDetail: View {
    @Environment(\.modelContext) private var modelContext
    let selection: ScheduleWorkspaceItem?

    var body: some View {
        Group {
            switch selection {
            case .timetable(let identifier):
                if let timetable = modelContext.model(for: identifier) as? Timetable {
                    TimetableEditView(timetable: timetable, presentation: .embedded)
                } else {
                    unavailable
                }
            case .course(let identifier):
                if let course = modelContext.model(for: identifier) as? Course {
                    CourseEditView(course: course, presentation: .embedded)
                } else {
                    unavailable
                }
            case .period(let identifier):
                if let period = modelContext.model(for: identifier) as? ClassPeriod,
                   let timetable = period.timetable {
                    ClassPeriodEditView(
                        timetable: timetable,
                        period: period,
                        presentation: .embedded
                    )
                } else {
                    unavailable
                }
            case .schedule(let identifier):
                if let schedule = modelContext.model(for: identifier) as? CourseSchedule,
                   let timetable = schedule.timetable {
                    CourseScheduleEditView(
                        timetable: timetable,
                        schedule: schedule,
                        presentation: .embedded
                    )
                } else {
                    unavailable
                }
            case .scheduleOverride(let identifier):
                if let scheduleOverride = modelContext.model(for: identifier) as? ScheduleOverride,
                   let timetable = scheduleOverride.timetable {
                    ScheduleOverrideEditView(
                        timetable: timetable,
                        scheduleOverride: scheduleOverride,
                        presentation: .embedded
                    )
                } else {
                    unavailable
                }
            case nil:
                ContentUnavailableView("选择要编辑的内容", systemImage: "sidebar.right")
            }
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private var unavailable: some View {
        ContentUnavailableView("内容不可用", systemImage: "exclamationmark.triangle")
    }
}
