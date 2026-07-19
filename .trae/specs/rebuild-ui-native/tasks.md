# Tasks

- [ ] Task 1: 清理 UI 工程边界，确认 `AddDataView Legacy.swift` 不进入 App Target，并盘点需要替换的自定义交互组件
  - [ ] 检查 Xcode Target membership 与文件系统同步例外
  - [ ] 标记 NativeGestures、UndoToastView、DataTypeCard 的替换范围
  - [ ] 编译验证基础工程仍可通过

- [ ] Task 2: 实现四标签原生主导航
  - [ ] 将默认标签设为「今天」
  - [ ] 接入「今天 / 分析 / 数据库 / 课程表」四个页面
  - [ ] 使用系统 `TabView`、`Label` 和 SF Symbols
  - [ ] 编译验证导航入口

- [ ] Task 3: 实现 Figma 今天页
  - [ ] 新建 `Views/Core/TodayView.swift`
  - [ ] 实现 Figma 339_3103 的标题、日期和内容滚动结构
  - [ ] 实现当前课程大卡：课程名、剩余时间、起止时间和 `ProgressView`
  - [ ] 按「接下来 / 中午 / 下午 / 晚修」分组显示课程行
  - [ ] 无课程时使用 `ContentUnavailableView`
  - [ ] 使用 SwiftData 课程表模型读取当前课程表

- [ ] Task 4: 实现 Figma 课程表页
  - [ ] 新建 `Views/Schedule/ScheduleView.swift`
  - [ ] 使用 `TabView`、`Picker` 或 `NavigationStack` 实现周视图切换
  - [ ] 展示当前课程表的周安排
  - [ ] 新建课程表为空时提供原生创建入口
  - [ ] 实现课程详情页布局，复用当前课程进度信息

- [ ] Task 5: 原生重构现有 UI 交互
  - [ ] 用 `swipeActions` 替换手写列表滑动手势
  - [ ] 用原生过渡与系统操作反馈替换自定义 Toast
  - [ ] 用 `ContentUnavailableView` 替换自定义空状态中可替换的部分
  - [ ] 保留业务功能，不改变 SwiftData 数据语义

- [ ] Task 6: 对齐 Figma 科目卡与分析页面
  - [ ] 调整 SubjectScoreCard 的系统材质、字体、间距和 SF Symbols
  - [ ] 调整 ClassRankingCard 的系统材质、字体、间距和图表区域
  - [ ] 保持 Swift Charts 数据逻辑与现有分析功能
  - [ ] 对照 Figma 截图完成视觉检查

- [ ] Task 7: 验证交付标准
  - [ ] 使用 Xcode 27 beta 与 `-disable-sandbox` 完成 clean build
  - [ ] 构建并安装到 iPhone 17 Pro 模拟器
  - [ ] 启动 App，验证四标签、今天页、课程表页可见
  - [ ] 对照 Figma 截图记录未完成或无法做到 1:1 的差异
  - [ ] 更新 checklist.md 并报告实际结果

# Task Dependencies

- Task 2 depends on Task 1.
- Task 3 depends on Task 2 and the existing ScheduleModels.
- Task 4 depends on Task 2 and the existing ScheduleModels.
- Task 5 can proceed in parallel with Tasks 3 and 4 after Task 1.
- Task 6 can proceed in parallel with Tasks 3 and 4 after Task 2.
- Task 7 depends on Tasks 1–6.
