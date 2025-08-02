//
//  PieChartView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// 占比图组件 - 包含扇形图和进度图
// 直接看到某一次考试得分率，各科目占比，各题型占比等
// 适合查看任意一次考试，或者最近一次，或者统计全时间尺度上的平均占比

import SwiftUI
import Charts
import SwiftData

// MARK: - 数据模型

/// 占比图数据点
struct PieChartDataPoint: Identifiable {
    let id = UUID()
    let category: String      // 类别名称（科目、题型等）
    let value: Double        // 数值
    let totalValue: Double   // 总数值
    let color: Color         // 显示颜色
    let description: String? // 描述信息
    
    /// 占比百分比
    var percentage: Double {
        totalValue > 0 ? (value / totalValue) * 100 : 0
    }
    
    /// 角度（用于扇形图）
    var angle: Double {
        percentage * 3.6 // 360度对应100%
    }
}

/// 占比图类型
enum PieChartType {
    case pie        // 扇形图
    case donut      // 环形图
    case progress   // 进度图
}

/// 占比图数据类型
enum PieDataType {
    case scoreRate      // 得分率
    case subjectRatio   // 科目占比
    case questionType   // 题型占比
    case custom         // 自定义
}

// MARK: - 占比图组件

struct PieChartView: View {
    // MARK: - 参数
    let dataPoints: [PieChartDataPoint]
    let chartType: PieChartType
    let dataType: PieDataType
    let title: String
    let showPercentageLabels: Bool
    
    // MARK: - 状态
    @State private var selectedSegment: PieChartDataPoint?
    @State private var animationProgress: Double = 0
    
    // MARK: - 初始化
    init(
        dataPoints: [PieChartDataPoint],
        chartType: PieChartType = .pie,
        dataType: PieDataType = .scoreRate,
        title: String = "占比图",
        showPercentageLabels: Bool = true
    ) {
        self.dataPoints = dataPoints
        self.chartType = chartType
        self.dataType = dataType
        self.title = title
        self.showPercentageLabels = showPercentageLabels
    }
    
    // MARK: - 计算属性
    
    /// 总值
    private var totalValue: Double {
        dataPoints.reduce(0) { $0 + $1.value }
    }
    
    /// 标准化数据点（确保百分比总和为100%）
    private var normalizedDataPoints: [PieChartDataPoint] {
        guard totalValue > 0 else { return dataPoints }
        
        return dataPoints.map { point in
            PieChartDataPoint(
                category: point.category,
                value: point.value,
                totalValue: totalValue,
                color: point.color,
                description: point.description
            )
        }
    }
    
    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 图表标题
            chartHeader
            
            HStack(spacing: 20) {
                // 主图表
                chartView
                    .frame(width: 200, height: 200)
                
                // 图例和详细信息
                VStack(alignment: .leading, spacing: 8) {
                    legendView
                    
                    if let selected = selectedSegment {
                        selectedSegmentDetails(selected)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 图表标题
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(dataTypeDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// 数据类型描述
    private var dataTypeDescription: String {
        switch dataType {
        case .scoreRate:
            return "得分率分析"
        case .subjectRatio:
            return "科目占比分析"
        case .questionType:
            return "题型占比分析"
        case .custom:
            return "自定义分析"
        }
    }
    
    /// 主图表视图
    @ViewBuilder
    private var chartView: some View {
        switch chartType {
        case .pie:
            pieChartView
        case .donut:
            donutChartView
        case .progress:
            progressChartView
        }
    }
    
    /// 扇形图
    private var pieChartView: some View {
        Chart(normalizedDataPoints) { point in
            SectorMark(
                angle: .value("占比", point.percentage * animationProgress),
                innerRadius: .ratio(0),
                outerRadius: .ratio(0.8)
            )
            .foregroundStyle(point.color)
            .opacity(selectedSegment?.id == point.id ? 1.0 : (selectedSegment == nil ? 1.0 : 0.6))
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                Circle()
                    .fill(Color.clear)
                    .contentShape(Circle())
                    .onTapGesture { location in
                        handleChartTap(at: location, center: center, geometry: geometry)
                    }
            }
        }
    }
    
    /// 环形图
    private var donutChartView: some View {
        ZStack {
            Chart(normalizedDataPoints) { point in
                SectorMark(
                    angle: .value("占比", point.percentage * animationProgress),
                    innerRadius: .ratio(0.4),
                    outerRadius: .ratio(0.8)
                )
                .foregroundStyle(point.color)
                .opacity(selectedSegment?.id == point.id ? 1.0 : (selectedSegment == nil ? 1.0 : 0.6))
            }
            
            // 中心显示总值或选中项信息
            VStack(spacing: 4) {
                if let selected = selectedSegment {
                    Text(selected.category)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("\(selected.percentage, specifier: "%.1f")%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(selected.color)
                } else {
                    Text("总计")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(totalValue))")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSegment = nil
            }
        }
    }
    
    /// 进度图
    private var progressChartView: some View {
        VStack(spacing: 12) {
            ForEach(normalizedDataPoints) { point in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(point.category)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(point.percentage, specifier: "%.1f")%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(point.color)
                                .frame(
                                    width: geometry.size.width * (point.percentage / 100) * animationProgress,
                                    height: 8
                                )
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSegment = selectedSegment?.id == point.id ? nil : point
                        }
                    }
                }
            }
        }
    }
    
    /// 图例
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("图例")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ForEach(normalizedDataPoints) { point in
                HStack(spacing: 8) {
                    Circle()
                        .fill(point.color)
                        .frame(width: 12, height: 12)
                    
                    Text(point.category)
                        .font(.caption)
                    
                    Spacer()
                    
                    if showPercentageLabels {
                        Text("\(point.percentage, specifier: "%.1f")%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .opacity(selectedSegment?.id == point.id ? 1.0 : (selectedSegment == nil ? 1.0 : 0.6))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = selectedSegment?.id == point.id ? nil : point
                    }
                }
            }
        }
    }
    
