# The Dreamer 原生重建与课程表实施计划

**目标：** 将现有半成品重建为可发布的 iOS 26 原生学习数据应用，完成成绩主链路、Figma 课程表、单双周、系统日历导出和本地提醒。

**架构：** 保留确认有效的 SwiftData 数据与业务概念，重建主导航和核心页面。应用采用 Model-View，SwiftData 是唯一业务数据源；EventKit 只承接用户主动执行的日历导出，UserNotifications 负责本地课程提醒。Figma 提供信息结构与视觉参考，系统导航、表单、列表、选择器、按钮、菜单和空状态全部使用原生 SwiftUI 控件。

**技术栈：** Swift 5、SwiftUI、SwiftData、Swift Charts、EventKit、UserNotifications、iOS 26 SDK

---

## 一、已确认范围

### 首版包含

- 四个主标签：今天、分析、数据库、课程表。
- 科目创建、编辑、排序、置顶与删除。
- 考试和练习的创建、编辑、删除与统一浏览。
- 考试组管理。
- 得分率趋势、科目对比和事实型分析文字。
- 学期设置、周课表、节次、单双周和指定日期调课。
- 当前课程、下一节课程、当天课程分组与课程进度。
- 每门课程独立设置日历导出和本地提醒。
- 系统日历事件更新与删除。

### 首版不包含

- 卷子模板完整编辑器。
- 逐题录入、题型和考法分析。
- Widget、Live Activity 和云同步。
- 系统日历向应用反向同步。
- 自定义绘制的导航栏、Tab Bar、表单控件或仿系统弹窗。

## 二、关键决策

### ADR-001：原生重建，不继续逐页修复

**决定：** 保留可迁移的数据模型、有效聚合逻辑和资源，重建主导航及核心页面。

**原因：** 当前项目存在重复分析页面、重复图表体系、文件名与类型名错位、不可达页面、旧页面和自定义仿系统控件。继续局部修改会长期保留这些结构问题。

**代价：** 需要明确旧模型迁移规则，并逐页替换现有导航入口。

### ADR-002：应用数据是课程表唯一来源

**决定：** 课程安排存储在 SwiftData。EventKit 事件是导出副本，不作为应用查询来源。

**原因：** 避免用户在系统日历修改事件后破坏学期、单双周和调课规则。

**代价：** 外部修改不会自动回写应用；应用修改后由保存的事件标识更新导出事件。

### ADR-003：课程独立保存，可选关联 Subject

**决定：** `Course` 独立保存，可选关联现有 `Subject`。`CourseSchedule` 关联 `Course`、`Timetable` 和 `ClassPeriod`，教师、地点、单双周和提醒保存在课程安排中。

**原因：** 用户无需先建立成绩科目即可排课；需要时仍可从课程关联对应的学习数据。

### ADR-005：课程表拥有日期范围并支持复制

**决定：** `Timetable` 保存名称、开始日期、结束日期、首周类型和当前状态。课程身份不属于某个学期；复制课程表时复制节次与课程安排，但继续引用原有课程身份。

**原因：** 同一门课程可出现在不同学期或不同版本课程表中，课程身份不应随课程表删除。

### ADR-006：删除只作用于安排

**决定：** 删除课程表时删除其节次、课程安排、调课和导出记录，保留课程身份。删除节次时删除使用该节次的课程安排，保留课程身份。执行删除前取消对应提醒，并让用户决定是否删除系统日历事件。

**原因：** 节次和课程表描述时间安排，不代表课程身份本身。

### ADR-004：每门课程独立提醒

**决定：** 每门课程可分别关闭提醒，或选择准时、提前 5、10、15、30 分钟；日历导出和应用通知分别开关。

**原因：** 不同课程和通勤安排需要不同提前量。

## 三、目标数据模型

### 现有核心模型

- `Subject`：科目身份、默认满分、排序、描述和置顶。
- `Exam`：考试名称、日期、成绩、满分、科目和考试组。
- `ExamGroup`：同一场综合考试的科目集合。
- `PracticeCollection`：同类练习集合。
- `Practice`：单次练习成绩。

