# UI 原生重构与 Figma 落地 Spec

## Why
项目现有 UI 是半成品：主导航只有两个标签，Figma 设计的「今天」和「课程表」页面尚未实现；部分界面使用了自定义手势、自定义提示条等非原生控件。本次要把 Figma 设计稿变成真实可运行的 app 内视图，并把非原生控件重构为 iOS 26 原生实现。

## What Changes
- 主导航从 2 标签扩展为 4 标签：今天 / 分析 / 数据库 / 课程表（对应 Figma 339_3103 底部 Tab Bar）
- 新建「今天」页（TodayView）：当前课程大卡 + 分时段课程列表，还原 Figma 339_3103 / 332_3637 / 343_1576
- 新建「课程表」页（ScheduleView）：按周展示课程安排，含当前课程详情（Figma 339_3109）
- 「分析」标签沿用现有 DashboardAnalysisView（已是原生实现）
- 「数据库」标签沿用 Database.swift 中的考试/练习统一列表
- 科目卡（SubjectScoreCard / ClassRankingCard）对齐 Figma 28_2000 / 28_2843 / 28_2838 视觉，全部用原生控件
- **BREAKING** 非原生控件原生化：自定义手势、自定义 Toast、自定义卡片等，替换为 swipeActions / ContentUnavailableView / sensoryFeedback / 系统材质等原生 API
- 排除 `AddDataView Legacy.swift`，消除潜在重复声明与死代码

## Impact
- Affected specs: 主导航、今天页、课程表页、科目概览、数据分析
- Affected code:
  - `Views/Core/MainTabView.swift`
  - `Views/Core/TodayView.swift`（新建）
  - `Views/Schedule/ScheduleView.swift`（新建）
  - `Cards/SubjectScoreCard.swift`、`Cards/ClassRankingCard.swift`
  - `CommonComponents/NativeGestures.swift`、`CommonComponents/UndoToastView.swift`、`Components/DataTypeCard.swift`
  - `Views/Core/AddDataView Legacy.swift`（排除）
  - `Models/ScheduleModels.swift`（读取，不改结构）

## ADDED Requirements

### Requirement: 四标签主导航
系统 SHALL 在 MainTabView 中提供四个原生 Tab：今天、分析、数据库、课程表，图标与文案对齐 Figma 339_3103。

#### Scenario: 应用启动进入四标签
- **WHEN** 用户完成引导并进入主界面
- **THEN** 底部显示四个标签，默认停留在「今天」
- **AND** 点击任一标签可切换到对应页面且状态保持

### Requirement: 今天页
系统 SHALL 提供「今天」页，展示当天日期、当前课程大卡与分时段课程列表。

#### Scenario: 有当前课程
- **WHEN** 当前时间落在某节课程时间段内
- **THEN** 顶部大卡显示「当前」标签、课程图标与名称、剩余时间、起止时间和进度条
- **AND** 下方按「接下来 / 中午 / 下午 / 晚修」分组显示后续课程行

#### Scenario: 今天无课程
- **WHEN** 当天没有任何课程安排
- **THEN** 使用原生 ContentUnavailableView 显示空状态，不显示当前课程大卡

### Requirement: 课程表页
系统 SHALL 提供「课程表」页，按周展示课程安排，并支持查看当前课程详情。

#### Scenario: 查看本周课程
- **WHEN** 用户打开课程表标签
- **THEN** 显示当前生效课程表在本周的课程安排
- **AND** 可打开当前课程详情（Figma 339_3109 的进度与信息布局）

#### Scenario: 无课程表数据
- **WHEN** 尚未创建任何课程表
- **THEN** 显示原生空状态并提供创建入口

## MODIFIED Requirements

### Requirement: 科目分数卡
系统 SHALL 使用原生 SwiftUI 控件渲染科目分数卡（SubjectScoreCard）与班级排名卡（ClassRankingCard），视觉对齐 Figma 28_2000 / 28_2843 / 28_2838，使用系统材质背景、系统字体与 Swift Charts 迷你图；不得使用自定义手写样式模拟系统控件。

### Requirement: 交互控件原生化
系统 SHALL 用原生 API 替换非原生交互控件：列表滑动操作使用 `swipeActions`，撤销提示使用系统机制或标准过渡，触感反馈使用 `sensoryFeedback`，空状态使用 `ContentUnavailableView`。凡有等价原生控件的自定义实现均须替换。

## REMOVED Requirements

### Requirement: AddDataView 旧版实现
**Reason**: `AddDataView Legacy.swift` 是历史遗留死代码，存在与正式版重复声明的风险。
**Migration**: 从 App Target 排除该文件（保留文件本体，不进入编译），功能以 `AddDataView.swift` 为准。
