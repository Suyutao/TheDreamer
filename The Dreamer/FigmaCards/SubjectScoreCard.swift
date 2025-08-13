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
    // 基本数据
    let subjectName: String
    let scoreText: String
    let date: Date
    var iconSystemName: String = "function"

    // 迷你图数据（可选）
    var miniSeries: [SubjectScoreLineChart.Series] = []

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
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        .frame(width: 86, height: 50)
                        .overlay(
                            Text("图表预留处")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        )
                } else {
                    // 复用现有迷你图样式：使用组件内部的微型绘制区域
                    SubjectScoreMiniChart(series: miniSeries)
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
    var series: [SubjectScoreLineChart.Series]

    var body: some View {
        // 仅绘制线，不展示坐标
        ChartContainer(series: series)
            .frame(width: 86, height: 50)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
    }
}

// MARK: - ChartContainer（极简绘制）
private struct ChartContainer: View {
    var series: [SubjectScoreLineChart.Series]

    var body: some View {
        Chart {
            ForEach(series) { s in
                ForEach(s.dataPoints) { p in
                    LineMark(
                        x: .value("时间", p.date),
                        y: .value("分数", p.score)
                    )
                    .foregroundStyle(s.type.color)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: s.type.isDashed ? [3,2] : []))
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
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
    let s: [SubjectScoreLineChart.Series] = [ .init(name: "我的分数", type: .myScore, dataPoints: points) ]

    return VStack {
        SubjectScoreCard(subjectName: "数学", scoreText: "125", date: Date(), miniSeries: s)
        SubjectScoreCard(subjectName: "数学", scoreText: "125", date: Date(), miniSeries: [])
    }
    .padding()
}