import SwiftData

class DataManager {
    static let shared = DataManager()
    private init() {}
    
    // 保存用户配置
    func saveUserProfile(_ profile: UserProfile, context: ModelContext) {
        profile.lastModifiedDate = Date()
        do {
            try context.save()
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
    
    // 获取当前用户配置
    func getUserProfile(context: ModelContext) -> UserProfile? {
        let fetchDescriptor = FetchDescriptor<UserProfile>()
        return try? context.fetch(fetchDescriptor).first
    }
    
    // 创建大型考试组
    func createLargeExamGroup(name: String, date: Date, subjects: [String], context: ModelContext) {
        let groupId = UUID().uuidString
        
        // 创建大型考试记录
        let largeExam = ExamGroup(
            name: name,
            type: .large,
            date: date,
            groupId: groupId
        )
        context.insert(largeExam)
        
        // 为每个科目创建小型考试
        for subject in subjects {
            let smallExam = ExamGroup(
                name: \(name) - \(subject)",
                type: .small,
                date: date,
                groupId: groupId
            )
            context.insert(smallExam)
        }
        
        do {
            try context.save()
        } catch {
            print("Error creating exam group: \(error)")
        }
    }
}
