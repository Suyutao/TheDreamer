import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import Yams

enum TimetableArchiveError: LocalizedError {
    case emptyFile
    case unsupportedFormat
    case unsupportedVersion(Int)
    case invalidTime(String)
    case missingReferenceTimetable

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            "课程表文件没有内容。"
        case .unsupportedFormat:
            "无法识别该课程表文件。"
        case .unsupportedVersion(let version):
            "暂不支持版本 \(version) 的课程表归档。"
        case .invalidTime(let value):
            "无法识别课程时间：\(value)"
        case .missingReferenceTimetable:
            "导入黑板贴或 CSES 课程表前，需要先创建一个包含日期范围的课程表。"
        }
    }
}

struct TimetableArchiveDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw TimetableArchiveError.emptyFile
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

@MainActor
enum TimetableArchiveService {
    static func exportData(for timetable: Timetable) throws -> Data {
        let archive = archive(for: timetable)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(archive)
    }

    static func importData(
        _ data: Data,
        fileExtension: String,
        referenceTimetable: Timetable?,
        existingTimetables: [Timetable],
        existingCourses: [Course],
        subjects: [Subject],
        modelContext: ModelContext
    ) throws -> Timetable {
        guard !data.isEmpty else { throw TimetableArchiveError.emptyFile }

        let importedArchive: TimetableArchive
        if ["yaml", "yml"].contains(fileExtension.lowercased()) {
            guard let referenceTimetable else { throw TimetableArchiveError.missingReferenceTimetable }
            importedArchive = try archiveFromCSES(data, referenceTimetable: referenceTimetable)
        } else {
            do {
                importedArchive = try decodeNativeArchive(data)
            } catch TimetableArchiveError.unsupportedVersion(let version) {
                throw TimetableArchiveError.unsupportedVersion(version)
            } catch {
                guard let blackboardArchive = try? archiveFromBlackboard(
                    data,
                    referenceTimetable: referenceTimetable
                ) else {
                    throw TimetableArchiveError.unsupportedFormat
                }
                importedArchive = blackboardArchive
            }
        }

        return try insert(
            importedArchive,
            existingTimetables: existingTimetables,
            existingCourses: existingCourses,
            subjects: subjects,
            modelContext: modelContext
        )
    }

    private static func archive(for timetable: Timetable) -> TimetableArchive {
        let scheduleCourses = timetable.schedules.compactMap(\.course)
        let overrideCourses = timetable.overrides.compactMap(\.replacementCourse)
        let courses = uniqueModels(scheduleCourses + overrideCourses)
        let periods = timetable.periods.sorted {
            if $0.startMinute == $1.startMinute { return $0.orderIndex < $1.orderIndex }
            return $0.startMinute < $1.startMinute
        }
        let schedules = timetable.schedules.sorted {
            if $0.weekday == $1.weekday {
                return ($0.period?.startMinute ?? Int.max) < ($1.period?.startMinute ?? Int.max)
            }
            return $0.weekday < $1.weekday
        }
        let courseIDs = Dictionary(uniqueKeysWithValues: courses.map { ($0.persistentModelID, UUID()) })
        let periodIDs = Dictionary(uniqueKeysWithValues: periods.map { ($0.persistentModelID, UUID()) })
        let scheduleIDs = Dictionary(uniqueKeysWithValues: schedules.map { ($0.persistentModelID, UUID()) })

        return TimetableArchive(
            version: 1,
            name: timetable.name,
            startDate: timetable.startDate,
            endDate: timetable.endDate,
            firstWeekParity: timetable.firstWeekParity.rawValue,
            courses: courses.compactMap { course in
                guard let id = courseIDs[course.persistentModelID] else { return nil }
                return ArchivedCourse(
                    id: id,
                    name: course.name,
                    systemImage: course.systemImage,
                    subjectName: course.subject?.name
                )
            },
            periods: periods.compactMap { period in
                guard let id = periodIDs[period.persistentModelID] else { return nil }
                return ArchivedPeriod(
                    id: id,
                    orderIndex: period.orderIndex,
                    name: period.name,
                    startMinute: period.startMinute,
                    endMinute: period.endMinute
                )
            },
            schedules: schedules.compactMap { schedule in
                guard let id = scheduleIDs[schedule.persistentModelID],
                      let course = schedule.course,
                      let period = schedule.period,
                      let courseID = courseIDs[course.persistentModelID],
                      let periodID = periodIDs[period.persistentModelID]
                else { return nil }
                return ArchivedSchedule(
                    id: id,
                    weekday: schedule.weekday,
                    repeatRule: schedule.repeatRule.rawValue,
                    teacher: schedule.teacher,
                    location: schedule.location,
                    exportsToCalendar: schedule.exportsToCalendar,
                    reminderEnabled: schedule.reminderEnabled,
                    reminderLeadMinutes: schedule.reminderLeadMinutes,
                    courseID: courseID,
                    periodID: periodID
                )
            },
            overrides: timetable.overrides.compactMap { item in
                let scheduleID = item.schedule.flatMap { scheduleIDs[$0.persistentModelID] }
                let replacementCourseID = item.replacementCourse.flatMap { courseIDs[$0.persistentModelID] }
                return ArchivedOverride(
                    date: item.date,
                    action: item.action.rawValue,
                    scheduleID: scheduleID,
                    replacementCourseID: replacementCourseID,
                    replacementStartMinute: item.replacementStartMinute,
                    replacementEndMinute: item.replacementEndMinute
                )
            }
        )
    }

