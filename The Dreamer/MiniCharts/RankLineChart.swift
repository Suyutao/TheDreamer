import SwiftUI

// 排名折线图 - 可复用组件（样式与 SubjectScoreLineChart 保持一致）
struct RankLineChart: View {
    let rank: Int
    let total: Int
    let date: Date
    
    var body: some View {
        MiniChartCard {
            VStack(alignment: .leading, spacing: 10) {
                MiniChartHeader(
                    iconSystemName: "trophy.fill",
                    title: "班级排名",
                    date: date,
                    accentColor: .orange,
                    showChevron: true
                )
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("最新")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary.opacity(0.50))
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(rank)")
                                .font(.system(size: 27, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("/\(total)人")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary.opacity(0.50))
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Text("图表预留处")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.60))
                            .offset(x: 0, y: 0.50)
                    }
                    .frame(width: 86)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.50)
                            .stroke(
                                Color.primary.opacity(0.12), lineWidth: 0.50
                            )
                    )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        RankLineChart(rank: 10, total: 20, date: Date())
        RankLineChart(rank: 3, total: 45, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