### 新增课程模型

- `Course`
  - 名称。
  - 系统图标。
  - 可选关联 `Subject`。
- `Timetable`
  - 名称。
  - 开始日期与结束日期。
  - 第 1 周对应的单双周类型。
  - 是否为当前学期。
  - 支持复制节次与课程安排。
- `ClassPeriod`
  - 节次序号。
  - 显示名称。
  - 开始时间与结束时间。
  - 关联 `Timetable`。
- `CourseSchedule`
  - 关联 `Course`。
  - 关联 `Timetable`。
  - 星期。
  - 关联 `ClassPeriod`。
  - 重复规则：每周、单周、双周。
  - 教师与地点。
  - 是否导出日历。
  - 是否启用本地提醒。
  - 提前分钟数。
- `ScheduleOverride`
  - 指定日期。
  - 操作类型：取消、换课、新增。
  - 关联 `Timetable` 和原课程安排。
  - 可选替代课程与时间。
- `CalendarExportRecord`
  - 关联课程安排。
  - 课程实际日期。
  - EventKit 事件标识。

### 数据约束

- 成绩不得小于 0。
- 满分必须大于 0。
- 成绩不得大于满分，缺考必须使用独立状态表达。
- 考试和练习必须关联科目。
- 练习必须关联练习集合。
- 课程结束时间必须晚于开始时间。
- 学期结束日期必须晚于开始日期。
- 同一星期和节次出现冲突时禁止保存并在表单内显示原因。
- 删除考试组不得删除考试。
- 删除课程表时删除其节次、课程安排、调课和导出记录，但保留课程身份。
- 删除节次时删除使用该节次的课程安排，但保留课程身份。
- 删除课程安排时同步取消对应通知；已导出的日历事件由用户确认是否删除。

## 四、界面结构

### 今天

- 使用原生 `NavigationStack` 和滚动内容。
- 顶部显示当天日期与设置入口。
- 有正在进行的课程时显示 Figma 当前课程卡：课程名、剩余时间、进度、起止时间。
- 没有当前课程时显示下一节课程和距离开始的时间。
- 后续课程按上午、中午、下午、晚修分组。
- 点击课程进入原生详情页。
- 无学期或无课程时使用 `ContentUnavailableView` 给出设置入口。

### 分析

- 使用得分率而不是原始分数跨科比较。
- 使用统一聚合类型向 Swift Charts 提供数据。
- 首版包含趋势折线图和科目对比柱状图。
- 数据不足时不生成趋势判断。
- 分析文字只描述可计算事实，不给出未经数据支持的学习建议。

### 数据库

- 统一显示考试和练习。
- 支持按科目、类型和时间筛选。
- 支持系统搜索。
- 使用原生 swipe actions、确认对话框和撤销行为。
- 工具栏提供新增记录和科目管理入口。

### 课程表

- 主页面遵循 Figma 的“当前课程＋当天分组课程”结构。
- 周视图使用原生日期选择和列表，不仿造系统导航栏。
- 设置页面使用 `Form` 管理学期、节次和单双周。
- 课程编辑使用 `Picker`、`DatePicker`、`Toggle` 和 `LabeledContent`。
- 日历权限和通知权限只在用户首次启用对应功能时请求。

## 五、错误与权限

- SwiftData 保存必须使用 `do/catch`，禁止 `try? modelContext.save()`。
- 保存错误显示在当前页面，不使用 UIKit 弹窗。
- EventKit 未授权时保留课程，不启用导出，并显示前往系统设置的入口。
- 通知未授权时保留课程，不创建提醒，并显示权限状态。
- 更新日历事件失败时保留 `CalendarExportRecord`，显示可重试状态。
- App 启动不得因存储创建失败直接进入无法解释的崩溃路径；开发构建记录完整错误。
- 所有权限说明写入 `Info.plist`，文案明确说明数据用途。

## 六、实施任务

### Task 1：保护工作区并建立重建分支

**检查：**