    private static func decodeNativeArchive(_ data: Data) throws -> TimetableArchive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let archive = try decoder.decode(TimetableArchive.self, from: data)
        guard archive.version == 1 else { throw TimetableArchiveError.unsupportedVersion(archive.version) }
        return archive
    }

    private static func archiveFromBlackboard(
        _ data: Data,
        referenceTimetable: Timetable?
    ) throws -> TimetableArchive {
        guard let referenceTimetable else { throw TimetableArchiveError.missingReferenceTimetable }
        let source = try JSONDecoder().decode(BlackboardTimetable.self, from: data)
        let days = [
            (1, source.monday), (2, source.tuesday), (3, source.wednesday),
            (4, source.thursday), (5, source.friday), (6, source.saturday), (7, source.sunday)
        ]
        var builder = ImportedArchiveBuilder(
            name: "黑板贴课程表",
            startDate: referenceTimetable.startDate,
            endDate: referenceTimetable.endDate,
            firstWeekParity: referenceTimetable.firstWeekParity
        )

        for (weekday, lessons) in days {
            for lesson in lessons {
                let startMinute = try minute(from: lesson.startTime)
                let endMinute = try minute(from: lesson.endTime)
                guard endMinute > startMinute else { throw TimetableArchiveError.invalidTime(lesson.endTime) }
                builder.addSchedule(
                    courseName: lesson.subject,
                    systemImage: "book.closed",
                    weekday: weekday,
                    repeatRule: .weekly,
                    teacher: "",
                    location: "",
                    startMinute: startMinute,
                    endMinute: endMinute,
                    reminderEnabled: lesson.strongClassOverNotificationEnabled
                )
            }
        }

        let temporaryDate = TimetableResolver.isWithinRange(Date(), timetable: referenceTimetable)
            ? Calendar.current.startOfDay(for: Date())
            : Calendar.current.startOfDay(for: referenceTimetable.startDate)
        for lesson in source.temp {
            let startMinute = try minute(from: lesson.startTime)
            let endMinute = try minute(from: lesson.endTime)
            guard endMinute > startMinute else { throw TimetableArchiveError.invalidTime(lesson.endTime) }
            builder.addTemporaryLesson(
                courseName: lesson.subject,
                date: temporaryDate,
                startMinute: startMinute,
                endMinute: endMinute
            )
        }
        return builder.archive
    }

    private static func archiveFromCSES(
        _ data: Data,
        referenceTimetable: Timetable
    ) throws -> TimetableArchive {
        guard let text = String(data: data, encoding: .utf8) else {
            throw TimetableArchiveError.unsupportedFormat
        }
        let profile = try YAMLDecoder().decode(CSESProfile.self, from: text)
        guard profile.version == 1 else {
            throw TimetableArchiveError.unsupportedVersion(profile.version)
        }
        var metadata: [String: CSESSubject] = [:]
        for subject in profile.subjects where metadata[subject.name] == nil {
            metadata[subject.name] = subject
        }
        var builder = ImportedArchiveBuilder(
            name: "CSES 课程表",
            startDate: referenceTimetable.startDate,
            endDate: referenceTimetable.endDate,
            firstWeekParity: referenceTimetable.firstWeekParity
        )

        for schedule in profile.schedules {
            guard (1...7).contains(schedule.enableDay) else { continue }
            let repeatRule: CourseRepeatRule
            switch schedule.weeks.lowercased() {
            case "odd": repeatRule = .oddWeeks
            case "even": repeatRule = .evenWeeks
            default: repeatRule = .weekly
            }

            for lesson in schedule.classes {
                let subject = metadata[lesson.subject]
                let startMinute = try minute(from: lesson.startTime)
                let endMinute = try minute(from: lesson.endTime)
                guard endMinute > startMinute else { throw TimetableArchiveError.invalidTime(lesson.endTime) }
                builder.addSchedule(
                    courseName: lesson.subject,
                    systemImage: "book.closed",
                    weekday: schedule.enableDay,
                    repeatRule: repeatRule,
                    teacher: subject?.teacher ?? "",
                    location: subject?.room ?? "",
                    startMinute: startMinute,
                    endMinute: endMinute,
                    reminderEnabled: false
                )
            }
        }
        return builder.archive
    }

    private static func insert(
        _ archive: TimetableArchive,
        existingTimetables: [Timetable],
        existingCourses: [Course],
        subjects: [Subject],
        modelContext: ModelContext
    ) throws -> Timetable {
        guard archive.endDate >= archive.startDate else { throw TimetableArchiveError.unsupportedFormat }
        let parity = WeekParity(rawValue: archive.firstWeekParity) ?? .odd
        let timetable = Timetable(
            name: uniqueName(archive.name, existingNames: existingTimetables.map(\.name)),
            startDate: archive.startDate,
            endDate: archive.endDate,
            firstWeekParity: parity,
            isCurrent: false
        )
        modelContext.insert(timetable)

        var courseMap: [UUID: Course] = [:]
        for item in archive.courses {
            let course: Course
            if let existing = existingCourses.first(where: { $0.name == item.name }) {
                course = existing
            } else {
                let subject = item.subjectName.flatMap { name in subjects.first { $0.name == name } }
                course = Course(name: item.name, systemImage: item.systemImage, subject: subject)
                modelContext.insert(course)
            }
            courseMap[item.id] = course
        }

        var periodMap: [UUID: ClassPeriod] = [:]
        for item in archive.periods {
            guard item.endMinute > item.startMinute else { continue }
            let period = ClassPeriod(
                orderIndex: item.orderIndex,
                name: item.name,
                startMinute: item.startMinute,
                endMinute: item.endMinute,
                timetable: timetable
            )
            modelContext.insert(period)
            periodMap[item.id] = period
        }

        var scheduleMap: [UUID: CourseSchedule] = [:]
        for item in archive.schedules {
            guard let course = courseMap[item.courseID],
                  let period = periodMap[item.periodID],
                  (1...7).contains(item.weekday)
            else { continue }
            let schedule = CourseSchedule(
                weekday: item.weekday,
                repeatRule: CourseRepeatRule(rawValue: item.repeatRule) ?? .weekly,
                teacher: item.teacher,
                location: item.location,
                exportsToCalendar: item.exportsToCalendar,
                reminderEnabled: item.reminderEnabled,
                reminderLeadMinutes: item.reminderLeadMinutes,
                course: course,
                timetable: timetable,
                period: period
            )
            modelContext.insert(schedule)
            scheduleMap[item.id] = schedule
        }

        for item in archive.overrides {
            guard let action = ScheduleOverrideAction(rawValue: item.action) else { continue }
            let schedule = item.scheduleID.flatMap { scheduleMap[$0] }
            let replacementCourse = item.replacementCourseID.flatMap { courseMap[$0] }
            modelContext.insert(ScheduleOverride(
                date: item.date,
                action: action,
                timetable: timetable,
                schedule: schedule,
                replacementCourse: replacementCourse,
                replacementStartMinute: item.replacementStartMinute,
                replacementEndMinute: item.replacementEndMinute
            ))
        }

        try modelContext.save()
        return timetable
    }

    private static func uniqueName(_ base: String, existingNames: [String]) -> String {
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmed.isEmpty ? "导入的课程表" : trimmed
        guard existingNames.contains(candidate) else { return candidate }
        var index = 2
        while existingNames.contains("\(candidate) \(index)") { index += 1 }
        return "\(candidate) \(index)"
    }

    private static func minute(from value: String) throws -> Int {
        let main = value.split(separator: ".").last.map(String.init) ?? value
        let components = main.split(separator: ":").compactMap { Int($0) }
        guard components.count >= 2,
              let hour = components.first,
              let minute = components.dropFirst().first,
              (0...23).contains(hour),
              (0...59).contains(minute)
        else { throw TimetableArchiveError.invalidTime(value) }
        return hour * 60 + minute
    }

    private static func uniqueModels<T: PersistentModel>(_ values: [T]) -> [T] {
        var identifiers = Set<PersistentIdentifier>()
        return values.filter { identifiers.insert($0.persistentModelID).inserted }
    }
}

