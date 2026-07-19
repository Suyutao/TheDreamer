# The Dreamer - 项目 Code Wiki 文档

> **版本**: 1.0 | **最后更新**: 2026-05-09 | **作者**: 苏宇韬 (Suyutao)

---

## 📋 目录

- [1. 项目概述](#1-项目概述)
- [2. 技术栈与架构](#2-技术栈与架构)
- [3. 项目目录结构](#3-项目目录结构)
- [4. 应用启动流程](#4-应用启动流程)
- [5. 数据模型层 (Models)](#5-数据模型层-models)
  - [5.1 基础定义模型](#51-基础定义模型)
  - [5.2 核心枢纽模型](#52-核心枢纽模型)
  - [5.3 模板系统](#53-模板系统)
  - [5.4 考试实例模型](#54-考试实例模型)
  - [5.5 练习实例模型](#55-练习实例模型)
  - [5.6 辅助数据模型](#56-辅助数据模型)
  - [5.7 数据模型关系图](#57-数据模型关系图)
- [6. 视图层 (Views)](#6-视图层-views)
  - [6.1 核心视图](#61-核心视图)
  - [6.2 科目管理视图](#62-科目管理视图)
  - [6.3 考试组管理视图](#63-考试组管理视图)
  - [6.4 设置与引导视图](#64-设置与引导视图)
- [7. 组件层 (Components/Charts/Cards)](#7-组件层-componentschartscards)
  - [7.1 图表组件](#71-图表组件)
  - [7.2 通用组件](#72-通用组件)
  - [7.3 卡片组件](#73-卡片组件)
- [8. 关键数据结构与类型](#8-关键数据结构与类型)
- [9. 核心功能模块说明](#9-核心功能模块说明)
- [10. 数据流与状态管理](#10-数据流与状态管理)
- [11. 项目构建与运行](#11-项目构建与运行)
- [12. 开发规范与约定](#12-开发规范与约定)
- [13. 常见问题与调试指南](#13-常见问题与调试指南)

---

## 1. 项目概述

**The Dreamer** 是一个由学生打造、为学生服务的数据驱动学习分析工具。

### 核心使命
帮助学生通过数据分析实现 **"自由、秩序与自我掌控"** 的认知工具，将模糊的学习感受转化为清晰的可量化数据。

### 项目特点
- **本地优先**: 所有数据存储在设备上，保护隐私
- **数据可视化**: 提供折线图、柱状图、热力图、散点图等多种图表
- **模板系统**: 支持可复用的考试和练习模板
- **开源免费**: 采用 Apache License 2.0 协议，永不商业化

---

## 2. 技术栈与架构

### 技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| **SwiftUI** | iOS 26+ | 原生 UI 框架 |
| **SwiftData** | iOS 26+ | 本地数据持久化 |
| **Swift Charts** | iOS 16+ | 数据可视化图表 |
| **Xcode** | 26+ | 开发环境 |

### 架构模式
采用 **MV (Model-View)** 轻量级架构：
- **Model**: SwiftData `@Model` 类，负责数据定义和持久化
- **View**: SwiftUI View，负责 UI 展示和用户交互
- **无复杂 ViewModel**: 利用 SwiftUI 的声明式特性和 SwiftData 的 `@Query` 实现数据绑定

### 设计原则
- **代码组织**: 按职责分层存放（Models / Views / Components）
- **模块化导入**: 不导入内部项目模块，所有类型全局可见
- **极简依赖**: 仅使用 Apple 原生框架，无第三方库

---

## 3. 项目目录结构

```
The Dreamer/
├── The Dreamer/                    # 主应用 Target
│   ├── Models/
│   │   └── Models.swift            # 所有 SwiftData @Model 定义（唯一位置）
│   │
│   ├── Views/
│   │   ├── Core/                   # 核心功能视图
│   │   │   ├── MainTabView.swift        # 主标签页导航
│   │   │   ├── DashboardView.swift      # 科目概览页面（原 Database）
│   │   │   ├── DashboardAnalysisView.swift  # 数据分析页面
│   │   │   ├── AddDataView.swift         # 添加数据界面
│   │   │   ├── Database.swift            # 数据浏览与分析
│   │   │   ├── ExamDetailView.swift      # 考试详情
│   │   │   └── TrendAnalysisView.swift   # 趋势分析
│   │   │
│   │   ├── Subject/                # 科目管理视图
│   │   │   ├── ManageSubjectsView.swift   # 科目列表管理
│   │   │   ├── SubjectDetailView.swift     # 科目详情
│   │   │   ├── SubjectDataView.swift       # 科目数据展示
│   │   │   └── SubjectEditView.swift       # 科目编辑
│   │   │
│   │   ├── ExamGroup/              # 考试组管理视图
│   │   │   ├── ExamGroupManagementView.swift
│   │   │   ├── ExamGroupDetailView.swift
│   │   │   ├── AddExamToGroupView.swift
│   │   │   └── EditExamGroupView.swift
│   │   │
│   │   ├── OnBoarding/             # 新手引导
│   │   │   └── OnBoardingView.swift
│   │   │
│   │   ├── Settings/               # 设置
│   │   │   ├── SettingsView.swift
│   │   │   └── DebugSettingsView.swift
│   │   │
│   │   └── About/                  # 关于页面
│   │       └── AboutView.swift
│   │
│   ├── Components/                 # 可复用 UI 组件
│   │   ├── DataTypeCard.swift
│   │   └── TimeRangeSelector.swift
│   │
│   ├── Charts/                     # 图表可视化组件
│   │   ├── LineChartView.swift     # 折线图
│   │   ├── BarChartView.swift      # 柱状图
│   │   ├── PieChartView.swift      # 饼图
│   │   ├── HeatmapView.swift       # 热力图
│   │   ├── ScatterChartView.swift  # 散点图
│   │   └── Apple.Inc-SwiftChartsWWDC24/  # Apple WWDC24 示例代码
│   │
│   ├── Cards/                      # 数据展示卡片
│   │   ├── SubjectScoreCard.swift  # 科目分数卡片
│   │   ├── ClassRankingCard.swift  # 班级排名卡片
│   │   └── FigmaCardsPreviewView.swift
│   │
│   ├── CommonComponents/           # 通用 UI 组件
│   │   ├── EmptyStateView.swift    # 空状态提示
│   │   ├── FormHeader.swift        # 表单标题
│   │   ├── NativeGestures.swift    # 手势处理
│   │   └── UndoToastView.swift     # 撤销提示
│   │
│   ├── Resources/                  # 资源文件
│   │   ├── Assets.xcassets/        # 图片资源
│   │   └── Design/                 # 设计稿
│   │
│   ├── Support/                    # 支持文档
│   │   ├── DATA_CLEANUP_GUIDE.md
│   │   └── OnBoardingView_README.md
│   │
│   ├── Info.plist
│   ├── The_DreamerApp.swift        # 应用入口点
│   └── The_Dreamer.entitlements
│
├── The Dreamer.xcodeproj/          # Xcode 项目配置
├── The DreamerTests/               # 单元测试
├── The DreamerUITests/             # UI 测试
├── ThirdParty/                     # 第三方资源
│   └── Apple Inc/
│       └── CreatingADataVisualizationDashboardWithSwiftCharts/
├── docs/                           # 项目文档
│   └── plans/
│       └── 2026-05-01-product-vision-roadmap.md
├── .github/workflows/              # CI/CD 配置
├── .trae/rules/                    # Trae IDE 规则
├── README.md                       # 项目说明
├── AGENTS.md                       # AI 开发指南
├── LICENSE                         # Apache 2.0 许可证
└── NOTICE.md                       # 第三方声明
```

---

## 4. 应用启动流程

### 启动序列图

```
[TheDreamerApp (@main)]
    │
    ├─ 1. 创建 ModelContainer (Schema + Configuration)
    │   ├─ 注册所有 @Model 类型
    │   └─ 配置为磁盘持久化存储
    │
    ├─ 2. 创建 WindowGroup
    │   └─ 显示 ContentView()
    │
    └─ [ContentView]
        │
        ├─ 检查 @AppStorage("hasCompletedOnboarding")
        │
        ├─ false → 显示 OnBoardingView() (首次引导)
        │          └─ 引导完成后设置 hasCompletedOnboarding = true
        │
        └─ true  → 显示 MainTabView() (主界面)
                   ├─ Tab 1: Database (科目概览)
                   └─ Tab 2: DashboardAnalysisView (数据分析)
```

### 关键入口文件: [The_DreamerApp.swift](The%20Dreamer/The_DreamerApp.swift)

```swift
@main
struct TheDreamerApp: App {
    // 创建 SwiftData 模型容器
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()  // 决定显示引导还是主界面
        }
        .modelContainer(sharedModelContainer)  // 注入数据容器
    }
}
```

---

## 5. 数据模型层 (Models)

**文件位置**: [Models.swift](The%20Dreamer/Models/Models.swift)

所有 SwiftData `@Model` 类型集中定义在此文件中，遵循项目规范。

### 5.1 基础定义模型

#### TestMethod (考法标签)
```swift
@Model
final class TestMethod {
    @Attribute(.unique) var name: String  // e.g., "阅读理解", "力学大题"
}
```

**用途**: 标记题目的考查方法/知识点类型

#### QuestionType (题型标签)
```swift
@Model
final class QuestionType {
    @Attribute(.unique) var name: String  // e.g., "选择题", "填空题"
}
```

**用途**: 标记题目的形式类型

---

### 5.2 核心枢纽模型

#### Subject (科目) ⭐
```swift
@Model
final class Subject {
    var name: String                    // 科目名称
    var totalScore: Double              // 满分
    var orderIndex: Int = 0             // 手动排序索引
    var subjectDescription: String = "" // 科目描述
    var pinned: Bool = false            // 是否置顶
    var createdAt: Date?                // 创建时间
    var updatedAt: Date?                // 更新时间

    // 关系: 一对多
    @Relationship(deleteRule: .cascade) var paperTemplates: [PaperTemplate] = []
    @Relationship(deleteRule: .cascade) var exams: [Exam] = []
    @Relationship(deleteRule: .cascade) var practiceCollections: [PracticeCollection] = []
    @Relationship(deleteRule: .nullify) var paperStructures: [PaperStructure] = []

    // 计算属性
    var availableMethods: [TestMethod]   // 自动汇总所有考法
    var availableTypes: [QuestionType]   // 自动汇总所有题型

    // 数据聚合方法
    func getExamsInDateRange(_ dateRange: ClosedRange<Date>?) -> [Exam]
    func getRecentExams(days: Int) -> [Exam]
    func getScoreDataPoints(in dateRange: ClosedRange<Date>?) -> [ChartDataPoint]
}
```

**角色**: 数据模型的中心枢纽，所有其他实体都围绕 Subject 组织

**关键方法**:
- `getExamsInDateRange(_:)`: 按时间范围过滤考试记录
- `getScoreDataPoints(in:)`: 生成用于折线图的 ChartDataPoint 数组

---

### 5.3 模板系统

#### PaperStructure (卷子结构)
```swift
@Model
final class PaperStructure {
    var name: String                        // 结构名称
    var isTemplate: Bool                    // 是否为通用模板
    var subject: Subject?                   // 所属科目
    @Relationship(deleteRule: .cascade)
    var questionDefinitions: [QuestionDefinition] = []  // 包含的题目定义

    var totalScore: Double { ... }          // 计算属性: 卷面总分
}
```

**用途**: 定义试卷的固定结构（题号、分值、题型）

#### PaperTemplate (卷子模板)
```swift
@Model
final class PaperTemplate {
    var name: String
    var subject: Subject?
    @Relationship(deleteRule: .cascade)
    var questionTemplates: [QuestionTemplate] = []
}
```

**用途**: 可复用的试卷蓝图

#### QuestionDefinition (题目定义)
```swift
@Model
final class QuestionDefinition {
    var questionNumber: String    // 题号
    var points: Double            // 分值
    var type: QuestionType?       // 题型
    var method: String?           // 考法
}
```

#### QuestionTemplate (题目模板)
```swift
@Model
final class QuestionTemplate {
    var questionNumber: String
    var points: Double
    var type: QuestionType?
    var method: TestMethod?
    var template: PaperTemplate?
}
```

---

### 5.4 考试实例模型

#### Exam (考试) ⭐
```swift
@Model
final class Exam {
    var name: String                          // 考试名称
    var date: Date                           // 考试日期
    var score: Double = 0.0                  // 得分
    var totalScore: Double                   // 满分
    var subject: Subject?                    // 所属科目
    var createdAt: Date?
    var updatedAt: Date?

    @Relationship(deleteRule: .cascade)
    var questions: [Question] = []           // 题目得分明细

    var examGroup: ExamGroup?                // 所属考试组
    var paperStructure: PaperStructure?      // 使用的卷子结构

    @Relationship(deleteRule: .cascade)
    var questionResults: [QuestionResult] = []  // 详细得分记录

    var classRank: RankData?                 // 班级排名
    var gradeRank: RankData?                 // 年级排名

    var isGroupExam: Bool { examGroup != nil }  // 计算属性
}
```

**核心业务实体**, 记录一次真实的考试事件及其得分

#### ExamGroup (考试组/联考)
```swift
@Model
final class ExamGroup {
    var name: String
    var semester: String                     // 学期
    var createdDate: Date

    @Relationship(deleteRule: .cascade)
    var exams: [Exam] = []                   // 组内考试

    @Relationship(deleteRule: .cascade)
    var schedules: [ExamSchedule] = []       // 日程安排
}
```

**用途**: 管理联考或系列考试（如期中考试、月考等）

#### ExamSchedule (考试日程)
```swift
@Model
final class ExamSchedule {
    var date: Date
    var dayNumber: Int                       // 第几天
    var subjects: [String]                   // 当天考试科目
    var examGroup: ExamGroup?
}
```

#### Question (题目得分)
```swift
@Model
final class Question {
    var questionNumber: String
    var points: Double                       // 该题满分
    var score: Double                        // 该题得分
    var type: QuestionType?
    var method: TestMethod?
    var exam: Exam?
}
```

#### QuestionResult (题目结果)
```swift
@Model
final class QuestionResult {
    var score: Double                        // 得分
    var definition: QuestionDefinition?      // 关联到题目定义
}
```

---

### 5.5 练习实例模型

#### PracticeCollection (练习组)
```swift
@Model
final class PracticeCollection {
    var name: String                         // 练习组名称
    var createdAt: Date?
    var updatedAt: Date?
    var subject: Subject?                    // 所属科目

    @Relationship(deleteRule: .cascade)
    var practices: [Practice] = []           // 包含的练习记录
}
```

**用途**: 将同类练习归类（如"数学午间练"、"英语听力打卡"）

#### Practice (练习记录)
```swift
@Model
final class Practice {
    var date: Date                           // 练习日期
    var score: Double                        // 得分
    var createdAt: Date?
    var updatedAt: Date?
    var collection: PracticeCollection?      // 所属练习组
    var subject: Subject?                    // 冗余存储的科目引用
}
```

**轻量级成绩记录**, 用于日常练习追踪

---

### 5.6 辅助数据模型

#### RankData (排名数据)
```swift
@Model
final class RankData {
    var rank: Int                            // 排名
    var medianScore: Double?                 // 中位分
    var averageScore: Double?                // 平均分
}
```

**用途**: 存储班级/年级排名信息

---

### 5.7 数据模型关系图

```
Subject (枢纽)
  │
  ├─ 1:N → PaperTemplate ── 1:N → QuestionTemplate
  │                              ├─ type → QuestionType
  │                              └─ method → TestMethod
  │
  ├─ 1:N → Exam ── 1:N → Question
  │              ├─ 1:N → QuestionResult
  │              ├─ N:1 → ExamGroup
  │              ├─ N:1 → PaperStructure
  │              └─ rank → RankData (classRank, gradeRank)
  │
  ├─ 1:N → PaperStructure ── 1:N → QuestionDefinition
  │                                  ├─ type → QuestionType
  │                                  └─ method → String
  │
  └─ 1:N → PracticeCollection ── 1:N → Practice
                                      └─ subject → Subject (冗余引用)
```

**删除规则说明**:
- `.cascade`: 删除父对象时自动删除关联子对象
- `.nullify`: 删除父对象时将外键设为 nil

---

## 6. 视图层 (Views)

### 6.1 核心视图

#### MainTabView (主标签页导航)
**文件**: [MainTabView.swift](The%20Dreamer/Views/Core/MainTabView.swift)

**职责**: 应用主界面的标签页容器，包含两个主要标签

```swift
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            Database()                          // Tab 1: 概览
                .tabItem { Label("概览", systemImage: "chart.bar.doc.horizontal") }

            DashboardAnalysisView()            // Tab 2: 分析
                .tabItem { Label("分析", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .onAppear { performDataIntegrityCheck() }
    }
}
```

**额外职责**:
- 应用启动时执行数据完整性检查
- 清理无效的外键引用（subject == nil 的孤立数据）
- 回填缺失的时间戳字段

---

#### Database (科目概览页)
**文件**: [DashboardView.swift](The%20Dreamer/Views/Core/DashboardView.swift)

**职责**: 展示所有学习科目的概览信息

**核心功能**:
- 显示置顶科目和全部科目列表
- 每个科目卡片展示: 最新成绩、平均分、最高分、考试次数
- 支持添加新科目、进入设置
- 点击科目进入详情页

**数据查询**:
```swift
@Query(sort: \Subject.orderIndex) private var subjects: [Subject]
@Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
```

**关键方法**:
- `getLatestExam(for:)`: 获取某科最新考试
- `getAverageScore(for:)`: 计算某科平均分
- `getHighestScore(for:)`: 获取某科最高分
- `getSubjectIcon(for:)`: 根据科目名返回 SF Symbol 图标

---

#### DashboardAnalysisView (数据分析页)
**文件**: [DashboardAnalysisView.swift](The%20Dreamer/Views/Core/DashboardAnalysisView.swift)

**职责**: 提供详细的学习数据分析与可视化

**核心功能模块**:
1. **时间范围选择器**: 最近一周/一月/三月/全部时间
2. **总体统计**: 考试次数、平均分、提升率
3. **科目表现对比**: 柱状图 + 排名列表
4. **成绩趋势图**: 折线图显示分数变化
5. **详细数据表格**: 最近 10 条考试记录

**时间范围枚举**:
```swift
enum TimeRange: String, CaseIterable {
    case lastWeek = "最近一周"
    case lastMonth = "最近一月"
    case lastThreeMonths = "最近三月"
    case allTime = "全部时间"

    var dateRange: ClosedRange<Date>? { ... }
}
```

**内置图表组件**:
- `SubjectComparisonChart`: 科目对比柱状图
- `SubjectRankingView`: 科目排名列表
- `ScoreTrendChart`: 成绩趋势折线图
- `SubjectComparisonBar`: 柱状图标记

---

#### AddDataView (添加数据界面)
**文件**: [AddDataView.swift](The%20Dreamer/Views/Core/AddDataView.swift)

**职责**: 统一的考试/练习数据录入界面

**支持模式**:
- **新增模式**: 从空白开始创建考试或练习记录
- **编辑模式**: 编辑已有考试记录 (`examToEdit != nil`)

**录入字段**:
- 考试/练习名称
- 日期选择
- 分数输入
- 科目选择（可锁定）
- 练习类别选择（练习模式）
- 考试组选择（考试模式）

**数据验证**:
- 必填字段检查
- 分数范围校验
- 科目关联性验证

---

#### AnalysisView (数据浏览与分析)
**文件**: [Database.swift](The%20Dreamer/Views/Core/Database.swift)

**职责**: 全局数据浏览和管理中心

**核心功能**:
- 展示所有可用的图表类型（折线图、柱状图、饼图、热力图、散点图）
- 按科目筛选数据
- 快速添加新数据（考试/练习）
- 进入趋势分析视图

**关键枚举**:
```swift
enum AddableDataType: Identifiable {
    case exam        // 考试数据
    case practice    // 练习数据
}
```

---

### 6.2 科目管理视图

#### ManageSubjectsView (科目管理)
**文件**: [ManageSubjectsView.swift](The%20Dreamer/Views/Subject/ManageSubjectsView.swift)

**职责**: 科目的增删改查、排序管理

#### SubjectDetailView (科目详情)
**文件**: [SubjectDetailView.swift](The%20Dreamer/Views/Subject/SubjectDetailView.swift)

**职责**: 单个科目的详细分析和操作

**展示内容**:
- 科目基本信息（名称、描述、图标）
- 统计摘要（考试次数、平均分、最高分）
- 成绩趋势折线图（支持时间范围切换）
- 操作选项（编辑、添加数据、删除）

**时间范围控制**:
```swift
@State private var selectedRange: TimeRangeSelector.TimeRange = .month
// 支持: 月 / 6个月 / 年
```

#### SubjectEditView (科目编辑)
**文件**: [SubjectEditView.swift](The%20Dreamer/Views/Subject/SubjectEditView.swift)

**职责**: 创建或编辑科目的表单界面

#### SubjectDataView (科目数据展示)
**文件**: [SubjectDataView.swift](The%20Dreamer/Views/Subject/SubjectDataView.swift)

**职责**: 展示某科目下的所有考试和练习记录

---

### 6.3 考试组管理视图

#### ExamGroupManagementView (考试组管理)
**文件**: [ExamGroupManagementView.swift](The%20Dreamer/Views/ExamGroup/ExamGroupManagementView.swift)

**职责**: 创建和管理考试组（联考系列）

#### ExamGroupDetailView (考试组详情)
**文件**: [ExamGroupDetailView.swift](The%20Dreamer/Views/ExamGroup/ExamGroupDetailView.swift)

**职责**: 展示考试组内的所有考试和日程安排

#### AddExamToGroupView (添加考试到组)
**文件**: [AddExamToGroupView.swift](The%20Dreamer/Views/ExamGroup/AddExamToGroupView.swift)

**职责**: 将已有考试加入考试组

#### EditExamGroupView (编辑考试组)
**文件**: [EditExamGroupView.swift](The%20Dreamer/Views/ExamGroup/EditExamGroupView.swift)

**职责**: 修改考试组的名称、学期等信息

#### ExamGroupSelectionView (考试组选择器)
**文件**: [ExamGroupSelectionView.swift](The%20Dreamer/Views/ExamGroup/ExamGroupSelectionView.swift)

**职责**: 在添加考试时选择所属考试组

---

### 6.4 设置与引导视图

#### SettingsView (设置)
**文件**: [SettingsView.swift](The%20Dreamer/Views/Settings/SettingsView.swift)

**职责**: 应用设置和偏好配置

#### DebugSettingsView (调试设置)
**文件**: [DebugSettingsView.swift](The%20Dreamer/Views/Settings/DebugSettingsView.swift)

**职责**: 开发者调试选项（仅 DEBUG 模式可用）

#### OnBoardingView (新手引导)
**文件**: [OnBoardingView.swift](The%20Dreamer/Views/OnBoarding/OnBoardingView.swift)

**职责**: 首次启动时的应用引导流程

**触发条件**:
```swift
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
```

#### AboutView (关于页面)
**文件**: [AboutView.swift](The%20Dreamer/Views/About/AboutView.swift)

**职责**: 显示应用版本、许可证、致谢信息

---

## 7. 组件层 (Components/Charts/Cards)

### 7.1 图表组件

#### LineChartView (折线图) ⭐
**文件**: [LineChartView.swift](The%20Dreamer/Charts/LineChartView.swift)

**用途**: 展示分数随时间变化的趋势

**核心数据结构**:
```swift
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let totalScore: Double
    let examName: String
    let subject: String
    let type: LineType

    var scoreRate: Double { ... }  // 得分率百分比
}

enum LineType: String {
    case myScore           // 我的分数
    case classTotalScore   // 班级总分
    case classAverage      // 班级均分
    case targetScore       // 目标分数
}
```

**特性**:
- 支持多线条叠加（我的分数、班级均分、目标分等）
- 平滑曲线 (.smooth) 或直线连接 (.linear)
- Y轴可选择显示实际分数或百分比
- 自适应时间范围过滤

**使用示例**:
```swift
LineChartView(
    dataPoints: myDataPoints,
    selectedSubject: "数学",
    visibleLines: [.myScore, .classAverage],
    chartStyle: .smooth,
    showYAxisAsPercentage: true
)
.frame(height: 300)
```

---

#### BarChartView (柱状图)
**文件**: [BarChartView.swift](The%20Dreamer/Charts/BarChartView.swift)

**用途**: 科目间分数对比、单次考试各题型得分分布

#### PieChartView (饼图)
**文件**: [PieChartView.swift](The%20Dreamer/Charts/PieChartView.swift)

**用途**: 得分率占比、科目贡献比例

#### HeatmapView (热力图)
**文件**: [HeatmapView.swift](The%20Dreamer/Charts/HeatmapView.swift)

**用途**: 题型/考法的长期能力变化趋势分析

#### ScatterChartView (散点图)
**文件**: [ScatterChartView.swift](The%20Dreamer/Charts/ScatterChartView.swift)

**用途**: 不同分值区间的得分效率诊断

---

### 7.2 通用组件

#### TimeRangeSelector (时间范围选择器)
**文件**: [TimeRangeSelector.swift](The%20Dreamer/Components/TimeRangeSelector.swift)

**用途**: 提供"月 / 6个月 / 年"的分段选择控制器

```swift
struct TimeRangeSelector: View {
    enum TimeRange: String, CaseIterable {
        case month = "月"
        case sixMonths = "6个月"
        case year = "年"

        var dateRange: ClosedRange<Date>? { ... }
    }

    @Binding var selectedRange: TimeRange
}
```

#### EmptyStateView (空状态提示)
**文件**: [EmptyStateView.swift](The%20Dreamer/CommonComponents/EmptyStateView.swift)

**用途**: 当数据为空时展示友好的占位提示

#### FormHeader (表单标题)
**文件**: [FormHeader.swift](The%20Dreamer/CommonComponents/FormHeader.swift)

**用途**: 数据录入表单的标题组件

#### DataTypeCard (数据类型卡片)
**文件**: [DataTypeCard.swift](The%20Dreamer/Components/DataTypeCard.swift)

**用途**: 选择添加"考试"还是"练习"的类型选择卡片

---

### 7.3 卡片组件

#### SubjectScoreCard (科目分数卡片) ⭐
**文件**: [SubjectScoreCard.swift](The%20Dreamer/Cards/SubjectScoreCard.swift)

**用途**: Figma 设计还原的科目概览卡片

**视觉元素**:
- 左上角: SF Symbol 图标 + 学科名（橙色强调）
- 右上角: 日期 + 导航箭头
- 左下: "最新"标签 + 分数值
- 右下: 迷你折线图（可选）

**数据结构**:
```swift
struct SubjectScoreCard: View {
    struct Series: Identifiable {
        let id = UUID()
        let name: String
        let type: LineType
        let dataPoints: [ChartDataPoint]
    }

    let subjectName: String
    let scoreText: String
    let date: Date
    var iconSystemName: String = "function"
    var miniSeries: [Series] = []
    var showYAxisAsPercentage: Bool = false
}
```

**特性**:
- 内嵌迷你图组件 `SubjectScoreMiniChart`
- 支持百分比 Y轴显示
- 圆角卡片设计 (cornerRadius: 26)

---

#### ClassRankingCard (班级排名卡片)
**文件**: [ClassRankingCard.swift](The%20Dreamer/Cards/ClassRankingCard.swift)

**用途**: 展示班级/年级排名信息

---

## 8. 关键数据结构与类型

### ChartDataPoint (图表数据点)
**定义位置**: [LineChartView.swift:65-78](The%20Dreamer/Charts/LineChartView.swift#L65-L78)

```swift
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date              // 时间戳
    let score: Double           // 得分
    let totalScore: Double      // 满分
    let examName: String        // 考试名称
    let subject: String         // 科目名称
    let type: LineType          // 数据类型（我的分数/班级均分等）

    var scoreRate: Double {     // 得分率 (%)
        totalScore > 0 ? (score / totalScore) * 100 : 0
    }
}
```

**用途**: 所有图表组件统一使用的数据格式

---

### LineType (线条类型枚举)
**定义位置**: [LineChartView.swift](The%20Dreamer/Charts/LineChartView.swift)

```swift
enum LineType: String, CaseIterable {
    case myScore           // 我的分数
    case classTotalScore   // 班级总分
    case classAverage      // 班级均分
    case targetScore       // 目标分数

    var color: Color { ... }
    var isDashed: Bool { ... }
}
```

---

### AddableDataType (可添加数据类型)
**定义位置**: [Database.swift:30-42](The%20Dreamer/Views/Core/Database.swift#L30-L42)

```swift
enum AddableDataType: Identifiable {
    case exam      // 考试
    case practice  // 练习

    var id: String { ... }
}
```

---

## 9. 核心功能模块说明

### 9.1 数据录入流程

```
用户点击 "+" 按钮
    ↓
弹出 DataTypeCard 选择 [考试 / 练习]
    ↓
┌─────────────────────────────────────┐
│         AddDataView                 │
│  ┌─────────────────────────────┐   │
│  │  基本信息                    │   │
│  │  - 名称                      │   │
│  │  - 日期                      │   │
│  │  - 分数                      │   │
│  ├─────────────────────────────┤   │
│  │  关联信息                    │   │
│  │  - 科目 (必选)               │   │
│  │  - [考试] 考试组 (可选)      │   │
│  │  - [练习] 练习组 (必选)      │   │
│  ├─────────────────────────────┤   │
│  │  [保存] / [取消]             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
    ↓
验证通过 → modelContext.insert(newEntity)
         → modelContext.save()
    ↓
刷新相关视图 (@Query 自动更新)
```

---

### 9.2 数据分析流程

```
DashboardAnalysisView
    │
    ├─ 时间范围过滤 (TimeRange)
    │   └─ getFilteredExams() → [Exam]
    │
    ├─ 总体统计计算
    │   └─ calculateOverallStats()
    │       ├─ 考试次数
    │       ├─ 平均分
    │       └─ 提升率 (最近3次 vs 最早3次)
    │
    ├─ 科目分组
    │   └─ getExamsBySubject() → [(Subject, [Exam])]
    │
    └─ 渲染图表
        ├─ SubjectComparisonChart (柱状图)
        ├─ SubjectRankingView (排名列表)
        ├─ ScoreTrendChart (折线图)
        └─ detailTableView (数据表格)
```

---

### 9.3 数据完整性保障机制

**触发时机**: MainTabView.onAppear

**执行逻辑** ([MainTabView.swift:50-211](The%20Dreamer/Views/Core/MainTabView.swift#L50-L211)):

1. **清理孤立数据**:
   - 删除 `subject == nil` 的 PaperStructure
   - 删除 `subject == nil` 的 PaperTemplate
   - 删除 `subject == nil` 的 Exam
   - 删除 `subject == nil` 的 PracticeCollection
   - 删除 `subject == nil` 的 Practice

2. **回填时间戳**:
   - Subject: 用首个考试日期或当前时间
   - Exam: 用自身日期
   - PracticeCollection: 用首个练习日期或当前时间
   - Practice: 用自身日期

3. **执行条件控制**:
   ```swift
   UserDefaults.standard.bool(forKey: "HasPerformedInitialDataCheck")
   UserDefaults.standard.bool(forKey: "ShouldPerformDataIntegrityCheck")
   ```

---

## 10. 数据流与状态管理

### 10.1 SwiftData 数据查询

使用 `@Query` 属性包装器实现响应式查询：

```swift
// 查询所有科目，按 orderIndex 升序排列
@Query(sort: \Subject.orderIndex) private var subjects: [Subject]

// 查询所有考试，按日期降序排列
@Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]

// 使用谓词过滤
@Query(filter: #Predicate { $0.subject == selectedSubject }) private var filteredExams: [Exam]
```

**特性**:
- 数据变更时自动刷新 UI
- 支持排序、过滤、限制数量
- 与 SwiftUI 声明式语法无缝集成

---

### 10.2 状态管理策略

| 状态类型 | 工具 | 用途 | 示例 |
|---------|------|------|------|
| **UI State** | `@State` | 视图内部临时状态 | `selectedTimeRange`, `showingSheet` |
| **App Storage** | `@AppStorage` | 用户偏好持久化 | `hasCompletedOnboarding` |
| **Model Context** | `@Environment(\.modelContext)` | 数据库操作上下文 | 插入、删除、保存 |
| **Environment Values** | `@Environment(\.dismiss)` | 系统环境值 | 关闭当前视图 |
| **Query Data** | `@Query` | 数据库查询结果 | `subjects`, `exams` |
| **Bindings** | `@Binding` | 父子视图数据传递 | `dataType`, `selectedSubject` |

---

### 10.3 数据修改标准流程

```swift
// 1. 获取 ModelContext
@Environment(\.modelContext) private var modelContext

// 2. 创建新对象
let newExam = Exam(
    name: "期中考试",
    date: Date(),
    score: 85.0,
    totalScore: 100.0,
    subject: selectedSubject
)

// 3. 插入到上下文
modelContext.insert(newExam)

// 4. 保存更改
do {
    try modelContext.save()
} catch {
    print("保存失败: \(error)")
}
```

**删除流程**:
```swift
modelContext.delete(exam)
try? modelContext.save()
// 注意: 由于设置了 deleteRule: .cascade，关联的 Question 和 QuestionResult 会自动删除
```

---

## 11. 项目构建与运行

### 11.1 环境要求

- **操作系统**: macOS 26.0 (Developer Beta)
- **IDE**: Xcode 26+
- **SDK**: iOS 26 / iPadOS 26 / macOS 26 / watchOS 26 / visionOS 26
- **Swift**: 5.0+

### 11.2 构建命令

```bash
# 清理并构建项目（推荐）
xcodebuild -project "The Dreamer.xcodeproj" \
  -scheme "The Dreamer" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  clean build

# 构建用于测试
xcodebuild -project "The Dreamer.xcodeproj" \
  -scheme "The Dreamer" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test

# 归档用于发布
xcodebuild -project "The Dreamer.xcodeproj" \
  -scheme "The Dreamer" \
  -destination 'generic/platform=iOS' \
  archive
```

### 11.3 运行方式

1. **使用 Xcode**:
   - 打开 `The Dreamer.xcodeproj`
   - 选择目标模拟器 (如 iPhone 16 Pro / iPhone 17 Pro)
   - 按 `Cmd + R` 运行

2. **使用命令行**:
   ```bash
   xcodebuild -project "The Dreamer.xcodeproj" \
     -scheme "The Dreamer" \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
   ```

### 11.4 测试策略

**项目测试哲学**: 专注于编译成功，无需在真实设备或模拟器上运行

**验证步骤**:
1. 执行上述构建命令
2. 确认编译无错误、无警告
3. 如有编译错误，修复后重新编译

**测试文件位置**:
- `The DreamerTests/The_DreamerTests.swift`: 单元测试
- `The DreamerUITests/`: UI 测试套件

---

## 12. 开发规范与约定

### 12.1 文件组织规则

根据 [.trae/rules/project_rules.md](.trae/rules/project_rules.md):

| 代码类型 | 存放位置 | 示例 |
|---------|---------|------|
| `@Model` 数据模型 | `Models/` | `Models.swift` |
| 功能特定视图 | `Views/` | `DashboardView.swift` |
| 可复用 UI 组件 | `Components/` 或 `CommonComponents/` | `TimeRangeSelector.swift` |
| 图表组件 | `Charts/` | `LineChartView.swift` |
| 卡片组件 | `Cards/` | `SubjectScoreCard.swift` |
| 通用工具/扩展 | `Utils/` | Date 格式化扩展 |

**禁止事项**:
- ❌ 不导入内部项目模块（如 `import TheDreamer.Models`）
- ❌ 不在 Views 中定义 `@Model` 类
- ❌ 不在 Models 中定义 SwiftUI View

---

### 12.2 代码风格规范

**注释风格**:
```swift
// MARK: - Section Name        段落注释
/// 文档注释                     文档注释
// 行内注释                      行内注释
```

**命名约定**:
- 类/结构体: PascalCase (如 `SubjectScoreCard`)
- 函数/方法: camelCase (如 `getLatestExam`)
- 变量/属性: camelCase (如 `selectedSubject`)
- 枚举成员: camelCase (如 `.lastMonth`)

**封装原则**:
- 极度推崇封装，将复杂逻辑拆分为私有视图/函数
- 即使为了代码整洁，也应封装成独立组件

---

### 12.3 错误处理策略

**研发阶段**:
- 使用 `print()` + 时间戳记录错误日志
- 尽量避免弹窗提示用户
- 通过禁用控件等方式提供反馈

**示例**:
```swift
do {
    try modelContext.save()
} catch {
    print("[\(Date())] 保存失败: \(error.localizedDescription)")
    // 不弹窗，静默处理或禁用相关按钮
}
```

---

### 13. 常见问题与调试指南

### 13.1 编译问题

**Q: 出现 "Cannot find type XXX in scope" 错误**
A: 这是正常现象。Swift 允许跨文件访问组件，IDE 的组件检查只看当前文件。不要在文件中重复定义，否则会导致 redeclaration 错误。

**Q: SwiftData 模型变更后应用崩溃**
A: 需要进行数据迁移或清除应用数据：
- 模拟器: 长按应用图标 → 删除应用 → 重新运行
- 真机: 设置 → 通用 → iPhone 存储空间 → 删除 App

---

### 13.2 数据问题

**Q: 如何查看数据库中的数据？**
A: 使用 Debug 模式下的诊断工具：

```swift
#if DEBUG
// 在需要的地方调用
DataDiagnostics.printReport(modelContext)
DataDiagnostics.suggestions(modelContext)
#endif
```

输出示例:
```
=== Data Diagnostics Report @ 2026-05-09 14:30:00.123 ===
Subjects (3):
 - 数学 total: 150.0 | exams: 5 | templates: 2
 - 英语 total: 150.0 | exams: 3 | templates: 1
 - 物理 total: 100.0 | exams: 4 | templates: 1
...
```

**Q: 手动触发数据完整性检查**
A: 在 DebugSettingsView 中开启开关，或在代码中设置:
```swift
UserDefaults.standard.set(true, forKey: "ShouldPerformDataIntegrityCheck")
```

---

### 13.3 性能优化建议

**大数据量场景**:
- 使用 `@Query` 的 `limit` 和 `offset` 参数分页加载
- 图表数据预聚合，避免在视图中进行复杂计算
- 考虑使用 `LazyVStack` 延迟加载列表项

**图表渲染优化**:
- 限制同时显示的数据点数量（建议 ≤ 100 个）
- 使用 `.chartPlotStyle` 调整绘图区域
- 迷你图禁用交互检测 (`.allowsHitTesting(false)`)

---

## 附录 A: 项目版本历史

| 版本 | 主要变更 | 日期 |
|------|---------|------|
| V7 | 确立最终数据模型架构 | 2025-07-30 |
| V8 | 以 V7 模型作为编码起点 | 2025-07-30 |
| V18 | 新增 PracticeCollection 和 Practice 模型 | 2025-08-xx |
| V22 | 新增 orderIndex 字段支持手动排序 | 2025-xx-xx |
| E1.1 | 新增数据聚合层（时间范围过滤） | 2026-05-xx |

---

## 附录 B: 关键文件索引

| 文件路径 | 核心职责 | 重要程度 |
|---------|---------|---------|
| [The_DreamerApp.swift](The%20Dreamer/The_DreamerApp.swift) | 应用入口、Schema 配置 | ⭐⭐⭐ |
| [Models.swift](The%20Dreamer/Models/Models.swift) | 所有数据模型定义 | ⭐⭐⭐ |
| [MainTabView.swift](The%20Dreamer/Views/Core/MainTabView.swift) | 主导航、数据完整性检查 | ⭐⭐⭐ |
| [DashboardView.swift](The%20Dreamer/Views/Core/DashboardView.swift) | 科目概览页 | ⭐⭐⭐ |
| [DashboardAnalysisView.swift](The%20Dreamer/Views/Core/DashboardAnalysisView.swift) | 数据分析页 | ⭐⭐⭐ |
| [AddDataView.swift](The%20Dreamer/Views/Core/AddDataView.swift) | 数据录入界面 | ⭐⭐ |
| [LineChartView.swift](The%20Dreamer/Charts/LineChartView.swift) | 折线图组件 + ChartDataPoint | ⭐⭐⭐ |
| [SubjectScoreCard.swift](The%20Dreamer/Cards/SubjectScoreCard.swift) | 科目分数卡片 | ⭐⭐ |
| [TimeRangeSelector.swift](The%20Dreamer/Components/TimeRangeSelector.swift) | 时间范围选择器 | ⭐⭐ |
| [SubjectDetailView.swift](The%20Dreamer/Views/Subject/SubjectDetailView.swift) | 科目详情页 | ⭐⭐ |
| [OnBoardingView.swift](The%20Dreamer/Views/OnBoarding/OnBoardingView.swift) | 新手引导 | ⭐ |

---

## 附录 C: 术语表

| 术语 | 英文 | 说明 |
|------|------|------|
| 模型容器 | ModelContainer | SwiftData 的运行时环境，管理所有数据模型 |
| 模式 | Schema | 数据模型集合的定义 |
| 属性包装器 | Property Wrapper | Swift 特性，如 `@State`, `@Query`, `@Environment` |
| 关系 | Relationship | SwiftData 模型之间的关联（一对一、一对多） |
| 删除规则 | Delete Rule | 父对象删除时子对象的行为（.cascade, .nullify） |
| 查询 | Query | 从数据库检索数据的声明式 API |
| 数据点 | ChartDataPoint | 图表使用的标准化数据结构 |
| 考法 | TestMethod | 题目考查的知识点或能力维度 |
| 题型 | QuestionType | 题目的形式分类（选择题、填空题等） |
| 联考 | Exam Group | 多科目、多场次的综合性考试 |

---

## 附录 D: 参考资料

- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui)
- [SwiftData 官方文档](https://developer.apple.com/documentation/swiftdata)
- [Swift Charts 官方文档](https://developer.apple.com/documentation/charts)
- [Apple WWDC24: Creating a Data Visualization Dashboard with SwiftCharts](ThirdParty/Apple%20Inc/CreatingADataVisualizationDashboardWithSwiftCharts/)
- [项目 README](README.md)
- [AI 开发指南 (AGENTS.md)](AGENTS.md)
- [项目规则 (.trae/rules/project_rules.md)](.trae/rules/project_rules.md)

---

> **文档维护说明**: 本文档基于项目代码自动分析生成，随着项目演进需定期更新。
>
> **最后更新时间**: 2026-05-09
>
> **文档版本**: v1.0