- 当前 `main` 比 `origin/main` 领先 5 个提交。
- 当前存在未提交的 Xcode 工程、Scheme、新增模型片段和 `CODE_WIKI.md`。

**步骤：**

1. 记录 `git status`、本地提交和未提交文件。
2. 不丢弃、不覆盖、不自动提交用户改动。
3. 从当前 HEAD 创建 `feature/native-rebuild`。
4. 再次确认分支与工作区内容一致。

**验证：** `git status --short --branch` 中所有原有改动仍存在。

### Task 2：恢复可重复编译基线

**文件：**

- 修改：`The Dreamer.xcodeproj/project.pbxproj`
- 检查：`The Dreamer/Charts/Apple.Inc-SwiftChartsWWDC24/`
- 检查：`The Dreamer/CommonComponents/Apple.Inc-SwiftChartsWWDC24/`

**步骤：**

1. 区分项目正式使用的图表代码与 Apple 示例。
2. 将未使用示例移出 App Target，保留第三方许可和源码参考。
3. 修正 Xcode Command Line Tools 选择方式，不修改用户全局设置。
4. 使用 Xcode beta 的 `DEVELOPER_DIR` 执行 clean build。
5. 若 Swift 宏插件仍返回 malformed response，单独验证 Xcode 工具链状态并记录环境阻断。

**验证命令：**

```bash
DEVELOPER_DIR="/Applications/Dev/Xcode-beta.app/Contents/Developer" xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination "platform=iOS Simulator,name=iPhone 17 Pro" clean build CODE_SIGNING_ALLOWED=NO
```

**通过标准：** 输出 `BUILD SUCCEEDED`；否则不得进入功能完成声明。

### Task 3：建立版本化 SwiftData Schema

**文件：**

- 修改：`The Dreamer/Models/Models.swift`
- 创建：`The Dreamer/Models/TheDreamerSchema.swift`
- 修改：`The Dreamer/The_DreamerApp.swift`

**步骤：**

1. 记录当前模型为旧版本 Schema。
2. 定义目标 Schema 和迁移计划。
3. 统一两套重复题目模型的边界；首版未使用模型不进入主流程。
4. 修正考试组删除规则。
5. 明确历史考试满分是记录快照，不随科目默认满分变化。
6. 增加课程表相关模型。
7. 将 ModelContainer 接入迁移计划。
8. 增加内存容器测试，验证 Schema 可创建。

**验证：** 测试容器成功创建，旧模型样本可迁移，删除考试组不删除考试。

### Task 4：统一数据写入和验证

**文件：**

- 创建：`The Dreamer/Utils/ScoreValidation.swift`
- 创建：`The Dreamer/Utils/ModelContextSave.swift`
- 修改：所有正式新增、编辑和删除页面。

**步骤：**

1. 集中定义考试与练习成绩验证。
2. 移除正式写入路径中的 `try? modelContext.save()`。
3. 统一保存错误状态。
4. 统一删除、确认与撤销行为。
5. 修复“清除所有数据”的范围与保存行为。

**验证：** 非法成绩无法保存；模拟保存失败时页面显示错误；批量删除与单条删除行为一致。

### Task 5：重建四标签主导航

**文件：**

- 修改：`The Dreamer/Views/Core/MainTabView.swift`
- 创建：`The Dreamer/Views/Core/TodayView.swift`
- 重命名或重建：概览、分析和数据库对应文件。

**步骤：**

1. 使用原生 `TabView` 建立今天、分析、数据库、课程表。
2. 修正 `DashboardView.swift` 与 `Database.swift` 的类型命名错位。
3. 删除正式导航中的不可达重复页面。
4. 设置每个 Tab 独立的 `NavigationStack`。
5. 保留系统 Tab Bar 行为，不实现 Figma 中手绘 Tab Bar。

**验证：** 四个标签均可进入；导航标题不重复；返回行为符合系统规则。

### Task 6：重建科目、考试与练习主链路

**文件：**

