//
//  TimetableResolver.swift
//  The Dreamer
//
//  课程表解析工具：根据当前生效课程表，把某一天的课程安排解析为可展示的课程实例。
//  今天页（TodayView）与课程表页（ScheduleView）共用此逻辑。
//

import Foundation
import SwiftData

// MARK: - 解析结果模型

/// 某一天已解析出的一节课
struct ResolvedLesson: Identifiable {
    let id: String
    let schedule: CourseSchedule?
    let scheduleOverride: ScheduleOverride?
    let course: Course?
    let period: ClassPeriod?
    let startMinute: Int
    let endMinute: Int
    let startDate: Date
    let endDate: Date

    var title: String {
        course?.name ?? period?.name ?? "课程"
    }

    var systemImage: String {
        course?.systemImage ?? "book.closed"
    }

    var timeRangeText: String {
        "\(Self.minuteText(startMinute))-\(Self.minuteText(endMinute))"
    }

    var teacher: String {
        schedule?.teacher ?? ""
    }

    var location: String {
        schedule?.location ?? ""
    }

    var reminderEnabled: Bool {
        schedule?.reminderEnabled ?? false
    }

    var reminderLeadMinutes: Int {
        schedule?.reminderLeadMinutes ?? 0
    }

    var isDateOverride: Bool {
        scheduleOverride != nil
    }

    private static func minuteText(_ minute: Int) -> String {
        String(format: "%02d:%02d", minute / 60, minute % 60)
    }
}

// MARK: - 一天中的时间分段（对齐 Figma 分组）

enum DayTimeBucket: String, CaseIterable, Identifiable {
    case morning = "上午"
    case noon = "中午"
    case afternoon = "下午"
    case evening = "晚修"

    var id: String { rawValue }

    /// 根据起始分钟归入分段
    static func bucket(forStartMinute minute: Int) -> DayTimeBucket {
        switch minute {
        case ..<720: return .morning        // < 12:00
        case 720..<810: return .noon        // 12:00 - 13:30
        case 810..<1080: return .afternoon  // 13:30 - 18:00
        default: return .evening            // >= 18:00
        }
    }
}

// MARK: - 解析器

enum TimetableResolver {

    /// 将 Calendar 的 weekday（1=周日…7=周六）转换为 ISO 习惯（1=周一…7=周日）
    static func isoWeekday(for date: Date, calendar: Calendar = .current) -> Int {
        let w = calendar.component(.weekday, from: date)
        return w == 1 ? 7 : w - 1
    }

