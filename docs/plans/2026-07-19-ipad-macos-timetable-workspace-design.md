# iPad 与 macOS 课程表工作区设计

## 目标

为 iPad 和 macOS 提供适合大屏的课程表管理与编辑界面。iPad 支持横竖屏、分屏和 Stage Manager，macOS 支持原生侧边栏、表格、键盘命令和独立课程表窗口。iPhone 继续使用现有逐层导航与 Sheet。visionOS 本阶段只保持原生目标编译兼容，不增加独立空间界面。

## 平台结构

主窗口中的课程表管理入口使用自适应工作区。宽屏采用三栏 `NavigationSplitView`：左栏选择课程表或课程库，中栏显示所选分类的对象集合，右栏常驻显示所选对象的编辑器。紧凑宽度由 `NavigationSplitView` 自动转换为逐层导航。

macOS 的课程安排集合使用 `Table`，列出星期、时间、课程、教师、地点和重复规则。iPad 使用支持选择、上下文菜单和 `swipeActions` 的 `List`。两个平台共用选择类型、编辑内容和保存逻辑，不复制业务实现。

## 选择与编辑

工作区保存当前课程表、内容分类和当前对象三个层级的选择。内容分类包括课程安排、节次、日期调整和课程库。

编辑已有对象时，宽屏在右栏显示表单；新建对象仍使用 Sheet。表单使用本地 `@State` 保存草稿，用户执行保存后才修改 SwiftData。保存成功后保持当前选择，其他窗口通过共享 `ModelContainer` 观察变化。

macOS 提供 `Command-N` 新建课程安排、`Command-S` 保存当前编辑器和 `Delete` 删除当前对象。iPad 使用工具栏和上下文菜单提供相同行为，不显示键盘操作说明文字。

## 多窗口

每张课程表可以从管理列表或课程表详情中选择“在新窗口中打开”。App 增加以 `PersistentIdentifier` 为值的 `WindowGroup`。`PersistentIdentifier` 已由当前 Xcode SDK 确认符合 `Codable` 与 `Hashable`，因此不新增模型字段，也不改变历史 SwiftData schema。

独立窗口使用同一个 `ModelContainer`，并通过 `ModelContext.registeredModel(for:)` 取得课程表。目标课程表不存在或已被其他窗口删除时，窗口显示 `ContentUnavailableView`。

## 数据与系统同步

SwiftData 继续是唯一业务数据来源。编辑保存后再刷新 EventKit 与本地通知。SwiftData 保存失败时保留表单草稿；本地保存成功但系统同步失败时显示明确错误，不撤销已保存数据。

导入、导出、复制和删除都以明确选中的课程表为目标。删除存在 `CalendarExportRecord` 的对象时，继续提供删除系统日历事件或仅删除应用数据的选择。

## 验证

- iPad：横屏、竖屏、窄分屏和 Stage Manager 尺寸下检查分栏折叠、选择和表单布局。
- macOS：检查原生侧边栏、课程安排表格、独立窗口、窗口间数据更新和键盘命令。
- iPhone：回归课程表按天浏览与现有 Sheet 编辑流程。
- visionOS：仅执行原生 `xros` 目标编译，确认新增窗口声明和平台条件不会破坏兼容性。
- 数据：运行现有课程表解析、复制、归档与 SwiftData 关系测试。