- 修改：`The Dreamer/Views/Subject/`
- 修改：`The Dreamer/Views/Core/AddDataView.swift`
- 创建：`The Dreamer/Views/Practice/PracticeCollectionManagementView.swift`
- 修改：`The Dreamer/Views/ExamGroup/`

**步骤：**

1. 将科目管理中的 UIKit 确认框改为 SwiftUI `confirmationDialog` 或 `alert`。
2. 用原生 Form 重建考试和练习录入。
3. 允许用户在首次添加练习时创建练习集合。
4. 保持从科目详情进入时科目锁定。
5. 完成考试组关联与解除。
6. 删除 `AddDataView Legacy.swift` 的 Target 引用；确认无用途后再删除文件。

**验证：** 空数据库可完成“创建科目→添加考试→添加练习→浏览→编辑→删除”。

### Task 7：统一数据库页面

**文件：**

- 重建：`The Dreamer/Views/Core/Database.swift`
- 修改：`The Dreamer/CommonComponents/UndoToastView.swift`

**步骤：**

1. 合并考试和练习列表。
2. 增加原生 searchable、筛选和排序。
3. 使用 `swipeActions` 处理编辑与删除。
4. 统一撤销提示，移除自定义拖动手势依赖。
5. 修正文案与实际行为冲突。

**验证：** 搜索、筛选、删除和撤销对两种记录都生效。

### Task 8：重建分析页面

**文件：**

- 重建：`The Dreamer/Views/Core/DashboardAnalysisView.swift`
- 修改：`The Dreamer/Charts/LineChartView.swift`
- 修改：`The Dreamer/Charts/BarChartView.swift`
- 创建：`The Dreamer/Utils/LearningAnalytics.swift`

**步骤：**

1. 删除重复的内嵌图表体系。
2. 统一使用得分率数据点。
3. 实现时间范围和科目筛选。
4. 数据少于 2 个有效点时不显示趋势结论。
5. 生成可验证的事实型分析文字。
6. 为 0 满分、缺失科目和稀疏数据提供保护。

**验证：** 不同满分科目可公平比较；0/0 不产生 NaN 或 Infinity；空数据不崩溃。

### Task 9：实现课程表数据与规则

**文件：**

- 创建：`The Dreamer/Models/ScheduleModels.swift`
- 创建：`The Dreamer/Utils/ScheduleResolver.swift`
- 创建：`The DreamerTests/ScheduleResolverTests.swift`

**步骤：**

1. 实现学期周数计算。
2. 实现首周类型与单双周判断。
3. 实现指定日期取消、换课和新增覆盖。
4. 实现当前课程、下一节课程和当天课程解析。
5. 实现时间冲突检测。
6. 编写边界测试：学期首日、跨年、单双周、调课、课程结束时刻。

**验证：** 所有规则测试通过。

### Task 10：按 Figma 实现课程表 UI

**设计依据：**

- `.figma/339_3103/`：课程表主页面。
- `.figma/332_3637/`：当前课程卡。
- `.figma/343_1576/`：普通课程行。
- `.figma/339_3109/`：当前课程详情概念。

**文件：**

- 创建：`The Dreamer/Views/Schedule/ScheduleView.swift`
- 创建：`The Dreamer/Views/Schedule/TodayScheduleView.swift`
- 创建：`The Dreamer/Views/Schedule/CourseDetailView.swift`
- 创建：`The Dreamer/Views/Schedule/CourseEditView.swift`
- 创建：`The Dreamer/Views/Schedule/SemesterSettingsView.swift`
- 创建：`The Dreamer/Components/CurrentCourseCard.swift`
- 创建：`The Dreamer/Components/CourseRow.swift`

**步骤：**

1. 保留 Figma 的信息层级和课程分组。
2. 使用系统字号、动态类型、语义颜色和 SF Symbols。
3. 当前课程卡使用 `ProgressView` 表达进度。
4. 普通课程使用原生按钮或 NavigationLink，保证完整无障碍语义。
5. 学期与课程编辑使用 Form。
6. 支持浅色、深色和较大动态字体。

