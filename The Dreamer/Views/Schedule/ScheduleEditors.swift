import SwiftUI
import SwiftData

struct TimetableEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var timetables: [Timetable]

    let timetable: Timetable?
    let presentation: ScheduleEditorPresentation

    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var firstWeekParity: WeekParity
    @State private var isCurrent: Bool
    @State private var saveError: String?

    init(
        timetable: Timetable?,
        presentation: ScheduleEditorPresentation = .sheet
    ) {
        self.timetable = timetable
        self.presentation = presentation
        _name = State(initialValue: timetable?.name ?? "")
        _startDate = State(initialValue: timetable?.startDate ?? Calendar.current.startOfDay(for: Date()))
        _endDate = State(initialValue: timetable?.endDate ?? Calendar.current.date(byAdding: .month, value: 5, to: Date()) ?? Date())
        _firstWeekParity = State(initialValue: timetable?.firstWeekParity ?? .odd)
        _isCurrent = State(initialValue: timetable?.isCurrent ?? false)
    }

    private var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "请输入课程表名称。"
        }
        if endDate < startDate {
            return "结束日期不能早于开始日期。"
        }
        return nil
    }

    var body: some View {
        ScheduleEditorContainer(presentation: presentation) {
            Form {
                Section("基本信息") {
                    TextField("课程表名称", text: $name)
                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                }

                Section("周次") {
                    Picker("第 1 周", selection: $firstWeekParity) {
                        ForEach(WeekParity.allCases, id: \.self) { parity in
                            Text(parity.displayName).tag(parity)
                        }
                    }
                    Toggle("设为当前课程表", isOn: $isCurrent)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(timetable == nil ? "新建课程表" : "编辑课程表")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if presentation == .sheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(validationMessage != nil)
                }
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
    }

    private func save() {
        guard validationMessage == nil else { return }

        if isCurrent {
            for item in timetables {
                item.isCurrent = item.persistentModelID == timetable?.persistentModelID
            }
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedTimetable: Timetable
        if let timetable {
            timetable.name = trimmedName
            timetable.startDate = startDate
            timetable.endDate = endDate
            timetable.firstWeekParity = firstWeekParity
            timetable.isCurrent = isCurrent
            timetable.updatedAt = Date()
            savedTimetable = timetable
        } else {
            let newTimetable = Timetable(
                name: trimmedName,
                startDate: startDate,
                endDate: endDate,
                firstWeekParity: firstWeekParity,
                isCurrent: isCurrent || timetables.isEmpty
            )
            if newTimetable.isCurrent {
                for item in timetables { item.isCurrent = false }
            }
            modelContext.insert(newTimetable)
            savedTimetable = newTimetable
        }

        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
            return
        }

        let activeTimetable = timetables.first(where: { $0.isCurrent }) ?? savedTimetable
        Task {
            do {
                try await CalendarExportService.refresh(timetable: savedTimetable, modelContext: modelContext)
                try await CourseNotificationService.refresh(timetable: activeTimetable)
                if presentation == .sheet {
                    dismiss()
                }
            } catch {
                saveError = "课程表已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }
}

struct CourseEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    @Query private var timetables: [Timetable]

    let course: Course?
    let presentation: ScheduleEditorPresentation

    @State private var name: String
    @State private var systemImage: String
    @State private var subject: Subject?
    @State private var saveError: String?

    private let iconOptions = [
        "book.closed", "function", "text.book.closed", "textformat.abc",
        "globe.asia.australia", "atom", "flask", "leaf", "music.note", "paintpalette"
    ]

    init(
        course: Course?,
        presentation: ScheduleEditorPresentation = .sheet
    ) {
        self.course = course
        self.presentation = presentation
        _name = State(initialValue: course?.name ?? "")
        _systemImage = State(initialValue: course?.systemImage ?? "book.closed")
        _subject = State(initialValue: course?.subject)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScheduleEditorContainer(presentation: presentation) {
            Form {
                Section("课程") {
                    TextField("课程名称", text: $name)
                    Picker("图标", selection: $systemImage) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Label(iconName(icon), systemImage: icon)
                                .tag(icon)
                        }
                    }
                    Picker("关联科目", selection: $subject) {
                        Text("无").tag(nil as Subject?)
                        ForEach(subjects) { subject in
                            Text(subject.name).tag(subject as Subject?)
                        }
                    }
                }
            }
            .navigationTitle(course == nil ? "新建课程" : "编辑课程")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if presentation == .sheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isValid)
                }
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
    }

    private func save() {
        guard isValid else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let course {
            course.name = trimmedName
            course.systemImage = systemImage
            course.subject = subject
            course.updatedAt = Date()
        } else {
            modelContext.insert(Course(name: trimmedName, systemImage: systemImage, subject: subject))
        }

        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
            return
        }

        refreshSystemIntegrations()
    }

    private func iconName(_ icon: String) -> String {
        switch icon {
        case "book.closed": "书本"
        case "function": "数学"
        case "text.book.closed": "语文"
        case "textformat.abc": "语言"
        case "globe.asia.australia": "地理"
        case "atom": "物理"
        case "flask": "化学"
        case "leaf": "生物"
        case "music.note": "音乐"
        case "paintpalette": "美术"
        default: icon
        }
    }

    private func refreshSystemIntegrations() {
        let affectedTimetables = course?.schedules.compactMap(\.timetable) ?? []
        let activeTimetable = timetables.first(where: { $0.isCurrent }) ?? timetables.first
        Task {
            do {
                for timetable in uniqueTimetables(affectedTimetables) {
                    try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                }
                try await CourseNotificationService.refresh(timetable: activeTimetable)
                if presentation == .sheet {
                    dismiss()
                }
            } catch {
                saveError = "课程已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private func uniqueTimetables(_ values: [Timetable]) -> [Timetable] {
        var identifiers = Set<PersistentIdentifier>()
        return values.filter { identifiers.insert($0.persistentModelID).inserted }
    }
}

struct ClassPeriodEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let timetable: Timetable
    let period: ClassPeriod?
    let presentation: ScheduleEditorPresentation

    @State private var name: String
    @State private var orderIndex: Int
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var saveError: String?

    init(
        timetable: Timetable,
        period: ClassPeriod?,
        presentation: ScheduleEditorPresentation = .sheet
    ) {
        self.timetable = timetable
        self.period = period
        self.presentation = presentation
        let nextIndex = (timetable.periods.map(\.orderIndex).max() ?? 0) + 1
        _name = State(initialValue: period?.name ?? "第\(nextIndex)节")
        _orderIndex = State(initialValue: period?.orderIndex ?? nextIndex)
        _startTime = State(initialValue: Self.date(for: period?.startMinute ?? 480))
        _endTime = State(initialValue: Self.date(for: period?.endMinute ?? 525))
    }

    private var startMinute: Int { Self.minute(for: startTime) }
    private var endMinute: Int { Self.minute(for: endTime) }

    private var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "请输入节次名称。"
        }
        if endMinute <= startMinute {
            return "结束时间必须晚于开始时间。"
        }
        return nil
    }

    var body: some View {
        ScheduleEditorContainer(presentation: presentation) {
            Form {
                Section("节次") {
                    TextField("名称", text: $name)
                    Stepper("顺序：\(orderIndex)", value: $orderIndex, in: 1...30)
                    DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(period == nil ? "添加节次" : "编辑节次")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if presentation == .sheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(validationMessage != nil)
                }
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
    }

    private func save() {
        guard validationMessage == nil else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let period {
            period.name = trimmedName
            period.orderIndex = orderIndex
            period.startMinute = startMinute
            period.endMinute = endMinute
        } else {
            modelContext.insert(ClassPeriod(
                orderIndex: orderIndex,
                name: trimmedName,
                startMinute: startMinute,
                endMinute: endMinute,
                timetable: timetable
            ))
        }
        timetable.updatedAt = Date()

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
                if presentation == .sheet {
                    dismiss()
                }
            } catch {
                saveError = "节次已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private static func date(for minute: Int) -> Date {
        Calendar.current.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: Date()) ?? Date()
    }

    private static func minute(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

struct CourseScheduleEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.name) private var courses: [Course]

    let timetable: Timetable
    let schedule: CourseSchedule?
    let presentation: ScheduleEditorPresentation

    @State private var course: Course?
    @State private var period: ClassPeriod?
    @State private var weekday: Int
    @State private var repeatRule: CourseRepeatRule
    @State private var teacher: String
    @State private var location: String
    @State private var exportsToCalendar: Bool
    @State private var reminderEnabled: Bool
    @State private var reminderLeadMinutes: Int
    @State private var saveError: String?

    init(
        timetable: Timetable,
        schedule: CourseSchedule?,
        presentation: ScheduleEditorPresentation = .sheet
    ) {
        self.timetable = timetable
        self.schedule = schedule
        self.presentation = presentation
        _course = State(initialValue: schedule?.course)
        _period = State(initialValue: schedule?.period)
        _weekday = State(initialValue: schedule?.weekday ?? 1)
        _repeatRule = State(initialValue: schedule?.repeatRule ?? .weekly)
        _teacher = State(initialValue: schedule?.teacher ?? "")
        _location = State(initialValue: schedule?.location ?? "")
        _exportsToCalendar = State(initialValue: schedule?.exportsToCalendar ?? false)
        _reminderEnabled = State(initialValue: schedule?.reminderEnabled ?? false)
        _reminderLeadMinutes = State(initialValue: schedule?.reminderLeadMinutes ?? 10)
    }

    private var periods: [ClassPeriod] {
        timetable.periods.sorted { lhs, rhs in
            if lhs.startMinute == rhs.startMinute { return lhs.orderIndex < rhs.orderIndex }
            return lhs.startMinute < rhs.startMinute
        }
    }

    private var validationMessage: String? {
        if course == nil { return "请选择课程。" }
        if period == nil { return "请选择节次。" }
        if hasConflict { return "该星期和节次已有时间重叠的课程安排。" }
        return nil
    }

    private var hasConflict: Bool {
        guard let period else { return false }
        return timetable.schedules.contains { other in
            if other.persistentModelID == schedule?.persistentModelID { return false }
            guard other.weekday == weekday,
                  other.period?.persistentModelID == period.persistentModelID
            else { return false }
            return repeatRulesOverlap(other.repeatRule, repeatRule)
        }
    }

    var body: some View {
        ScheduleEditorContainer(presentation: presentation) {
            Form {
                Section("课程安排") {
                    Picker("课程", selection: $course) {
                        Text("请选择").tag(nil as Course?)
                        ForEach(courses) { course in
                            Label(course.name, systemImage: course.systemImage)
                                .tag(course as Course?)
                        }
                    }
                    Picker("星期", selection: $weekday) {
                        ForEach(1...7, id: \.self) { day in
                            Text(day.displayName).tag(day)
                        }
                    }
                    Picker("节次", selection: $period) {
                        Text("请选择").tag(nil as ClassPeriod?)
                        ForEach(periods) { period in
                            Text(period.name).tag(period as ClassPeriod?)
                        }
                    }
                    Picker("重复", selection: $repeatRule) {
                        ForEach(CourseRepeatRule.allCases, id: \.self) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }
                }

                Section("详情") {
                    TextField("教师", text: $teacher)
                    TextField("地点", text: $location)
                }

                Section("提醒") {
                    Toggle("上课与下课提醒", isOn: $reminderEnabled)
                    if reminderEnabled {
                        Picker("提前时间", selection: $reminderLeadMinutes) {
                            Text("准时").tag(0)
                            ForEach([5, 10, 15, 30], id: \.self) { minute in
                                Text("提前 \(minute) 分钟").tag(minute)
                            }
                        }
                    }
                }

                Section("系统日历") {
                    Toggle("导出课程", isOn: $exportsToCalendar)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(schedule == nil ? "添加课程安排" : "编辑课程安排")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if presentation == .sheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await save() }
                    }
                        .disabled(validationMessage != nil)
                }
            }
            .onAppear {
                if course == nil { course = courses.first }
                if period == nil { period = periods.first }
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
    }

    private func save() async {
        guard validationMessage == nil else { return }

        if reminderEnabled {
            do {
                try await CourseNotificationService.ensureAuthorization()
            } catch {
                saveError = error.localizedDescription
                return
            }
        }

        if exportsToCalendar {
            do {
                try await CalendarExportService.ensureAuthorization()
            } catch {
                saveError = error.localizedDescription
                return
            }
        }

        if let schedule {
            schedule.course = course
            schedule.period = period
            schedule.weekday = weekday
            schedule.repeatRule = repeatRule
            schedule.teacher = teacher.trimmingCharacters(in: .whitespacesAndNewlines)
            schedule.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
            schedule.exportsToCalendar = exportsToCalendar
            schedule.reminderEnabled = reminderEnabled
            schedule.reminderLeadMinutes = reminderLeadMinutes
        } else {
            modelContext.insert(CourseSchedule(
                weekday: weekday,
                repeatRule: repeatRule,
                teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
                location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                exportsToCalendar: exportsToCalendar,
                reminderEnabled: reminderEnabled,
                reminderLeadMinutes: reminderLeadMinutes,
                course: course,
                timetable: timetable,
                period: period
            ))
        }
        timetable.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
            return
        }

        do {
            try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
            try await CourseNotificationService.refresh(timetable: timetable)
            if presentation == .sheet {
                dismiss()
            }
        } catch {
            saveError = "课程安排已保存，但系统同步失败：\(error.localizedDescription)"
        }
    }

    private func repeatRulesOverlap(_ lhs: CourseRepeatRule, _ rhs: CourseRepeatRule) -> Bool {
        lhs == .weekly || rhs == .weekly || lhs == rhs
    }
}