    /// 选中片段的详细信息
    private func selectedSegmentDetails(_ segment: PieChartDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("详细信息")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("类别: \(segment.category)")
                Text("数值: \(Int(segment.value))")
                Text("占比: \(segment.percentage, specifier: "%.2f")%")
                
                if let description = segment.description {
                    Text("说明: \(description)")
                }
            }
            .font(.caption)
            .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
    
    // MARK: - 交互处理
    
    /// 处理图表点击
    private func handleChartTap(at location: CGPoint, center: CGPoint, geometry: GeometryProxy) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.8
        
        // 检查点击是否在图表范围内
        guard distance <= radius else {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSegment = nil
            }
            return
        }
        
        // 计算点击角度
        var angle = atan2(dy, dx) * 180 / .pi
        if angle < 0 {
            angle += 360
        }
        
        // 调整角度，使0度从顶部开始
        angle = angle + 90
        if angle >= 360 {
            angle -= 360
        }
        
        // 找到对应的数据片段
        var currentAngle: Double = 0
        for point in normalizedDataPoints {
            let segmentAngle = point.percentage * 3.6
            if angle >= currentAngle && angle < currentAngle + segmentAngle {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSegment = point
                }
                return
            }
            currentAngle += segmentAngle
        }
    }
}

// MARK: - 便利构造器

extension PieChartView {
    /// 创建得分率占比图
    static func scoreRateChart(
        exam: Exam,
        chartType: PieChartType = .donut
    ) -> PieChartView {
        let totalScore = exam.questions.reduce(0) { $0 + $1.score }
        let lostScore = exam.totalScore - totalScore
        
        let dataPoints = [
            PieChartDataPoint(
                category: "已得分",
                value: totalScore,
                totalValue: exam.totalScore,
                color: .green,
                description: "实际获得的分数"
            ),
            PieChartDataPoint(
                category: "失分",
                value: lostScore,
                totalValue: exam.totalScore,
                color: .red,
                description: "未获得的分数"
            )
        ]
        
        return PieChartView(
            dataPoints: dataPoints,
            chartType: chartType,
            dataType: .scoreRate,
            title: "\(exam.name) - 得分率分析"
        )
    }
    
    /// 创建科目占比图
    static func subjectRatioChart(
        exams: [Exam],
        chartType: PieChartType = .pie
    ) -> PieChartView {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan]
        let groupedExams = Dictionary(grouping: exams) { $0.subject?.name ?? "未知科目" }
        
        let dataPoints = groupedExams.enumerated().map { (index, element) in
            let (subject, subjectExams) = element
            let totalScore = subjectExams.reduce(0) { total, exam in
                total + exam.questions.reduce(0) { $0 + $1.score }
            }
            
            return PieChartDataPoint(
                category: subject,
                value: totalScore,
                totalValue: 0, // 将在normalizedDataPoints中重新计算
                color: colors[index % colors.count],
                description: "\(subjectExams.count)次考试"
            )
        }
        
        return PieChartView(
            dataPoints: dataPoints,
            chartType: chartType,
            dataType: .subjectRatio,
            title: "科目分数占比"
        )
    }
    
    /// 创建题型占比图
    static func questionTypeChart(
        exam: Exam,
        chartType: PieChartType = .progress
    ) -> PieChartView {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink]
        let groupedQuestions = Dictionary(grouping: exam.questions) { $0.type?.name ?? "未知题型" }
        
        let dataPoints = groupedQuestions.enumerated().map { (index, element) in
            let (type, questions) = element
            let totalScore = questions.reduce(0) { $0 + $1.score }
            let totalPoints = questions.reduce(0) { $0 + $1.points }
            
            return PieChartDataPoint(
                category: type,
                value: totalScore,
                totalValue: totalPoints,
                color: colors[index % colors.count],
                description: "\(questions.count)道题目"
            )
        }
        
        return PieChartView(
            dataPoints: dataPoints,
            chartType: chartType,
            dataType: .questionType,
            title: "\(exam.name) - 题型得分分析"
        )
    }
}

// MARK: - 预览

#Preview {
    let sampleData = [
        PieChartDataPoint(
            category: "数学",
            value: 85,
            totalValue: 300,
            color: .blue,
            description: "3次考试"
        ),
        PieChartDataPoint(
            category: "语文",
            value: 92,
            totalValue: 300,
            color: .green,
            description: "3次考试"
        ),
        PieChartDataPoint(
            category: "英语",
            value: 88,
            totalValue: 300,
            color: .orange,
            description: "3次考试"
        )
    ]
    
    return PieChartView(
        dataPoints: sampleData,
        chartType: .donut,
        dataType: .subjectRatio,
        title: "科目分数占比"
    )
    .padding()
}