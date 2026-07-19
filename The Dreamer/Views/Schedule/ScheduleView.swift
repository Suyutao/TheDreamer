import SwiftUI
import SwiftData
import Combine

struct ScheduleView: View {
    @Query(sort: \Timetable.startDate, order: .reverse) private var timetables: [Timetable]

    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var selectedDayOffset = 0
    @State private var selectedLesson: SelectedScheduleLesson?
    @State private var now = Date()

    private let ticker = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    private let dayOffsets = Array(-730...730)

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if proxy.size.width >= 900 {
                    weekOverview
                } else {
                    dayOverview
                }
            }
            .navigationTitle("课程表")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("今天") {
                        selectDate(Date())
                    }

                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: selectedDate) { _, newValue in
                            selectedDayOffset = dayOffset(for: newValue)
                        }

                    NavigationLink {
                        ScheduleManagementView()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .help("管理课程与课程表")
                }
            }
            .sheet(item: $selectedLesson) { selection in
                CourseDetailSheet(lesson: selection.lesson, now: now)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onReceive(ticker) { now = $0 }
    }

    private var dayOverview: some View {
        VStack(spacing: 0) {
            WeekDateStrip(selectedDate: $selectedDate)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            #if os(iOS)
            TabView(selection: $selectedDayOffset) {
                ForEach(dayOffsets, id: \.self) { offset in
                    DaySchedulePage(
                        date: date(for: offset),
                        timetable: activeTimetable,
                        selectedLesson: $selectedLesson
                    )
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedDayOffset) { _, newValue in
                selectedDate = date(for: newValue)
            }
            #else
            DaySchedulePage(
                date: selectedDate,
                timetable: activeTimetable,
                selectedLesson: $selectedLesson
            )
            #endif
        }
    }

    private var weekOverview: some View {
        let dates = weekDates(containing: selectedDate)

        return Group {
            if let timetable = activeTimetable {
                ScrollView(.vertical) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(dates, id: \.self) { date in
                            WideDayColumn(
                                date: date,
                                timetable: timetable,
                                selectedDate: $selectedDate,
                                selectedLesson: $selectedLesson
                            )
                            .frame(maxWidth: .infinity, alignment: .top)
                            .overlay(alignment: .leading) {
                                if date != dates.first {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                }
            } else {
                MissingTimetableView()
            }
        }
    }

    private var activeTimetable: Timetable? {
        if let current = timetables.first(where: {
            $0.isCurrent && TimetableResolver.isWithinRange(selectedDate, timetable: $0)
        }) {
            return current
        }
        return timetables.first { TimetableResolver.isWithinRange(selectedDate, timetable: $0) }
    }

    private func selectDate(_ date: Date) {
        let normalized = Calendar.current.startOfDay(for: date)
        selectedDate = normalized
        selectedDayOffset = dayOffset(for: normalized)
    }

    private func dayOffset(for date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return min(max(calendar.dateComponents([.day], from: today, to: target).day ?? 0, -730), 730)
    }

    private func date(for offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    }

    private func weekDates(containing date: Date) -> [Date] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let offset = TimetableResolver.isoWeekday(for: day, calendar: calendar) - 1
        guard let monday = calendar.date(byAdding: .day, value: -offset, to: day) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

}

private struct WeekDateStrip: View {
    @Binding var selectedDate: Date

    private var dates: [Date] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)
        let offset = TimetableResolver.isoWeekday(for: day, calendar: calendar) - 1
        guard let monday = calendar.date(byAdding: .day, value: -offset, to: day) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(dates, id: \.self) { date in
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                Button {
                    selectedDate = date
                } label: {
                    VStack(spacing: 6) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(date, format: .dateTime.day())
                            .font(.body.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color.white : Color.primary)
                            .frame(width: 34, height: 34)
                            .background(isSelected ? Color.accentColor : Color.clear, in: Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(date, format: .dateTime.month().day().weekday(.wide)))
            }
        }
    }
}

private struct DaySchedulePage: View {
    let date: Date
    let timetable: Timetable?
    @Binding var selectedLesson: SelectedScheduleLesson?

    private var lessons: [ResolvedLesson] {
        guard let timetable else { return [] }
        return TimetableResolver.lessons(on: date, timetable: timetable)
    }

    private var buckets: [(bucket: DayTimeBucket, lessons: [ResolvedLesson])] {
        DayTimeBucket.allCases.compactMap { bucket in
            let matches = lessons.filter { DayTimeBucket.bucket(forStartMinute: $0.startMinute) == bucket }
            return matches.isEmpty ? nil : (bucket, matches)
        }
    }