struct ScheduleOverrideEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.name) private var courses: [Course]

    let timetable: Timetable
    let scheduleOverride: ScheduleOverride?
    let presentation: ScheduleEditorPresentation

    @State private var date: Date
    @State private var action: ScheduleOverrideAction
    @State private var originalSchedule: CourseSchedule?
    @State private var replacementCourse: Course?
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var saveError: String?

    init(
        timetable: Timetable,
        scheduleOverride: ScheduleOverride?,
        presentation: ScheduleEditorPresentation = .sheet
    ) {
        self.timetable = timetable
        self.scheduleOverride = scheduleOverride
        self.presentation = presentation

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let initialDate = scheduleOverride?.date
            ?? (TimetableResolver.isWithinRange(today, timetable: timetable) ? today : timetable.startDate)
        let initialSchedule = scheduleOverride?.schedule ?? timetable.schedules.first
        let initialStartMinute = scheduleOverride?.replacementStartMinute
            ?? initialSchedule?.period?.startMinute
            ?? 480
        let initialEndMinute = scheduleOverride?.replacementEndMinute
            ?? initialSchedule?.period?.endMinute
            ?? 525

        _date = State(initialValue: initialDate)
        _action = State(initialValue: scheduleOverride?.action ?? .cancel)
        _originalSchedule = State(initialValue: initialSchedule)
        _replacementCourse = State(initialValue: scheduleOverride?.replacementCourse ?? initialSchedule?.course)
        _startTime = State(initialValue: Self.timeDate(for: initialStartMinute))
        _endTime = State(initialValue: Self.timeDate(for: initialEndMinute))
    }

    private var applicableSchedules: [CourseSchedule] {
        timetable.schedules.filter {
            $0.period != nil && TimetableResolver.schedule($0, appliesOn: date, timetable: timetable)
        }.sorted { lhs, rhs in
            if lhs.weekday != rhs.weekday { return lhs.weekday < rhs.weekday }
            return (lhs.period?.startMinute ?? Int.max) < (rhs.period?.startMinute ?? Int.max)
        }
    }

    private var startMinute: Int { Self.minute(for: startTime) }
    private var endMinute: Int { Self.minute(for: endTime) }

    private var validationMessage: String? {
        if !TimetableResolver.isWithinRange(date, timetable: timetable) {
            return "调整日期必须在课程表有效期内。"
        }
        if action != .add && originalSchedule == nil {
            return applicableSchedules.isEmpty ? "该日期没有可调整的原课程。" : "请选择原课程安排。"
        }
        if action != .add,
           let originalSchedule,
           !applicableSchedules.contains(where: {
               $0.persistentModelID == originalSchedule.persistentModelID
           }) {
            return "所选课程在该日期不生效。"
        }
        if action != .cancel && replacementCourse == nil {
            return "请选择调整后的课程。"
        }
        if action != .cancel && endMinute <= startMinute {
            return "结束时间必须晚于开始时间。"
        }
        if hasDuplicateOriginalOverride {
            return "该课程在这一天已有停课或换课设置。"
        }
        if action != .cancel && hasTimeConflict {
            return "调整后的时间与当天其他课程重叠。"
        }
        return nil
    }

    private var hasDuplicateOriginalOverride: Bool {
        guard action != .add, let originalSchedule else { return false }
        return timetable.overrides.contains { item in
            if item.persistentModelID == scheduleOverride?.persistentModelID { return false }
            guard item.action != .add,
                  Calendar.current.isDate(item.date, inSameDayAs: date)
            else { return false }
            return item.schedule?.persistentModelID == originalSchedule.persistentModelID
        }
    }

    private var hasTimeConflict: Bool {
        TimetableResolver.lessons(on: date, timetable: timetable).contains { lesson in
            if lesson.scheduleOverride?.persistentModelID == scheduleOverride?.persistentModelID {
                return false
            }
            if action == .replace,
               lesson.schedule?.persistentModelID == originalSchedule?.persistentModelID {
                return false
            }
            return startMinute < lesson.endMinute && endMinute > lesson.startMinute
        }
    }

    var body: some View {
        ScheduleEditorContainer(presentation: presentation) {
            Form {
                Section("调整") {
                    DatePicker(
                        "日期",
                        selection: $date,
                        in: timetable.startDate...timetable.endDate,
                        displayedComponents: .date
                    )
                    Picker("类型", selection: $action) {
                        ForEach(ScheduleOverrideAction.allCases, id: \.self) { item in
                            Label(item.displayName, systemImage: item.systemImage)
                                .tag(item)
                        }
                    }
                }

                if action != .add {
                    Section("原课程") {
                        Picker("课程安排", selection: $originalSchedule) {
                            Text("请选择").tag(nil as CourseSchedule?)
                            ForEach(applicableSchedules) { schedule in
                                Text(scheduleLabel(schedule)).tag(schedule as CourseSchedule?)
                            }
                        }
                    }
                }

                if action != .cancel {
                    Section(action == .replace ? "调整后" : "临时课程") {
                        Picker("课程", selection: $replacementCourse) {
                            Text("请选择").tag(nil as Course?)
                            ForEach(courses) { course in
                                Label(course.name, systemImage: course.systemImage)
                                    .tag(course as Course?)
                            }
                        }
                        DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(scheduleOverride == nil ? "添加日期调整" : "编辑日期调整")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if presentation == .sheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(validationMessage != nil)
                }
            }
            .onAppear {
                if action != .add,
                   !applicableSchedules.contains(where: {
                       $0.persistentModelID == originalSchedule?.persistentModelID
                   }) {
                    originalSchedule = applicableSchedules.first
                }
                if action == .add, replacementCourse == nil {
                    replacementCourse = courses.first
                }
            }
            .onChange(of: originalSchedule) { _, newValue in
                guard let newValue, action == .replace else { return }
                replacementCourse = newValue.course
                if let period = newValue.period {
                    startTime = Self.timeDate(for: period.startMinute)
                    endTime = Self.timeDate(for: period.endMinute)
                }
            }
            .onChange(of: date) { _, _ in
                guard action != .add else { return }
                if !applicableSchedules.contains(where: {
                    $0.persistentModelID == originalSchedule?.persistentModelID
                }) {
                    originalSchedule = applicableSchedules.first
                }
            }
            .onChange(of: action) { _, newValue in
                if newValue == .replace, let originalSchedule {
                    replacementCourse = originalSchedule.course
                    if let period = originalSchedule.period {
                        startTime = Self.timeDate(for: period.startMinute)
                        endTime = Self.timeDate(for: period.endMinute)
                    }
                } else if newValue == .add, replacementCourse == nil {
                    replacementCourse = courses.first
                } else if newValue != .add,
                          !applicableSchedules.contains(where: {
                              $0.persistentModelID == originalSchedule?.persistentModelID
                          }) {
                    originalSchedule = applicableSchedules.first
                }
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
    }

    private func save() {
        guard validationMessage == nil else { return }
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let schedule = action == .add ? nil : originalSchedule
        let course = action == .cancel ? nil : replacementCourse
        let replacementStart = action == .cancel ? nil : startMinute
        let replacementEnd = action == .cancel ? nil : endMinute

        if let scheduleOverride {
            scheduleOverride.date = normalizedDate
            scheduleOverride.action = action
            scheduleOverride.schedule = schedule
            scheduleOverride.replacementCourse = course
            scheduleOverride.replacementStartMinute = replacementStart
            scheduleOverride.replacementEndMinute = replacementEnd
        } else {
            modelContext.insert(ScheduleOverride(
                date: normalizedDate,
                action: action,
                timetable: timetable,
                schedule: schedule,
                replacementCourse: course,
                replacementStartMinute: replacementStart,
                replacementEndMinute: replacementEnd
            ))
        }
        timetable.updatedAt = Date()

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
                if presentation == .sheet {
                    dismiss()
                }
            } catch {
                saveError = "日期调整已保存，但系统同步失败：\(error.localizedDescription)"
            }
        }
    }

    private func scheduleLabel(_ schedule: CourseSchedule) -> String {
        let courseName = schedule.course?.name ?? "未关联课程"
        let periodName = schedule.period?.name ?? "未关联节次"
        return "\(schedule.weekday.displayName) · \(periodName) · \(courseName) · \(schedule.repeatRule.displayName)"
    }

    private static func timeDate(for minute: Int) -> Date {
        Calendar.current.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: Date()) ?? Date()
    }

    private static func minute(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

struct DayScheduleCopyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let timetable: Timetable

    @State private var sourceWeekday = 1
    @State private var targetWeekday = 2
    @State private var showsOverwriteConfirmation = false
    @State private var saveError: String?

    private var sourceSchedules: [CourseSchedule] {
        timetable.schedules.filter { $0.weekday == sourceWeekday }
    }

    private var targetHasSchedules: Bool {
        timetable.schedules.contains { $0.weekday == targetWeekday }
    }

    private var validationMessage: String? {
        if sourceWeekday == targetWeekday { return "来源和目标不能是同一天。" }
        if sourceSchedules.isEmpty { return "来源日期没有课程安排。" }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("复制安排") {
                    Picker("来源", selection: $sourceWeekday) {
                        ForEach(1...7, id: \.self) { day in
                            Text(day.displayName).tag(day)
                        }
                    }
                    Picker("目标", selection: $targetWeekday) {
                        ForEach(1...7, id: \.self) { day in
                            Text(day.displayName).tag(day)
                        }
                    }
                    LabeledContent("课程数量", value: "\(sourceSchedules.count)")
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("复制一天安排")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("复制") {
                        if targetHasSchedules {
                            showsOverwriteConfirmation = true
                        } else {
                            copySchedules()
                        }
                    }
                    .disabled(validationMessage != nil)
                }
            }
            .confirmationDialog(
                "覆盖目标日期的课程？",
                isPresented: $showsOverwriteConfirmation,
                titleVisibility: .visible
            ) {
                Button("覆盖并复制", role: .destructive) {
                    copySchedules()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("目标日期原有课程安排会被删除。")
            }
            .alert("无法复制", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("好") {}
            } message: {
                Text(saveError ?? "未知错误")
            }
        }
    }

    private func copySchedules() {
        let records = timetable.schedules
            .filter { $0.weekday == targetWeekday }
            .flatMap(\.calendarExportRecords)

        Task {
            do {
                try await CalendarExportService.removeEvents(for: records, modelContext: modelContext)
                try TimetableCopyService.copyDay(
                    from: sourceWeekday,
                    to: targetWeekday,
                    in: timetable,
                    modelContext: modelContext
                )
                try await CalendarExportService.refresh(timetable: timetable, modelContext: modelContext)
                try await CourseNotificationService.refresh(timetable: timetable)
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }
}
