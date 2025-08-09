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
            HStack(alignment: .top, spacing: 10) {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1, green: 0.55, blue: 0.16))
                    Text(subjectName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1, green: 0.55, blue: 0.16))
                }
                HStack(alignment: .top, spacing: 2) {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                }
            }
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("最新")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.60))
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(Int(score))")
                            .font(Font.custom("SF Pro Rounded", size: 27).weight(.semibold))
                            .foregroundColor(.black)
                        Text("分")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    }
                }
                .frame(height: 48)
                ZStack() {
                    Text("图表预留处")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.60))
                        .offset(x: 0, y: 0.50)
                }
                .frame(width: 86)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .inset(by: 0.50)
                        .stroke(
                            Color(red: 0, green: 0, blue: 0).opacity(0.12), lineWidth: 0.50
                        )
                )
            }
            .frame(height: 53)
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15))
        .frame(width: 362, height: 137)
        .background(.white)
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
