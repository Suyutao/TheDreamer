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
            HStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: iconSystemName)
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(subjectName)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                HStack(alignment: .top, spacing: 2) {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("最新")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.60))
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(Int(score))")
                            .font(Font.custom("SF Pro Rounded", size: 27).weight(.semibold))
                            .foregroundColor(.primary)
                        Text("分")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 48)
                
                Spacer()
                
                ZStack() {
                    Text("图表预留处")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.60))
                        .offset(x: 0, y: 0.50)
                }
                .frame(width: 86)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .inset(by: 0.50)
                        .stroke(
                            Color.primary.opacity(0.12), lineWidth: 0.50
                        )
                )
            }
            .frame(height: 53)
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
        .padding(.bottom, 20)
        .frame(width: 362, height: 137)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(26)
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