private struct TimetableArchive: Codable {
    let version: Int
    let name: String
    let startDate: Date
    let endDate: Date
    let firstWeekParity: String
    var courses: [ArchivedCourse]
    var periods: [ArchivedPeriod]
    var schedules: [ArchivedSchedule]
    var overrides: [ArchivedOverride]
}

private struct ArchivedCourse: Codable {
    let id: UUID
    let name: String
    let systemImage: String
    let subjectName: String?
}

private struct ArchivedPeriod: Codable {
    let id: UUID
    let orderIndex: Int
    let name: String
    let startMinute: Int
    let endMinute: Int
}

private struct ArchivedSchedule: Codable {
    let id: UUID
    let weekday: Int
    let repeatRule: String
    let teacher: String
    let location: String
    let exportsToCalendar: Bool
    let reminderEnabled: Bool
    let reminderLeadMinutes: Int
    let courseID: UUID
    let periodID: UUID
}

private struct ArchivedOverride: Codable {
    let date: Date
    let action: String
    let scheduleID: UUID?
    let replacementCourseID: UUID?
    let replacementStartMinute: Int?
    let replacementEndMinute: Int?
}

private struct BlackboardTimetable: Decodable {
    let monday: [BlackboardLesson]
    let tuesday: [BlackboardLesson]
    let wednesday: [BlackboardLesson]
    let thursday: [BlackboardLesson]
    let friday: [BlackboardLesson]
    let saturday: [BlackboardLesson]
    let sunday: [BlackboardLesson]
    let temp: [BlackboardLesson]