**验证：** 与 Figma 截图逐项比较布局、层级、间距和状态；同时确认没有手绘状态栏、导航栏或 Tab Bar。

### Task 11：接入系统日历

**文件：**

- 创建：`The Dreamer/Utils/CalendarExportService.swift`
- 修改：`The Dreamer/Views/Schedule/CourseEditView.swift`
- 修改：`The Dreamer/Info.plist`

**步骤：**

1. 使用 EventKit 请求仅写入事件所需权限。
2. 用户开启导出时，为学期范围内实际发生的课程生成事件。
3. 单双周和调课由应用解析后生成具体事件，避免依赖无法表达全部规则的简单 recurrence。
4. 保存每个事件标识。
5. 修改课程时更新对应事件。
6. 删除课程时询问是否同步删除事件。
7. 权限拒绝和事件不存在时提供可恢复状态。

**验证：** 导出、更新、取消课程和删除课程均不会生成重复事件。

### Task 12：接入本地提醒

**文件：**

- 创建：`The Dreamer/Utils/CourseNotificationService.swift`
- 修改：`The Dreamer/Views/Schedule/CourseEditView.swift`

**步骤：**

1. 用户首次启用提醒时请求通知权限。
2. 为学期内近期课程安排通知，避免超过系统待处理通知数量限制。
3. 在应用启动、课程修改和日期变化时刷新通知窗口。
4. 通知标识包含课程和实际日期，确保可更新和取消。
5. 支持准时及提前 5、10、15、30 分钟。
6. 删除课程、取消某日课程或关闭提醒时删除对应通知。

**验证：** 通知请求数量受控；修改提前量后旧通知被替换；取消课程后没有残留提醒。

### Task 13：移除非原生 UI 与占位功能

**文件：**

- 删除或停止引用：`The Dreamer/CommonComponents/NativeGestures.swift`
- 检查：`The Dreamer/Cards/`
- 检查：`The Dreamer/Views/OnBoarding/OnBoardingView.swift`
- 检查：`The Dreamer/Views/About/AboutView.swift`
- 检查：`The Dreamer/Views/Settings/SettingsView.swift`

**步骤：**

1. 移除 UIKit 视图、手势识别器和 UIKit 弹窗。
2. 移除透明按钮覆盖自定义行的导航做法。
3. 删除“图表预留处”“即将推出”和 Lorem ipsum。
4. 移除发布界面的调试危险操作。
5. 从 Bundle 读取版本号，不再硬编码。
6. 保留真正需要的 Swift Charts 交互；图表手势不视为仿系统控件。

**验证：** 正式代码中没有 `import UIKit`、`UIViewRepresentable`、`UIAlertController` 或占位文案。

### Task 14：最终验证

**步骤：**

1. 执行完整 clean build。
2. 执行规则单元测试。
3. 检查所有 SwiftData 写入错误处理。
4. 检查权限说明和拒绝状态。
5. 检查深色模式、动态字体和空数据。
6. 检查旧数据迁移。
7. 检查 Git diff，确认没有覆盖任务开始前的用户改动。

**最终编译命令：**

```bash
DEVELOPER_DIR="/Applications/Dev/Xcode-beta.app/Contents/Developer" xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination "platform=iOS Simulator,name=iPhone 17 Pro" clean build CODE_SIGNING_ALLOWED=NO
```

**完成标准：**

- 输出 `BUILD SUCCEEDED`。
- 核心主链路可从空数据开始完成。
- 四个主标签均有真实功能。
- Figma 课程表主要状态已实现。
- 日历导出不会重复创建事件。
- 本地提醒可更新和取消。
- 正式 UI 不使用 UIKit 或仿系统控件。
- 没有未说明的测试失败或未验证项目。

## 七、Git 策略

- 工作分支：`feature/native-rebuild`。
- 不重写 `main` 历史。
- 不使用 `git reset --hard`、`git clean` 或强制推送。
- 不自动提交任务开始前已有的未提交文件。
- 未经用户明确要求，不创建 commit、不 push、不合并。
