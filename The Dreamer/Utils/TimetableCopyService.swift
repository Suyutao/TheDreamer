import Foundation
import SwiftData

enum TimetableCopyError: LocalizedError {
    case invalidWeekday
    case sameWeekday
    case emptySourceDay

    var errorDescription: String? {
        switch self {
        case .invalidWeekday:
            "星期参数无效。"
        case .sameWeekday:
            "来源和目标不能是同一天。"
        case .emptySourceDay:
            "来源日期没有课程安排。"
        }
    }
}

@MainActor
enum TimetableCopyService {
    static func copyTimetable(_ source: Timetable, in modelContext: ModelContext) throws -> Timetable {
        let copy = Timetable(
            name: "\(source.name) 副本",
            startDate: source.startDate,
            endDate: source.endDate,
            firstWeekParity: source.firstWeekParity,
            isCurrent: false
        )
        modelContext.insert(copy)

        var periodMap: [PersistentIdentifier: ClassPeriod] = [:]
        for period in source.periods {
            let periodCopy = ClassPeriod(
                orderIndex: period.orderIndex,
                name: period.name,
                startMinute: period.startMinute,
                endMinute: period.endMinute,
                timetable: copy
            )
            modelContext.insert(periodCopy)
            periodMap[period.persistentModelID] = periodCopy
        }

        for schedule in source.schedules {
            guard let sourcePeriod = schedule.period,
                  let copiedPeriod = periodMap[sourcePeriod.persistentModelID]
            else { continue }

            modelContext.insert(CourseSchedule(
                weekday: schedule.weekday,
                repeatRule: schedule.repeatRule,
                teacher: schedule.teacher,
                location: schedule.location,
                exportsToCalendar: false,
                reminderEnabled: schedule.reminderEnabled,
                reminderLeadMinutes: schedule.reminderLeadMinutes,
                course: schedule.course,
                timetable: copy,
                period: copiedPeriod
            ))
        }

        try modelContext.save()
        return copy
    }

    static func copyDay(
        from sourceWeekday: Int,
        to targetWeekday: Int,
        in timetable: Timetable,
        modelContext: ModelContext
    ) throws {
        guard (1...7).contains(sourceWeekday), (1...7).contains(targetWeekday) else {
            throw TimetableCopyError.invalidWeekday
        }
        guard sourceWeekday != targetWeekday else {
            throw TimetableCopyError.sameWeekday
        }

        let sourceSchedules = timetable.schedules.filter { $0.weekday == sourceWeekday }
        guard !sourceSchedules.isEmpty else {
            throw TimetableCopyError.emptySourceDay
        }

        let targetSchedules = timetable.schedules.filter { $0.weekday == targetWeekday }
        for schedule in targetSchedules {
            modelContext.delete(schedule)
        }

        for schedule in sourceSchedules {
            modelContext.insert(CourseSchedule(
                weekday: targetWeekday,
                repeatRule: schedule.repeatRule,
                teacher: schedule.teacher,
                location: schedule.location,
                exportsToCalendar: false,
                reminderEnabled: schedule.reminderEnabled,
                reminderLeadMinutes: schedule.reminderLeadMinutes,
                course: schedule.course,
                timetable: timetable,
                period: schedule.period
            ))
        }

        timetable.updatedAt = Date()
        try modelContext.save()
    }
}
