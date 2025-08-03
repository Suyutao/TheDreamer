# 数据完整性检查与清理指南

## 概述

这是一个临时的数据清理功能，用于解决在修复SwiftData关系约束之前产生的异常数据引用问题。当你删除科目后仍然遇到崩溃时，可以使用此功能清理所有无效的数据引用。

## 功能说明

### 自动检查（首次启动）
- App会在首次启动时自动执行数据完整性检查
- 检查完成后会在控制台输出日志信息
- 后续启动将跳过自动检查，除非手动触发

### 手动触发清理
1. 打开App，进入任意标签页
2. 导航到「管理科目」页面
3. 点击工具栏中的垃圾桶图标（🗑️）
4. 系统会提示重启应用以执行清理
5. 重启App，清理操作将自动执行

## 清理范围

该功能会检查并清理以下数据中的无效Subject引用：

1. **PaperStructure** - 卷子结构数据
2. **PaperTemplate** - 卷子模板数据  
3. **Exam** - 考试实例数据
4. **PracticeCollection** - 练习合集数据
5. **Practice** - 单次练习数据

## 日志信息

清理过程中会在控制台输出详细的日志信息：

```
[时间戳] 开始执行数据完整性检查...
[时间戳] 清理了 X 个无效的 PaperStructure
[时间戳] 清理了 X 个无效的 PaperTemplate
[时间戳] 清理了 X 个无效的 Exam
[时间戳] 清理了 X 个无效的 PracticeCollection
[时间戳] 清理了 X 个无效的 Practice
[时间戳] 数据完整性检查完成，所有异常数据已清理
```

## 注意事项

⚠️ **重要提醒**：
- 这是一个临时功能，主要用于清理历史遗留的异常数据
- 清理操作会永久删除无效的数据引用，无法恢复
- 建议在清理前备份重要数据
- 清理完成后，相关的崩溃问题应该得到解决

## 技术细节

### UserDefaults标志
- `HasPerformedInitialDataCheck`: 标记是否已完成首次检查
- `ShouldPerformDataIntegrityCheck`: 标记是否需要执行手动检查

### 实现位置
- 主要逻辑：`MainTabView.swift` 中的 `performDataIntegrityCheck()` 函数
- 手动触发：`ManageSubjectsView.swift` 中的 `triggerDataIntegrityCheck()` 函数

---

*此功能是为了解决特定的数据完整性问题而临时添加的，未来版本中可能会被移除或重构。*