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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: iconSystemName)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    Text(subjectName)
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                HStack(alignment: .top, spacing: 4) {
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("最新")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.60))
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(Int(score))")
                            .font(.system(size: 27, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("分")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 48)
                
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
            .frame(height: 52)
        }
        .padding(16)
        .frame(width: 360, height: 136)
        .background(Color(.secondarySystemBackground))
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
