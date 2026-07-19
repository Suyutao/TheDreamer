import Foundation
import SwiftData
import UserNotifications

enum CourseNotificationError: LocalizedError {
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "通知权限未开启。"
        }
    }
}

enum CourseNotificationService {
    private static let identifierPrefix = "the-dreamer.course."
    private static let maximumPendingRequests = 48
    private static let schedulingDays = 90

    static func ensureAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return
        case .notDetermined:
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            if !granted { throw CourseNotificationError.authorizationDenied }
        case .denied:
            throw CourseNotificationError.authorizationDenied
        @unknown default:
            throw CourseNotificationError.authorizationDenied
        }
    }

    static func refresh(timetable: Timetable?, now: Date = Date(), calendar: Calendar = .current) async throws {
        let center = UNUserNotificationCenter.current()
        let hasEnabledReminders = timetable?.schedules.contains { $0.reminderEnabled } == true

        if hasEnabledReminders {
            try await ensureAuthorization()
        }

        let pending = await center.pendingNotificationRequests()
        let existingIdentifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: existingIdentifiers)

        guard let timetable else { return }
        guard hasEnabledReminders else { return }

        let today = calendar.startOfDay(for: now)
        let lastSchedulingDay = calendar.date(byAdding: .day, value: schedulingDays, to: today) ?? today
        let timetableEnd = calendar.startOfDay(for: timetable.endDate)
        let endDate = min(lastSchedulingDay, timetableEnd)
        var day = max(today, calendar.startOfDay(for: timetable.startDate))
        var requestCount = 0

        while day <= endDate && requestCount < maximumPendingRequests {
            let lessons = TimetableResolver.lessons(on: day, timetable: timetable, calendar: calendar)
            for (index, lesson) in lessons.enumerated() {
                guard lesson.reminderEnabled else { continue }
                let fireDate = calendar.date(
                    byAdding: .minute,
                    value: -lesson.reminderLeadMinutes,
                    to: lesson.startDate
                ) ?? lesson.startDate
                if fireDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = lesson.reminderLeadMinutes == 0
                        ? "\(lesson.title)开始了"
                        : "\(lesson.title)即将开始"
                    if lesson.location.isEmpty {
                        content.body = "\(lesson.timeRangeText)"
                    } else {
                        content.body = "\(lesson.timeRangeText) · \(lesson.location)"
                    }
                    content.sound = .default

                    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: identifier(for: lesson, fireDate: fireDate, kind: "begin"),
                        content: content,
                        trigger: trigger
                    )
                    try await center.add(request)
                    requestCount += 1
                }

                if requestCount >= maximumPendingRequests { break }

                guard lesson.endDate > now else { continue }
                let endContent = UNMutableNotificationContent()
                endContent.title = "\(lesson.title)结束了"
                if lessons.indices.contains(index + 1) {
                    let nextLesson = lessons[index + 1]
                    endContent.body = "下一节 \(nextLesson.title) 将于 \(Self.timeText(nextLesson.startDate, calendar: calendar)) 开始"
                } else {
                    endContent.body = "今天的课程已结束"
                }
                endContent.sound = .default

                let endComponents = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: lesson.endDate
                )
                let endTrigger = UNCalendarNotificationTrigger(dateMatching: endComponents, repeats: false)
                let endRequest = UNNotificationRequest(
                    identifier: identifier(for: lesson, fireDate: lesson.endDate, kind: "end"),
                    content: endContent,
                    trigger: endTrigger
                )
                try await center.add(endRequest)
                requestCount += 1

                if requestCount >= maximumPendingRequests { break }
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }
    }

    static func refreshIfAuthorized(timetable: Timetable?, now: Date = Date(), calendar: Calendar = .current) async throws {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            try await refresh(timetable: timetable, now: now, calendar: calendar)
        case .notDetermined, .denied:
            return
        @unknown default:
            return
        }
    }

    private static func identifier(for lesson: ResolvedLesson, fireDate: Date, kind: String) -> String {
        let timestamp = Int(fireDate.timeIntervalSince1970)
        return "\(identifierPrefix)\(lesson.id).\(kind).\(timestamp)"
    }

    private static func timeText(_ date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }
}
