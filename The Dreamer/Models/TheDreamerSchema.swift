import SwiftData

enum TheDreamerSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            TestMethod.self,
            QuestionType.self,
            Subject.self,
            PaperStructure.self,
            PaperTemplate.self,
            QuestionDefinition.self,
            QuestionTemplate.self,
            Exam.self,
            ExamGroup.self,
            ExamSchedule.self,
            Question.self,
            QuestionResult.self,
            PracticeCollection.self,
            Practice.self,
            RankData.self
        ]
    }
}

enum TheDreamerSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        TheDreamerSchemaV1.models + [
            Course.self,
            Timetable.self,
            ClassPeriod.self,
            CourseSchedule.self,
            ScheduleOverride.self,
            CalendarExportRecord.self
        ]
    }
}

enum TheDreamerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TheDreamerSchemaV1.self, TheDreamerSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: TheDreamerSchemaV1.self, toVersion: TheDreamerSchemaV2.self)
        ]
    }
}

enum TheDreamerModelContainer {
    static func make(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TheDreamerSchemaV2.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(
            for: schema,
            migrationPlan: nil,
            configurations: [configuration]
        )
    }
}
