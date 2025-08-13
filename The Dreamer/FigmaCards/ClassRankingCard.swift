import SwiftUI
import Charts

// MARK: - ClassRankingCard
/// Figma: 28_2838 班级排名卡片
/// 整合了RankLineChart的迷你图表功能
struct ClassRankingCard: View {
    let rank: Int
    let total: Int
    let date: Date
    
    // 可选的排名历史数据
    var rankSeries: [RankDataPoint] = []

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
                    Text("􀉪") // 人像图标
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    HStack(spacing: 0) {
                        Text("班级")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                        Text("排名")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                    }
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

            // 底部
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("最新")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(rank)")
                            .font(.system(size: 27, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("/\(total)人")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                // 迷你排名趋势图
                if rankSeries.isEmpty {
                    ZStack {
                        Text("图表预留处")
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
                    RankMiniChart(series: rankSeries)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

// MARK: - Supporting Types
/// 排名数据点
struct RankDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let rank: Int
    let total: Int
    
    /// 排名百分比（用于图表绘制，排名越靠前百分比越高）
    var rankPercentage: Double {
        total > 0 ? Double(total - rank + 1) / Double(total) * 100 : 0
    }
}

// MARK: - Mini Chart Component
private struct RankMiniChart: View {
    var series: [RankDataPoint]

    var body: some View {
        Chart {
            ForEach(series) { point in
                LineMark(
                    x: .value("时间", point.date),
                    y: .value("排名", point.rankPercentage)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .interpolationMethod(.catmullRom)
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
    // 示例排名数据
    let sampleRankData = [
        RankDataPoint(date: Date().addingTimeInterval(-86400*10), rank: 15, total: 20),
        RankDataPoint(date: Date().addingTimeInterval(-86400*5), rank: 12, total: 20),
        RankDataPoint(date: Date(), rank: 10, total: 20)
    ]
    
    VStack(spacing: 16) {
        ClassRankingCard(rank: 10, total: 20, date: Date(), rankSeries: sampleRankData)
        ClassRankingCard(rank: 3, total: 45, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }
    .padding()
}