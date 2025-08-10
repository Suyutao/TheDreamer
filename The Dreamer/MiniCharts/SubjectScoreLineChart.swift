import SwiftUI

// 科目分数折线图 - 可复用组件
struct SubjectScoreLineChart: View {
    let subjectName: String
    let score: Double
    let date: Date
    let iconSystemName: String
    
    // 格式化日期显示
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
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
                
                ZStack() {
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
    SubjectScoreLineChart(
        subjectName: "数学",
        score: 125.0,
        date: Date(),
        iconSystemName: "function"
    )
}