    var body: some View {
        if timetable == nil {
            MissingTimetableView()
        } else if lessons.isEmpty {
            ContentUnavailableView {
                Label("当天没有课程", systemImage: "calendar.badge.checkmark")
            } description: {
                Text(date, format: .dateTime.year().month().day().weekday(.wide))
            } actions: {
                NavigationLink("管理课程表") {
                    ScheduleManagementView()
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            List {
                ForEach(buckets, id: \.bucket.id) { group in
                    Section(group.bucket.rawValue) {
                        ForEach(group.lessons) { lesson in
                            Button {
                                selectedLesson = SelectedScheduleLesson(lesson: lesson)
                            } label: {
                                ScheduleLessonRow(lesson: lesson)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            #if os(macOS)
            .listStyle(.inset)
            #else
            .listStyle(.insetGrouped)
            #endif
        }
    }
}

private struct ScheduleLessonRow: View {
    let lesson: ResolvedLesson

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: lesson.systemImage)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.body.weight(.medium))

                HStack(spacing: 8) {
                    Text(lesson.timeRangeText)
                    if !lesson.teacher.isEmpty {
                        Text(lesson.teacher)
                    }
                    if !lesson.location.isEmpty {
                        Text(lesson.location)
                    }
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

private struct WideDayColumn: View {
    let date: Date
    let timetable: Timetable
    @Binding var selectedDate: Date
    @Binding var selectedLesson: SelectedScheduleLesson?

    private var lessons: [ResolvedLesson] {
        TimetableResolver.lessons(on: date, timetable: timetable)
    }

    var body: some View {
        VStack(spacing: 8) {
            Button {
                selectedDate = Calendar.current.startOfDay(for: date)
            } label: {
                VStack(spacing: 4) {
                    Text(date, format: .dateTime.weekday(.abbreviated))
                        .font(.caption)
                    Text(date, format: .dateTime.day())
                        .font(.headline)
                }
                .foregroundStyle(
                    Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        ? Color.accentColor
                        : Color.primary
                )
                .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.plain)

            Divider()

            if lessons.isEmpty {
                Text("无课程")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, minHeight: 56)
            } else {
                ForEach(lessons) { lesson in
                    Button {
                        selectedLesson = SelectedScheduleLesson(lesson: lesson)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 4) {
                                Image(systemName: lesson.systemImage)
                                Text(lesson.title)
                                    .font(.caption.weight(.semibold))
                                    .lineLimit(2)
                                Spacer(minLength: 0)
                            }
                            Text(lesson.timeRangeText)
                                .font(.caption2)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                            if !lesson.location.isEmpty {
                                Text(lesson.location)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            if lesson.isDateOverride {
                                Label("调整", systemImage: "calendar.badge.clock")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, minHeight: 68, alignment: .topLeading)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 6)
    }
}

private struct MissingTimetableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("还没有课程表", systemImage: "calendar.badge.plus")
        } description: {
            Text("创建课程表并添加节次与课程安排。")
        } actions: {
            NavigationLink("管理课程表") {
                ScheduleManagementView()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct SelectedScheduleLesson: Identifiable {
    let id = UUID()
    let lesson: ResolvedLesson
}

struct CourseDetailSheet: View {
    let lesson: ResolvedLesson
    let now: Date

    private var progress: Double {
        let total = lesson.endDate.timeIntervalSince(lesson.startDate)
        guard total > 0 else { return 0 }
        return min(max(now.timeIntervalSince(lesson.startDate) / total, 0), 1)
    }

    private var remainingText: String? {
        guard now >= lesson.startDate, now < lesson.endDate else { return nil }
        let remaining = max(lesson.endDate.timeIntervalSince(now), 0)
        return "\(Int(remaining) / 60) 分钟"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(lesson.title, systemImage: lesson.systemImage)
                        .font(.title2.weight(.bold))
                }

                Section("时间") {
                    LabeledContent("日期") {
                        Text(lesson.startDate, format: .dateTime.year().month().day().weekday(.wide))
                    }
                    LabeledContent("时间段", value: lesson.timeRangeText)
                    if let remainingText {
                        LabeledContent("剩余时间", value: remainingText)
                        ProgressView(value: progress)
                            .tint(.accentColor)
                    }
                }

                if !lesson.teacher.isEmpty || !lesson.location.isEmpty {
                    Section("详情") {
                        if !lesson.teacher.isEmpty {
                            LabeledContent("教师", value: lesson.teacher)
                        }
                        if !lesson.location.isEmpty {
                            LabeledContent("地点", value: lesson.location)
                        }
                    }
                }

                if lesson.isDateOverride {
                    Section {
                        Label("指定日期调整", systemImage: "calendar.badge.clock")
                    }
                }
            }
            .navigationTitle("课程详情")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
