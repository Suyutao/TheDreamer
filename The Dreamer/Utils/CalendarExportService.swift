import EventKit
import Foundation
import SwiftData

enum CalendarExportError: LocalizedError {
    case authorizationDenied
    case defaultCalendarUnavailable

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "日历完整访问权限未开启。"
        case .defaultCalendarUnavailable:
            "没有可写入的默认日历。"
        }
    }
}

@MainActor
enum CalendarExportService {
    private struct DesiredOccurrence {
        let lesson: ResolvedLesson
        let schedule: CourseSchedule
        let day: Date
    }

    static func ensureAuthorization(eventStore: EKEventStore = EKEventStore()) async throws {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            return
        case .notDetermined, .writeOnly:
            let granted = try await eventStore.requestFullAccessToEvents()
            if !granted { throw CalendarExportError.authorizationDenied }
        case .denied, .restricted:
            throw CalendarExportError.authorizationDenied
        case .authorized:
            return
        @unknown default:
            throw CalendarExportError.authorizationDenied
        }
    }

    static func refresh(
        timetable: Timetable,
        modelContext: ModelContext,
        calendar: Calendar = .current
    ) async throws {
        let exportingSchedules = timetable.schedules.filter { $0.exportsToCalendar }
        let allRecords = timetable.schedules.flatMap(\.calendarExportRecords)

        if exportingSchedules.isEmpty {
            try await removeEvents(for: allRecords, modelContext: modelContext)
            return
        }

        let eventStore = EKEventStore()
        try await ensureAuthorization(eventStore: eventStore)
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarExportError.defaultCalendarUnavailable
        }

        let desired = desiredOccurrences(
            timetable: timetable,
            exportingSchedules: exportingSchedules,
            calendar: calendar
        )
        var unmatchedRecords = allRecords

        for occurrence in desired {
            let recordIndex = unmatchedRecords.firstIndex { record in
                record.schedule?.persistentModelID == occurrence.schedule.persistentModelID
                    && calendar.isDate(record.occurrenceDate, inSameDayAs: occurrence.day)
            }

            if let recordIndex {
                let record = unmatchedRecords.remove(at: recordIndex)
                let event = eventStore.event(withIdentifier: record.eventIdentifier)
                    ?? EKEvent(eventStore: eventStore)
                configure(event, for: occurrence.lesson, calendar: defaultCalendar)
                do {
                    try eventStore.save(event, span: .thisEvent, commit: true)
                } catch {
                    let eventError = error
                    record.needsRetry = true
                    try modelContext.save()
                    throw eventError
                }
                record.eventIdentifier = event.eventIdentifier
                record.needsRetry = false
            } else {
                let event = EKEvent(eventStore: eventStore)
                configure(event, for: occurrence.lesson, calendar: defaultCalendar)
                try eventStore.save(event, span: .thisEvent, commit: true)
                modelContext.insert(CalendarExportRecord(
                    occurrenceDate: occurrence.day,
                    eventIdentifier: event.eventIdentifier,
                    schedule: occurrence.schedule
                ))
            }
        }

        for record in unmatchedRecords {
            do {
                if let event = eventStore.event(withIdentifier: record.eventIdentifier) {
                    try eventStore.remove(event, span: .thisEvent, commit: true)
                }
            } catch {
                let eventError = error
                record.needsRetry = true
                try modelContext.save()
                throw eventError
            }
            modelContext.delete(record)
        }

        try modelContext.save()
    }

    static func removeEvents(
        for records: [CalendarExportRecord],
        modelContext: ModelContext
    ) async throws {
        guard !records.isEmpty else { return }
        let eventStore = EKEventStore()
        try await ensureAuthorization(eventStore: eventStore)

        for record in records {
            do {
                if let event = eventStore.event(withIdentifier: record.eventIdentifier) {
                    try eventStore.remove(event, span: .thisEvent, commit: true)
                }
            } catch {
                let eventError = error
                record.needsRetry = true
                try modelContext.save()
                throw eventError
            }
            modelContext.delete(record)
        }
        try modelContext.save()
    }

    private static func desiredOccurrences(
        timetable: Timetable,
        exportingSchedules: [CourseSchedule],
        calendar: Calendar
    ) -> [DesiredOccurrence] {
        let exportingIDs = Set(exportingSchedules.map(\.persistentModelID))
        var day = calendar.startOfDay(for: timetable.startDate)
        let end = calendar.startOfDay(for: timetable.endDate)
        var result: [DesiredOccurrence] = []

        while day <= end {
            for lesson in TimetableResolver.lessons(on: day, timetable: timetable, calendar: calendar) {
                guard let schedule = lesson.schedule,
                      exportingIDs.contains(schedule.persistentModelID)
                else { continue }
                result.append(DesiredOccurrence(lesson: lesson, schedule: schedule, day: day))
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }
        return result
    }

    private static func configure(_ event: EKEvent, for lesson: ResolvedLesson, calendar: EKCalendar) {
        event.calendar = calendar
        event.title = lesson.title
        event.startDate = lesson.startDate
        event.endDate = lesson.endDate
        event.location = lesson.location.isEmpty ? nil : lesson.location
        event.notes = lesson.teacher.isEmpty ? "由 The Dreamer 导出" : "教师：\(lesson.teacher)\n由 The Dreamer 导出"
    }
}
