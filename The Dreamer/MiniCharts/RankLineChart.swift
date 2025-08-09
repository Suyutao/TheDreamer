import SwiftUI

// 排名折线图 - 可复用组件（当前为静态UI占位，不含Swift Charts绘制）
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
            HStack(alignment: .top, spacing: 10) {
                HStack(alignment: .top, spacing: 2) {
                    Text("􀉪")
                        .font(.system(size: 12))
                        .lineSpacing(16)
                        .foregroundColor((.blue))
                    HStack(spacing: 0) {
                        Text("班级")
                            .font(.system(size: 12))
                            .lineSpacing(16)
                            .foregroundColor((.blue))
                        Text("排名")
                            .font(.system(size: 12))
                            .lineSpacing(16)
                            .foregroundColor((.blue))
                    }
                }
                HStack(alignment: .top, spacing: 2) {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .lineSpacing(16)
                        .foregroundColor(.secondary)
                    Text("􀆊")
                        .font(.system(size: 12))
                        .lineSpacing(16)
                        .foregroundColor(.secondary)
                }
            }
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("最新")
                        .font(.system(size: 12))
                        .lineSpacing(16)
                        .foregroundColor(.secondary)
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(rank)")
                            .font(Font.custom("SF Pro Rounded", size: 27).weight(.semibold))
                            .lineSpacing(22)
                            .foregroundColor(.primary)
                        Text("/\(total)人")
                            .font(.system(size: 12))
                            .lineSpacing(16)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 48)
                ZStack() {
                    Text("图表预留处")
                        .font(.system(size: 12))
                        .lineSpacing(16)
                        .foregroundColor(.secondary)
                        .offset(x: 0, y: 0.50)
                }
                .frame(width: 86)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .inset(by: 0.50)
                        .stroke(.secondary)
                )
            }
            .frame(height: 53)
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15))
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(26)
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
