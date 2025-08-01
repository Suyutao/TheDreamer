# 项目总纲: The Dreamer (V6.0)

## 1. 项目核心信息
*   **项目名称:** The Dreamer
*   **项目宣言:** 由学生打造，为学生服务。一个旨在帮助学生通过数据分析实现“自由、秩序与自我掌控”的认知工具。
*   **核心原则:** 本项目采用GPLv3开源协议，永不商业化，永远免费开源。

## 2. 技术与架构约束
*   **技术栈:** SwiftUI, SwiftData, Swift Charts, Swift。
*   **目标SDK:** iOS 26。
*   **架构模式:** 遵循MV（Model-View）模式。
*   **禁止使用的APIs:** 禁止使用`UIKit`/`AppKit`进行界面布局；禁止使用`CoreData`；禁止使用`UserDefaults`存储核心业务数据。

---
## 3. !!! 代码组织与文件结构规范 (The "Where-To-Put-Code" Rulebook) !!!

**这是决定代码存放位置的最高准则。所有AI在生成或修改代码时，必须严格遵守。**

*   **原则一：按职责划分目录 (Directory by Responsibility)**
    *   **`Models/`**: **唯一**存放所有SwiftData `@Model`类型（如`Subject`, `Exam`）的地方。
    *   **`Views/`**: 存放所有核心的、与特定功能绑定的SwiftUI视图（如`ManageSubjectsView`, `DashboardView`）。
    *   **`Components/`**: 存放所有通用的、可在多个视图中复用的UI组件（如`HeaderView`, `EmptyStateView`）。
    *   **`Utils/` 或 `Extensions/`**: 存放通用的辅助函数或对现有类型的扩展（如`Date`格式化扩展）。

*   **原则二：智能决策路由 (Intelligent Decision Routing)**
    *   **当需要一个新类型时，首先判断其职责：**
        1.  **是数据模型吗？ (`@Model`)** -> **必须**在`Models/`目录下创建或修改。
        2.  **是可复用的UI组件吗？** -> **必须**在`Components/`目录下创建或修改。
        3.  **是某个特定功能的主视图吗？** -> **必须**在`Views/`目录下创建或修改。
        4.  **是通用的辅助工具吗？** -> **必须**在`Utils/`目录下创建或修改。

*   **原则三：模块化导入 (Modular Imports)**
    *   **绝对禁止**编写`import TheDreamer.Models`或任何类似的、对项目内部模块的显式导入。
    *   你必须理解：在同一个App Target内，所有非私有的类型都是默认全局可见的。你只需要导入外部框架，如`SwiftUI`, `SwiftData`, `Charts`。

## 4. 数据模型蓝图 (SwiftData)
*   **`Subject`:** 学科 (name, totalScore, orderIndex)。
*   **`Exam`:** 考试实例 (name, date, totalScore) -> 关联`Subject`。
*   **`PracticeCollection`:** 练习合集 (name) -> 关联`Subject`。
*   **`Practice`:** 单次练习 (date, score, totalScore) -> 关联`PracticeCollection`。
*   **`Question`:** 题目实例 (questionNumber, score, totalScore) -> 关联`Exam`或`Practice`。
*   **`PaperTemplate`:** 卷子模板 (name) -> 关联`Subject`。
*   **`QuestionTemplate`:** 题目模板 (questionNumber, totalScore) -> 关联`PaperTemplate`。
*   **`QuestionType` & `CognitiveLaw`:** 题型与考法标签 (name)。

## 5. 可视化方案蓝图 (Swift Charts)
*   **折线图:** 核心图表，展示分数随时间的变化趋势，支持多条曲线（我的分数, 班级均分等）叠加。
*   **柱状图/叠层柱状图:** 用于单次考试的科目对比，或历次考试中各科分数贡献的比例变化。
*   **占比图 (扇形图/进度图):** 用于展示单次考试的得分率、科目/题型占比等静态构成。
*   **散点密度图:** 进阶图表，用于诊断不同分值、不同题型的得分效率。
*   **热力图:** 进阶图表，用于分析特定题型/考法的长期能力变化趋势。

## 6. 核心功能模块
*   `MainTabView`, `ManageSubjectsView`, `AddDataView`, `AnalysisView (V1)`, `DashboardView (V1)`, `OnBoardingView`, `TemplateManagementView`, `DetailedDataEntryView`, `DashboardView (V2+)`, `AnalysisView (V2+)`, `SearchFunctionalityView`。