    /// 判断目标日期落在课程表生效区间内
    static func isWithinRange(_ date: Date, timetable: Timetable, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: timetable.startDate)
        let end = calendar.startOfDay(for: timetable.endDate)
        return day >= start && day <= end
    }

    /// 计算目标日期所在周相对课程表首周的单双周
    static func weekParity(for date: Date, timetable: Timetable, calendar: Calendar = .current) -> WeekParity {
        let startWeek = calendar.dateInterval(of: .weekOfYear, for: timetable.startDate)?.start
            ?? calendar.startOfDay(for: timetable.startDate)
        let targetWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start
            ?? calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startWeek, to: targetWeek).day ?? 0
        let weekIndex = days / 7
        let isFirstParity = weekIndex % 2 == 0
        if isFirstParity { return timetable.firstWeekParity }
        return timetable.firstWeekParity == .odd ? .even : .odd
    }

    /// 判断某条课程安排是否在目标日期生效
    static func schedule(_ s: CourseSchedule, appliesOn date: Date, timetable: Timetable, calendar: Calendar = .current) -> Bool {
        guard s.weekday == isoWeekday(for: date, calendar: calendar) else { return false }
        switch s.repeatRule {
        case .weekly:
            return true
        case .oddWeeks:
            return weekParity(for: date, timetable: timetable, calendar: calendar) == .odd
        case .evenWeeks:
            return weekParity(for: date, timetable: timetable, calendar: calendar) == .even
        }
    }

    /// 解析目标日期的全部课程，按开始时间排序
    static func lessons(on date: Date, timetable: Timetable, calendar: Calendar = .current) -> [ResolvedLesson] {
        guard isWithinRange(date, timetable: timetable, calendar: calendar) else { return [] }
        let dayStart = calendar.startOfDay(for: date)

        var lessons: [ResolvedLesson] = timetable.schedules.compactMap { schedule in
            guard let period = schedule.period,
                  self.schedule(schedule, appliesOn: date, timetable: timetable, calendar: calendar)
            else { return nil }

            let start = calendar.date(byAdding: .minute, value: period.startMinute, to: dayStart) ?? dayStart
            let end = calendar.date(byAdding: .minute, value: period.endMinute, to: dayStart) ?? dayStart
            return ResolvedLesson(
                id: occurrenceID(for: schedule, dayStart: dayStart),
                schedule: schedule,
                scheduleOverride: nil,
                course: schedule.course,
                period: period,
                startMinute: period.startMinute,
                endMinute: period.endMinute,
                startDate: start,
                endDate: end
            )
        }

        let overrides = timetable.overrides.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        for override in overrides {
            switch override.action {
            case .cancel:
                guard let schedule = override.schedule else { continue }
                lessons.removeAll { $0.schedule?.persistentModelID == schedule.persistentModelID }
            case .replace:
                guard let schedule = override.schedule,
                      let index = lessons.firstIndex(where: {
                          $0.schedule?.persistentModelID == schedule.persistentModelID
                      })
                else { continue }

                let original = lessons.remove(at: index)
                let startMinute = override.replacementStartMinute ?? original.startMinute
                let endMinute = override.replacementEndMinute ?? original.endMinute
                guard endMinute > startMinute else { continue }
                let start = calendar.date(byAdding: .minute, value: startMinute, to: dayStart) ?? dayStart
                let end = calendar.date(byAdding: .minute, value: endMinute, to: dayStart) ?? dayStart
                lessons.append(ResolvedLesson(
                    id: occurrenceID(for: override, dayStart: dayStart),
                    schedule: schedule,
                    scheduleOverride: override,
                    course: override.replacementCourse ?? original.course,
                    period: original.period,
                    startMinute: startMinute,
                    endMinute: endMinute,
                    startDate: start,
                    endDate: end
                ))
            case .add:
                guard let course = override.replacementCourse,
                      let startMinute = override.replacementStartMinute,
                      let endMinute = override.replacementEndMinute,
                      endMinute > startMinute
                else { continue }

                let start = calendar.date(byAdding: .minute, value: startMinute, to: dayStart) ?? dayStart
                let end = calendar.date(byAdding: .minute, value: endMinute, to: dayStart) ?? dayStart
                lessons.append(ResolvedLesson(
                    id: occurrenceID(for: override, dayStart: dayStart),
                    schedule: override.schedule,
                    scheduleOverride: override,
                    course: course,
                    period: override.schedule?.period,
                    startMinute: startMinute,
                    endMinute: endMinute,
                    startDate: start,
                    endDate: end
                ))
            }
        }

        return lessons.sorted {
            if $0.startMinute == $1.startMinute { return $0.endMinute < $1.endMinute }
            return $0.startMinute < $1.startMinute
        }
    }

    /// 当前正在进行的课程
    static func currentLesson(in lessons: [ResolvedLesson], now: Date = Date()) -> ResolvedLesson? {
        lessons.first { now >= $0.startDate && now < $0.endDate }
    }

    /// 下一节即将开始的课程
    static func nextLesson(in lessons: [ResolvedLesson], now: Date = Date()) -> ResolvedLesson? {
        lessons.first { $0.startDate > now }
    }

    private static func occurrenceID(for schedule: CourseSchedule, dayStart: Date) -> String {
        "schedule:\(String(describing: schedule.persistentModelID)):\(Int(dayStart.timeIntervalSince1970))"
    }

    private static func occurrenceID(for override: ScheduleOverride, dayStart: Date) -> String {
        "override:\(String(describing: override.persistentModelID)):\(Int(dayStart.timeIntervalSince1970))"
    }
}