    enum CodingKeys: String, CodingKey {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
        case temp = "Temp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        monday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .monday) ?? []
        tuesday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .tuesday) ?? []
        wednesday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .wednesday) ?? []
        thursday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .thursday) ?? []
        friday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .friday) ?? []
        saturday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .saturday) ?? []
        sunday = try container.decodeIfPresent([BlackboardLesson].self, forKey: .sunday) ?? []
        temp = try container.decodeIfPresent([BlackboardLesson].self, forKey: .temp) ?? []
    }
}

private struct BlackboardLesson: Decodable {
    let subject: String
    let startTime: String
    let endTime: String
    let strongClassOverNotificationEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case subject = "Subject"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case strongClassOverNotificationEnabled = "IsStrongClassOverNotificationEnabled"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subject = try container.decodeIfPresent(String.self, forKey: .subject) ?? "课程"
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
        strongClassOverNotificationEnabled = try container.decodeIfPresent(
            Bool.self,
            forKey: .strongClassOverNotificationEnabled
        ) ?? false
    }
}

private struct CSESProfile: Decodable {
    let version: Int
    let subjects: [CSESSubject]
    let schedules: [CSESSchedule]
}

private struct CSESSubject: Decodable {
    let name: String
    let teacher: String
    let room: String

    enum CodingKeys: String, CodingKey {
        case name, teacher, room
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        teacher = try container.decodeIfPresent(String.self, forKey: .teacher) ?? ""
        room = try container.decodeIfPresent(String.self, forKey: .room) ?? ""
    }
}

