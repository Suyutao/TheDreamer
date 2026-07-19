import Foundation
import SwiftData

enum WeekParity: String, Codable, CaseIterable {
    case odd
    case even
}

enum CourseRepeatRule: String, Codable, CaseIterable {
    case weekly
    case oddWeeks
    case evenWeeks
}

enum ScheduleOverrideAction: String, Codable, CaseIterable {
    case cancel
    case replace
    case add
}

@Model
final class Course {
    var name: String
    var systemImage: String
    var subject: Subject?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \CourseSchedule.course)
    var schedules: [CourseSchedule] = []

    init(name: String, systemImage: String = "book.closed", subject: Subject? = nil) {
        self.name = name
        self.systemImage = systemImage
        self.subject = subject
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
}

@Model
final class Timetable {
    var name: String
    var startDate: Date
    var endDate: Date
    var firstWeekParityRawValue: String
    var isCurrent: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ClassPeriod.timetable)
    var periods: [ClassPeriod] = []

    @Relationship(deleteRule: .cascade, inverse: \CourseSchedule.timetable)
    var schedules: [CourseSchedule] = []

    @Relationship(deleteRule: .cascade, inverse: \ScheduleOverride.timetable)
    var overrides: [ScheduleOverride] = []

    var firstWeekParity: WeekParity {
        get { WeekParity(rawValue: firstWeekParityRawValue) ?? .odd }
        set { firstWeekParityRawValue = newValue.rawValue }
    }

    init(
        name: String,
        startDate: Date,
        endDate: Date,
        firstWeekParity: WeekParity = .odd,
        isCurrent: Bool = false
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.firstWeekParityRawValue = firstWeekParity.rawValue
        self.isCurrent = isCurrent
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
}

@Model
final class ClassPeriod {
    var orderIndex: Int
    var name: String
    var startMinute: Int
    var endMinute: Int
    var timetable: Timetable?

    @Relationship(deleteRule: .cascade, inverse: \CourseSchedule.period)
    var schedules: [CourseSchedule] = []

    init(orderIndex: Int, name: String, startMinute: Int, endMinute: Int, timetable: Timetable? = nil) {
        self.orderIndex = orderIndex
        self.name = name
        self.startMinute = startMinute
        self.endMinute = endMinute
        self.timetable = timetable
    }
}

@Model
final class CourseSchedule {
    var weekday: Int
    var repeatRuleRawValue: String
    var teacher: String
    var location: String
    var exportsToCalendar: Bool
    var reminderEnabled: Bool
    var reminderLeadMinutes: Int
    var course: Course?
    var timetable: Timetable?
    var period: ClassPeriod?

    @Relationship(deleteRule: .cascade, inverse: \ScheduleOverride.schedule)
    var overrides: [ScheduleOverride] = []

    @Relationship(deleteRule: .cascade, inverse: \CalendarExportRecord.schedule)
    var calendarExportRecords: [CalendarExportRecord] = []

    var repeatRule: CourseRepeatRule {
        get { CourseRepeatRule(rawValue: repeatRuleRawValue) ?? .weekly }
        set { repeatRuleRawValue = newValue.rawValue }
    }

    init(
        weekday: Int,
        repeatRule: CourseRepeatRule = .weekly,
        teacher: String = "",
        location: String = "",
        exportsToCalendar: Bool = false,
        reminderEnabled: Bool = false,
        reminderLeadMinutes: Int = 0,
        course: Course? = nil,
        timetable: Timetable? = nil,
        period: ClassPeriod? = nil
    ) {
        self.weekday = weekday
        self.repeatRuleRawValue = repeatRule.rawValue
        self.teacher = teacher
        self.location = location
        self.exportsToCalendar = exportsToCalendar
        self.reminderEnabled = reminderEnabled
        self.reminderLeadMinutes = reminderLeadMinutes
        self.course = course
        self.timetable = timetable
        self.period = period
    }
}

@Model
final class ScheduleOverride {
    var date: Date
    var actionRawValue: String
    var replacementStartMinute: Int?
    var replacementEndMinute: Int?
    var timetable: Timetable?
    var schedule: CourseSchedule?
    var replacementCourse: Course?

    var action: ScheduleOverrideAction {
        get { ScheduleOverrideAction(rawValue: actionRawValue) ?? .cancel }
        set { actionRawValue = newValue.rawValue }
    }

    init(
        date: Date,
        action: ScheduleOverrideAction,
        timetable: Timetable? = nil,
        schedule: CourseSchedule? = nil,
        replacementCourse: Course? = nil,
        replacementStartMinute: Int? = nil,
        replacementEndMinute: Int? = nil
    ) {
        self.date = date
        self.actionRawValue = action.rawValue
        self.timetable = timetable
        self.schedule = schedule
        self.replacementCourse = replacementCourse
        self.replacementStartMinute = replacementStartMinute
        self.replacementEndMinute = replacementEndMinute
    }
}

@Model
final class CalendarExportRecord {
    var occurrenceDate: Date
    var eventIdentifier: String
    var needsRetry: Bool
    var schedule: CourseSchedule?

    init(
        occurrenceDate: Date,
        eventIdentifier: String,
        needsRetry: Bool = false,
        schedule: CourseSchedule? = nil
    ) {
        self.occurrenceDate = occurrenceDate
        self.eventIdentifier = eventIdentifier
        self.needsRetry = needsRetry
        self.schedule = schedule
    }
}
