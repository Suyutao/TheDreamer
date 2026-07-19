//
//  TodayView.swift
//  The Dreamer
//
//  「今天」页：展示当天日期、当前课程大卡与分时段课程列表。
//  视觉与信息结构对齐 Figma 339_3103 / 332_3637 / 343_1576，全部使用原生 SwiftUI 控件。
//

import SwiftUI
import SwiftData
import Combine

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Timetable.startDate, order: .reverse) private var timetables: [Timetable]

    /// 每秒刷新一次，用于当前课程进度与剩余时间
    @State private var now = Date()
    @State private var selectedLesson: TodaySelectedLesson?
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - 数据解析

    /// 当前生效课程表：优先取标记为 current 的，否则取日期区间覆盖今天的
    private var activeTimetable: Timetable? {
        if let marked = timetables.first(where: { $0.isCurrent }) {
            return marked
        }
        return timetables.first { TimetableResolver.isWithinRange(now, timetable: $0) }
    }

    private var todayLessons: [ResolvedLesson] {
        guard let timetable = activeTimetable else { return [] }
        return TimetableResolver.lessons(on: now, timetable: timetable)
    }

    private var currentLesson: ResolvedLesson? {
        TimetableResolver.currentLesson(in: todayLessons, now: now)
    }

    /// 除当前课程外的后续课程，按时间分段
    private var upcomingBuckets: [(bucket: DayTimeBucket, lessons: [ResolvedLesson])] {
        let remaining = todayLessons.filter { lesson in
            if let current = currentLesson { return lesson.id != current.id && lesson.endDate > now }
            return lesson.endDate > now
        }
        return DayTimeBucket.allCases.compactMap { bucket in
            let items = remaining.filter { DayTimeBucket.bucket(forStartMinute: $0.startMinute) == bucket }
            return items.isEmpty ? nil : (bucket, items)
        }
    }

    // MARK: - 视图

    var body: some View {
        NavigationStack {
            Group {
                if todayLessons.isEmpty {
                    ContentUnavailableView {
                        Label("今天没有课程", systemImage: "calendar.badge.checkmark")
                    } description: {
                        Text("当前课程表在今天没有安排，去课程表添加吧。")
                    } actions: {
                        NavigationLink(activeTimetable == nil ? "创建课程表" : "管理课程表") {
                            ScheduleManagementView()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if currentLesson == nil && upcomingBuckets.isEmpty {
                    ContentUnavailableView {
                        Label("今日课程已结束", systemImage: "checkmark.circle")
                    } description: {
                        Text("今天的课程已经全部完成。")
                    } actions: {
                        NavigationLink("查看课程表") {
                            ScheduleView()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    lessonList
                }
            }
            .navigationTitle("今天")
            #if !os(visionOS)
            .navigationSubtitle(Text(now, format: .dateTime.year().month().day()))
            #endif
            .sheet(item: $selectedLesson) { selection in
                CourseDetailSheet(lesson: selection.lesson, now: now)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onReceive(ticker) { now = $0 }
    }

    private var lessonList: some View {
        List {
            if let current = currentLesson {
                Section {
                    Button {
                        selectedLesson = TodaySelectedLesson(lesson: current)
                    } label: {
                        CurrentLessonCard(lesson: current, now: now)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }

            ForEach(upcomingBuckets, id: \.bucket.id) { group in
                Section(group.bucket.rawValue) {
                    ForEach(group.lessons) { lesson in
                        Button {
                            selectedLesson = TodaySelectedLesson(lesson: lesson)
                        } label: {
                            LessonRow(lesson: lesson)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct TodaySelectedLesson: Identifiable {
    let id = UUID()
    let lesson: ResolvedLesson
}

// MARK: - 当前课程大卡

private struct CurrentLessonCard: View {
    let lesson: ResolvedLesson
    let now: Date

    private var progress: Double {
        let total = lesson.endDate.timeIntervalSince(lesson.startDate)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(lesson.startDate)
        return min(max(elapsed / total, 0), 1)
    }

    private var remainingText: String {
        let remaining = max(lesson.endDate.timeIntervalSince(now), 0)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("当前")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline) {
                Label(lesson.title, systemImage: lesson.systemImage)
                    .font(.largeTitle.weight(.bold))
                    .labelStyle(.titleAndIcon)
                Spacer()
                Text(remainingText)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .monospacedDigit()
            }

            VStack(spacing: 6) {
                ProgressView(value: progress)
                    .tint(.primary)
                HStack {
                    Text(lesson.startDate, format: .dateTime.hour().minute())
                    Spacer()
                    Text(lesson.endDate, format: .dateTime.hour().minute())
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.secondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

// MARK: - 普通课程行

private struct LessonRow: View {
    let lesson: ResolvedLesson

    var body: some View {
        HStack {
            Label(lesson.title, systemImage: lesson.systemImage)
                .font(.body)
            Spacer()
            Text(lesson.timeRangeText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
