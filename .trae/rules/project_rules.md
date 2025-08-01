# 项目总纲: The Dreamer

## 1. 项目核心信息
*   **项目名称:** The Dreamer
*   **项目宣言:** 由学生打造，为学生服务。一个旨在帮助学生通过数据分析实现“自由、秩序与自我掌控”的认知工具。
*   **核心原则:** 本项目采用GPLv3开源协议，永不商业化，永远免费开源。

## 2. 技术与架构约束
*   **技术栈:** SwiftUI, SwiftData, Swift Charts, Swift。
*   **目标SDK:** iOS 26。
*   **架构模式:** 遵循MV（Model-View）模式。视图（View）通过`@Query`直接从数据库获取数据，通过`modelContext`进行数据操作。避免使用复杂的、与视图生命周期强绑定的ViewModel。
*   **禁止使用的APIs:** 禁止使用`UIKit`/`AppKit`进行界面布局；禁止使用`CoreData`；禁止使用`UserDefaults`存储核心业务数据。

## 3. 数据模型蓝图 (SwiftData)
*   **`Subject`:** 学科 (name, totalScore, orderIndex)。
*   **`Exam`:** 考试实例 (name, date, totalScore) -> 关联`Subject`。
*   **`PracticeCollection`:** 练习合集 (name) -> 关联`Subject`。
*   **`Practice`:** 单次练习 (date, score, totalScore) -> 关联`PracticeCollection`。
*   **`Question`:** 题目实例 (questionNumber, score, totalScore) -> 关联`Exam`或`Practice`。
*   **`PaperTemplate`:** 卷子模板 (name) -> 关联`Subject`。
*   **`QuestionTemplate`:** 题目模板 (questionNumber, totalScore) -> 关联`PaperTemplate`。
*   **`QuestionType` & `CognitiveLaw`:** 题型与考法标签 (name)。

## 4. 可视化方案蓝图 (Swift Charts)
*   **折线图:** 核心图表，展示分数随时间的变化趋势，支持多条曲线（我的分数, 班级均分等）叠加。
*   **柱状图/叠层柱状图:** 用于单次考试的科目对比，或历次考试中各科分数贡献的比例变化。
*   **占比图 (扇形图/进度图):** 用于展示单次考试的得分率、科目/题型占比等静态构成。
*   **散点密度图:** 进阶图表，用于诊断不同分值、不同题型的得分效率。
*   **热力图:** 进阶图表，用于分析特定题型/考法的长期能力变化趋势。

## 5. 核心功能模块
*   `MainTabView`, `ManageSubjectsView`, `AddDataView`, `AnalysisView (V1)`, `DashboardView (V1)`, `OnBoardingView`, `TemplateManagementView`, `DetailedDataEntryView`, `DashboardView (V2+)`, `AnalysisView (V2+)`, `SearchFunctionalityView`。