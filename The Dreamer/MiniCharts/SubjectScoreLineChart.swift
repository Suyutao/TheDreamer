import SwiftUI

// 科目分数折线图 - 可复用组件
struct SubjectScoreLineChart: View {
    let subjectName: String
    let score: Double
    let date: Date
    let iconSystemName: String
    
    var body: some View {
        MiniChartCard {
            VStack(alignment: .leading, spacing: 10) {
                MiniChartHeader(
                    iconSystemName: iconSystemName,
                    title: subjectName,
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
        }
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
