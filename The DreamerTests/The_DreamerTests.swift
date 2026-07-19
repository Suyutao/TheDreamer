//
//  The_DreamerTests.swift
//  The DreamerTests
//
//  Created by 苏宇韬 on 7/23/25.
//

import Foundation
import Testing
import SwiftData
@testable import The_Dreamer

struct The_DreamerTests {

    @Test func currentSchemaCreatesInMemoryContainer() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        #expect(container.schema.entities.count == TheDreamerSchemaV2.models.count)
    }

    @Test @MainActor func timetableResolvesFromPersistentIdentifier() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let timetable = Timetable(
            name: "独立窗口课程表",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30)
        )
        context.insert(timetable)
        try context.save()

        let windowContext = ModelContext(container)
        let resolved = windowContext.model(for: timetable.persistentModelID) as? Timetable

        #expect(resolved?.persistentModelID == timetable.persistentModelID)
        #expect(resolved?.name == "独立窗口课程表")
    }

    @Test func deletingPeriodDeletesScheduleButKeepsCourse() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let timetable = Timetable(name: "测试课表", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 30))
        let course = Course(name: "数学")
        let period = ClassPeriod(orderIndex: 3, name: "第三节", startMinute: 610, endMinute: 655, timetable: timetable)
        let schedule = CourseSchedule(weekday: 2, course: course, timetable: timetable, period: period)

        context.insert(timetable)
        context.insert(course)
        context.insert(period)
        context.insert(schedule)
        try context.save()

        context.delete(period)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Course>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<ClassPeriod>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CourseSchedule>()) == 0)
    }

    @Test func deletingTimetableDeletesArrangementsButKeepsCourse() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let timetable = Timetable(name: "测试课表", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 30))
        let course = Course(name: "数学")
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(weekday: 2, course: course, timetable: timetable, period: period)

        context.insert(timetable)
        context.insert(course)
        context.insert(period)
        context.insert(schedule)
        try context.save()

        context.delete(timetable)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Course>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<Timetable>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ClassPeriod>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CourseSchedule>()) == 0)
    }

    @Test func timetableLessonsAreSortedByStartTime() {
        let calendar = fixedCalendar()
        let monday = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(name: "测试课表", startDate: monday, endDate: date(2026, 8, 31, calendar: calendar))
        let course = Course(name: "数学")
        let early = ClassPeriod(orderIndex: 2, name: "早课", startMinute: 480, endMinute: 525, timetable: timetable)
        let late = ClassPeriod(orderIndex: 1, name: "晚课", startMinute: 600, endMinute: 645, timetable: timetable)
        let lateSchedule = CourseSchedule(weekday: 1, course: course, timetable: timetable, period: late)
        let earlySchedule = CourseSchedule(weekday: 1, course: course, timetable: timetable, period: early)
        timetable.schedules = [lateSchedule, earlySchedule]

        let lessons = TimetableResolver.lessons(on: monday, timetable: timetable, calendar: calendar)

        #expect(lessons.map(\.startMinute) == [480, 600])
    }

    @Test func timetableLessonsRespectDateRange() {
        let calendar = fixedCalendar()
        let monday = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(name: "测试课表", startDate: monday, endDate: date(2026, 7, 12, calendar: calendar))
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(weekday: 1, course: Course(name: "数学"), timetable: timetable, period: period)
        timetable.schedules = [schedule]

        let before = TimetableResolver.lessons(on: date(2026, 6, 29, calendar: calendar), timetable: timetable, calendar: calendar)
        let after = TimetableResolver.lessons(on: date(2026, 7, 13, calendar: calendar), timetable: timetable, calendar: calendar)

        #expect(before.isEmpty)
        #expect(after.isEmpty)
    }

    @Test func timetableLessonsRespectOddAndEvenWeeks() {
        let calendar = fixedCalendar()
        let firstMonday = date(2026, 7, 6, calendar: calendar)
        let secondMonday = date(2026, 7, 13, calendar: calendar)
        let timetable = Timetable(
            name: "测试课表",
            startDate: firstMonday,
            endDate: date(2026, 8, 31, calendar: calendar),
            firstWeekParity: .odd
        )
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(
            weekday: 1,
            repeatRule: .oddWeeks,
            course: Course(name: "数学"),
            timetable: timetable,
            period: period
        )
        timetable.schedules = [schedule]

        #expect(TimetableResolver.lessons(on: firstMonday, timetable: timetable, calendar: calendar).count == 1)
        #expect(TimetableResolver.lessons(on: secondMonday, timetable: timetable, calendar: calendar).isEmpty)
    }

    @Test func scheduleOverrideCancelsOneOccurrence() {
        let calendar = fixedCalendar()
        let monday = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(name: "测试课表", startDate: monday, endDate: date(2026, 8, 31, calendar: calendar))
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(weekday: 1, course: Course(name: "数学"), timetable: timetable, period: period)
        let cancellation = ScheduleOverride(date: monday, action: .cancel, timetable: timetable, schedule: schedule)
        timetable.schedules = [schedule]
        timetable.overrides = [cancellation]

        #expect(TimetableResolver.lessons(on: monday, timetable: timetable, calendar: calendar).isEmpty)
        #expect(TimetableResolver.lessons(on: date(2026, 7, 13, calendar: calendar), timetable: timetable, calendar: calendar).count == 1)
    }

    @Test func scheduleOverrideReplacesCourseAndTime() {
        let calendar = fixedCalendar()
        let monday = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(name: "测试课表", startDate: monday, endDate: date(2026, 8, 31, calendar: calendar))
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(weekday: 1, course: Course(name: "数学"), timetable: timetable, period: period)
        let replacement = ScheduleOverride(
            date: monday,
            action: .replace,
            timetable: timetable,
            schedule: schedule,
            replacementCourse: Course(name: "英语"),
            replacementStartMinute: 600,
            replacementEndMinute: 650
        )
        timetable.schedules = [schedule]
        timetable.overrides = [replacement]

        let lessons = TimetableResolver.lessons(on: monday, timetable: timetable, calendar: calendar)

        #expect(lessons.count == 1)
        #expect(lessons.first?.title == "英语")
        #expect(lessons.first?.startMinute == 600)
        #expect(lessons.first?.endMinute == 650)
        #expect(lessons.first?.isDateOverride == true)
    }

    @Test func scheduleOverrideAddsAndSortsTemporaryCourse() {
        let calendar = fixedCalendar()
        let monday = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(name: "测试课表", startDate: monday, endDate: date(2026, 8, 31, calendar: calendar))
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 600, endMinute: 645, timetable: timetable)
        let schedule = CourseSchedule(weekday: 1, course: Course(name: "数学"), timetable: timetable, period: period)
        let addition = ScheduleOverride(
            date: monday,
            action: .add,
            timetable: timetable,
            replacementCourse: Course(name: "班会"),
            replacementStartMinute: 480,
            replacementEndMinute: 525
        )
        timetable.schedules = [schedule]
        timetable.overrides = [addition]

        let lessons = TimetableResolver.lessons(on: monday, timetable: timetable, calendar: calendar)

        #expect(lessons.map(\.title) == ["班会", "数学"])
        #expect(lessons.map(\.startMinute) == [480, 600])
    }

    @Test @MainActor func copyingTimetableKeepsCourseIdentity() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let timetable = Timetable(name: "原课程表", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 30))
        let course = Course(name: "数学")
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(weekday: 1, course: course, timetable: timetable, period: period)
        context.insert(timetable)
        context.insert(course)
        context.insert(period)
        context.insert(schedule)
        try context.save()

        let copy = try TimetableCopyService.copyTimetable(timetable, in: context)

        #expect(copy.name == "原课程表 副本")
        #expect(copy.periods.count == 1)
        #expect(copy.schedules.count == 1)
        #expect(copy.schedules.first?.course?.persistentModelID == course.persistentModelID)
        #expect(try context.fetchCount(FetchDescriptor<Course>()) == 1)
    }

    @Test @MainActor func copyingDayOverwritesTargetSchedules() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let timetable = Timetable(name: "测试课表", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 30))
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let sourceCourse = Course(name: "数学")
        let targetCourse = Course(name: "英语")
        context.insert(timetable)
        context.insert(period)
        context.insert(sourceCourse)
        context.insert(targetCourse)
        context.insert(CourseSchedule(weekday: 1, course: sourceCourse, timetable: timetable, period: period))
        context.insert(CourseSchedule(weekday: 2, course: targetCourse, timetable: timetable, period: period))
        try context.save()

        try TimetableCopyService.copyDay(from: 1, to: 2, in: timetable, modelContext: context)

        let targetSchedules = timetable.schedules.filter { $0.weekday == 2 }
        #expect(targetSchedules.count == 1)
        #expect(targetSchedules.first?.course?.persistentModelID == sourceCourse.persistentModelID)
    }

    @Test @MainActor func nativeTimetableArchiveRoundTripPreservesBusinessData() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let calendar = fixedCalendar()
        let startDate = date(2026, 7, 6, calendar: calendar)
        let timetable = Timetable(
            name: "高二课程表",
            startDate: startDate,
            endDate: date(2026, 8, 31, calendar: calendar),
            firstWeekParity: .even,
            isCurrent: true
        )
        let course = Course(name: "数学", systemImage: "function")
        let replacementCourse = Course(name: "班会", systemImage: "person.3")
        let period = ClassPeriod(orderIndex: 1, name: "第一节", startMinute: 480, endMinute: 525, timetable: timetable)
        let schedule = CourseSchedule(
            weekday: 1,
            repeatRule: .oddWeeks,
            teacher: "李老师",
            location: "101",
            exportsToCalendar: true,
            reminderEnabled: true,
            reminderLeadMinutes: 15,
            course: course,
            timetable: timetable,
            period: period
        )
        let scheduleOverride = ScheduleOverride(
            date: startDate,
            action: .replace,
            timetable: timetable,
            schedule: schedule,
            replacementCourse: replacementCourse,
            replacementStartMinute: 540,
            replacementEndMinute: 585
        )
        let exportRecord = CalendarExportRecord(
            occurrenceDate: startDate,
            eventIdentifier: "external-event",
            schedule: schedule
        )
        context.insert(timetable)
        context.insert(course)
        context.insert(replacementCourse)
        context.insert(period)
        context.insert(schedule)
        context.insert(scheduleOverride)
        context.insert(exportRecord)
        try context.save()

        let data = try TimetableArchiveService.exportData(for: timetable)
        let imported = try TimetableArchiveService.importData(
            data,
            fileExtension: "json",
            referenceTimetable: timetable,
            existingTimetables: [timetable],
            existingCourses: [course, replacementCourse],
            subjects: [],
            modelContext: context
        )

        #expect(imported.name == "高二课程表 2")
        #expect(imported.firstWeekParity == .even)
        #expect(imported.isCurrent == false)
        #expect(imported.periods.count == 1)
        #expect(imported.schedules.count == 1)
        #expect(imported.schedules.first?.repeatRule == .oddWeeks)
        #expect(imported.schedules.first?.teacher == "李老师")
        #expect(imported.schedules.first?.location == "101")
        #expect(imported.schedules.first?.reminderLeadMinutes == 15)
        #expect(imported.schedules.first?.calendarExportRecords.isEmpty == true)
        #expect(imported.overrides.first?.action == .replace)
        #expect(imported.overrides.first?.replacementCourse?.name == "班会")
    }

    @Test @MainActor func importsBlackboardJSONIncludingTemporaryLessons() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let reference = Timetable(
            name: "当前课程表",
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date().addingTimeInterval(86400 * 30),
            firstWeekParity: .odd,
            isCurrent: true
        )
        context.insert(reference)
        let json = """
        {
          "Monday": [{"Subject":"数学","StartTime":"08:00:00","EndTime":"08:45:00","IsStrongClassOverNotificationEnabled":true}],
          "Temp": [{"Subject":"临时班会","StartTime":"10:00:00","EndTime":"10:40:00"}]
        }
        """.data(using: .utf8)!

        let imported = try TimetableArchiveService.importData(
            json,
            fileExtension: "json",
            referenceTimetable: reference,
            existingTimetables: [reference],
            existingCourses: [],
            subjects: [],
            modelContext: context
        )

        #expect(imported.name == "黑板贴课程表")
        #expect(imported.schedules.count == 1)
        #expect(imported.schedules.first?.weekday == 1)
        #expect(imported.schedules.first?.period?.startMinute == 480)
        #expect(imported.schedules.first?.reminderEnabled == true)
        #expect(imported.overrides.count == 1)
        #expect(imported.overrides.first?.action == .add)
        #expect(imported.overrides.first?.replacementCourse?.name == "临时班会")
    }

    @Test @MainActor func importsCSESWithWeekRuleAndMetadata() throws {
        let container = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let reference = Timetable(
            name: "当前课程表",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 60),
            firstWeekParity: .even,
            isCurrent: true
        )
        context.insert(reference)
        let yaml = """
        version: 1
        subjects:
          - name: 数学
            simplified_name: 数
            teacher: 李梅
            room: "101"
        schedules:
          - name: 星期一
            enable_day: 1
            weeks: odd
            classes:
              - subject: 数学
                start_time: "08:00:00"
                end_time: "09:00:00"
        """.data(using: .utf8)!

        let imported = try TimetableArchiveService.importData(
            yaml,
            fileExtension: "yaml",
            referenceTimetable: reference,
            existingTimetables: [reference],
            existingCourses: [],
            subjects: [],
            modelContext: context
        )

        #expect(imported.name == "CSES 课程表")
        #expect(imported.firstWeekParity == .even)
        #expect(imported.schedules.count == 1)
        #expect(imported.schedules.first?.repeatRule == .oddWeeks)
        #expect(imported.schedules.first?.teacher == "李梅")
        #expect(imported.schedules.first?.location == "101")
        #expect(imported.schedules.first?.period?.endMinute == 540)
    }

    private func fixedCalendar() -> Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

}
