import SwiftUI

// 排名折线图 - 可复用组件（样式与 SubjectScoreLineChart 保持一致）
struct RankLineChart: View {
    let rank: Int
    let total: Int
    let date: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 头部：图标 + 标题 | 日期 + 导航箭头
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                    Text("班级排名")
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
            
            // 主体：最新排名 + 图表占位
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
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
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
