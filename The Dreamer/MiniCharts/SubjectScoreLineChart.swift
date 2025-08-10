import SwiftUI
import Charts

// 科目分数折线图 - 可复用组件（增强版 E1.2）
struct SubjectScoreLineChart: View {
    // 输入数据：允许 1-3 条线条类型
    struct Series: Identifiable {
        let id = UUID()
        let name: String
        let type: LineType // 复用 Charts/LineChartView.swift 的 LineType
        let dataPoints: [ChartDataPoint]
    }
    
    // 基本信息（兼容原调用）
    let subjectName: String
    let score: Double
    let date: Date
    let iconSystemName: String
    
    // 新增：序列集合（默认仅我的分数）
    var series: [Series] = []
    
    // 新增：是否将Y轴显示为百分比
    var showYAxisAsPercentage: Bool = false
    
    // 格式化日期显示
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    // 判空
    private var isEmpty: Bool { series.flatMap { $0.dataPoints }.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: iconSystemName)
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                    Text(subjectName)
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 6) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.85))
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary.opacity(0.60))
                }
            }
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("最新")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary.opacity(0.50))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(score))")
                            .font(.system(size: 27, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("分")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary.opacity(0.50))
                    }
                }
                
                Spacer()
                
                // 迷你折线图
                if isEmpty {
                    ZStack {
                        Text("暂无数据")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.60))
                    }
                    .frame(width: 86, height: 50)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                    .allowsHitTesting(false)
                } else {
                    Chart {
                        ForEach(series) { s in
                            ForEach(s.dataPoints) { p in
                                LineMark(
                                    x: .value("时间", p.date),
                                    y: .value("分数", showYAxisAsPercentage ? p.scoreRate : p.score)
                                )
                                .foregroundStyle(s.type.color)
                                .lineStyle(StrokeStyle(
                                    lineWidth: 1.5,
                                    dash: s.type.isDashed ? [3, 2] : []
                                ))
                                .interpolationMethod(.catmullRom)
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    // .chartYScale(domain: showYAxisAsPercentage ? 0...100 : .automatic)
                    .frame(width: 86, height: 50)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                    .allowsHitTesting(false)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    // 示例数据
    let points = [
        ChartDataPoint(date: Date().addingTimeInterval(-86400 * 10), score: 120, totalScore: 150, examName: "周练", subject: "数学", type: .myScore),
        ChartDataPoint(date: Date().addingTimeInterval(-86400 * 5), score: 125, totalScore: 150, examName: "月考", subject: "数学", type: .myScore),
        ChartDataPoint(date: Date(), score: 130, totalScore: 150, examName: "期中", subject: "数学", type: .myScore)
    ]
    return SubjectScoreLineChart(
        subjectName: "数学",
        score: 130,
        date: Date(),
        iconSystemName: "function",
        series: [
            .init(name: "我的分数", type: .myScore, dataPoints: points)
        ]
    )
}