private struct CSESSchedule: Decodable {
    let enableDay: Int
    let weeks: String
    let classes: [CSESClass]

    enum CodingKeys: String, CodingKey {
        case enableDay = "enable_day"
        case weeks, classes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enableDay = try container.decode(Int.self, forKey: .enableDay)
        weeks = try container.decodeIfPresent(String.self, forKey: .weeks) ?? "all"
        classes = try container.decodeIfPresent([CSESClass].self, forKey: .classes) ?? []
    }
}

private struct CSESClass: Decodable {
    let subject: String
    let startTime: String
    let endTime: String

    enum CodingKeys: String, CodingKey {
        case subject
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

private struct ImportedArchiveBuilder {
    private(set) var archive: TimetableArchive
    private var courseIDs: [String: UUID] = [:]
    private var periodIDs: [String: UUID] = [:]

    init(name: String, startDate: Date, endDate: Date, firstWeekParity: WeekParity) {
        archive = TimetableArchive(
            version: 1,
            name: name,
            startDate: startDate,
            endDate: endDate,
            firstWeekParity: firstWeekParity.rawValue,
            courses: [],
            periods: [],
            schedules: [],
            overrides: []
        )
    }

    mutating func addSchedule(
        courseName: String,
        systemImage: String,
        weekday: Int,
        repeatRule: CourseRepeatRule,
        teacher: String,
        location: String,
        startMinute: Int,
        endMinute: Int,
        reminderEnabled: Bool
    ) {
        let courseID = courseID(for: courseName, systemImage: systemImage)
        let periodID = periodID(startMinute: startMinute, endMinute: endMinute)
        archive.schedules.append(ArchivedSchedule(
            id: UUID(),
            weekday: weekday,
            repeatRule: repeatRule.rawValue,
            teacher: teacher,
            location: location,
            exportsToCalendar: false,
            reminderEnabled: reminderEnabled,
            reminderLeadMinutes: 0,
            courseID: courseID,
            periodID: periodID
        ))
    }

    mutating func addTemporaryLesson(
        courseName: String,
        date: Date,
        startMinute: Int,
        endMinute: Int
    ) {
        let courseID = courseID(for: courseName, systemImage: "book.closed")
        archive.overrides.append(ArchivedOverride(
            date: date,
            action: ScheduleOverrideAction.add.rawValue,
            scheduleID: nil,
            replacementCourseID: courseID,
            replacementStartMinute: startMinute,
            replacementEndMinute: endMinute
        ))
    }

    private mutating func courseID(for name: String, systemImage: String) -> UUID {
        if let id = courseIDs[name] { return id }
        let id = UUID()
        courseIDs[name] = id
        archive.courses.append(ArchivedCourse(id: id, name: name, systemImage: systemImage, subjectName: nil))
        return id
    }

    private mutating func periodID(startMinute: Int, endMinute: Int) -> UUID {
        let key = "\(startMinute)-\(endMinute)"
        if let id = periodIDs[key] { return id }
        let id = UUID()
        periodIDs[key] = id
        archive.periods.append(ArchivedPeriod(
            id: id,
            orderIndex: archive.periods.count + 1,
            name: "第\(archive.periods.count + 1)节",
            startMinute: startMinute,
            endMinute: endMinute
        ))
        archive.periods.sort { $0.startMinute < $1.startMinute }
        for index in archive.periods.indices {
            let item = archive.periods[index]
            archive.periods[index] = ArchivedPeriod(
                id: item.id,
                orderIndex: index + 1,
                name: "第\(index + 1)节",
                startMinute: item.startMinute,
                endMinute: item.endMinute
            )
        }
        return id
    }
}
