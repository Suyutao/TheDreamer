import SwiftUI

// MARK: - ClassRankingCard
/// Figma: 28_2838 班级排名卡片
struct ClassRankingCard: View {
    let rank: Int
    let total: Int
    let date: Date

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

                // 集成RankLineChart样式的迷你图表占位
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
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 16) {
        ClassRankingCard(rank: 10, total: 20, date: Date())
    }
    .padding()
}