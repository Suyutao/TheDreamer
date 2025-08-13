import SwiftUI
import Charts

// MARK: - SubjectScoreCard
/// Figma: 28_2000 科目分数卡片
/// 视觉还原点：
/// - 左上角：功能符号 + 学科名（橙色重色）
/// - 右上角：日期 + chevron
/// - 左下："最新" 标签 + 数值与单位
/// - 右下：迷你折线图占位（使用内置迷你图组件或空态框）
struct SubjectScoreCard: View {
    // 科目分数序列数据类型定义（从 SubjectScoreLineChart 迁移）
    struct Series: Identifiable {
        let id = UUID()
        let name: String
        let type: LineType // 复用 Charts/LineChartView.swift 的 LineType
        let dataPoints: [ChartDataPoint]
    }
    
    // 基本数据
    let subjectName: String
    let scoreText: String
    let date: Date
    var iconSystemName: String = "function"

    // 迷你图数据（可选），支持完整的系列数据
    var miniSeries: [Series] = []
    
    // 新增：是否将Y轴显示为百分比（从 SubjectScoreLineChart 迁移）
    var showYAxisAsPercentage: Bool = false

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 12) {
            // 顶部栏
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: iconSystemName)
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                    Text(subjectName)
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                }
                Spacer()
                HStack(spacing: 6) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.85))
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary.opacity(0.85))
                }
            }

            // 底部区域
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("最新")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(scoreText)
                            .font(.system(size: 27, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("分")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                // 右侧迷你图/占位
                if miniSeries.flatMap({ $0.dataPoints }).isEmpty {
                    ZStack {
                        Text("暂无数据")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.60))
                    }
                    .frame(width: 86, height: 50)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondary.opacity(0.30), lineWidth: 1)
                    )
                } else {
                    // 使用优化的内联迷你图实现，支持百分比显示
                    SubjectScoreMiniChart(series: miniSeries, showYAxisAsPercentage: showYAxisAsPercentage)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

// MARK: - Mini Chart Wrapper
private struct SubjectScoreMiniChart: View {
    var series: [SubjectScoreCard.Series]
    var showYAxisAsPercentage: Bool = false

    var body: some View {
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
        .frame(width: 86, height: 50)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.secondary.opacity(0.30), lineWidth: 1)
        )
        .allowsHitTesting(false)
    }
}

#Preview {
    // 示例数据
    let points = [
        ChartDataPoint(date: Date().addingTimeInterval(-86400*10), score: 120, totalScore: 150, examName: "周练", subject: "数学", type: .myScore),
        ChartDataPoint(date: Date().addingTimeInterval(-86400*5), score: 125, totalScore: 150, examName: "月考", subject: "数学", type: .myScore),
        ChartDataPoint(date: Date(), score: 130, totalScore: 150, examName: "期中", subject: "数学", type: .myScore)
    ]
    let s: [SubjectScoreCard.Series] = [ .init(name: "我的分数", type: .myScore, dataPoints: points) ]

    return VStack {
        SubjectScoreCard(subjectName: "数学", scoreText: "125", date: Date(), miniSeries: s)
        SubjectScoreCard(subjectName: "数学", scoreText: "125", date: Date(), miniSeries: [])
    }
    .padding()
}