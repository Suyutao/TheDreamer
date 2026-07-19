# 验收清单

## 已在模拟器截图确认
- [x] App 在 iPhone 17 Pro 模拟器成功安装并启动
- [x] 主界面显示四个原生 Tab：今天、分析、数据库、课程表
- [x] 默认进入「今天」标签，底部原生 Tab Bar 可见
- [x] 没有课程数据时，今天页显示原生 ContentUnavailableView

## 已由 clean build + 代码确认
- [x] clean build 成功（Xcode 27 beta + -disable-sandbox）
- [x] AddDataView Legacy.swift 不进入 App Target
- [x] 可替换的自定义手势已移除，NativeGestures.swift（UIKit）已排除出 Target
- [x] SubjectScoreCard / ClassRankingCard 使用原生 SwiftUI + Swift Charts，图标改用 SF Symbols
- [x] 不引入 UIKit/AppKit 布局；UserDefaults 仅用于完整性检查标志位，不承载业务数据
- [x] 今天页当前课程卡在代码层实现课程名、剩余时间、起止时间和原生 ProgressView
- [x] 分析页沿用 DashboardAnalysisView，数据库页沿用 Database，功能保留
- [x] 课程表页含周视图、无数据空状态与创建入口；课程详情 Sheet 含进度信息

## 未在模拟器逐一可视验证（缺少课程表样例数据，无法呈现真实排课界面）
- [ ] 今天页当前课程卡在真实数据下与 Figma 339_3103 的 1:1 视觉比对
- [ ] 课程表页周安排在真实数据下的显示
- [ ] 课程详情页在真实数据下的显示
- [ ] Tab 间切换与各页填充数据后的最终视觉走查
