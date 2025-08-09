import SwiftUI

// 排名折线图
struct RankLineChart: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top, spacing: 10) {
        HStack(alignment: .top, spacing: 2) {
          Text("􀉪")
            .font(.system(size: 12))
            .lineSpacing(16)
            .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
          HStack(spacing: 0) {
            Text("班级")
              .font(.system(size: 12))
              .lineSpacing(16)
              .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
            Text("排名")
              .font(.system(size: 12))
              .lineSpacing(16)
              .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
          }
        }
        HStack(alignment: .top, spacing: 2) {
          Text("6月25日")
            .font(.system(size: 12))
            .lineSpacing(16)
            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
          Text("􀆊")
            .font(.system(size: 12))
            .lineSpacing(16)
            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
        }
      }
      HStack(alignment: .bottom, spacing: 10) {
        VStack(alignment: .leading, spacing: 7) {
          Text("最新")
            .font(.system(size: 12))
            .lineSpacing(16)
            .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.60))
          HStack(alignment: .bottom, spacing: 2) {
            Text("10")
              .font(Font.custom("SF Pro Rounded", size: 27).weight(.semibold))
              .lineSpacing(22)
              .foregroundColor(.black)
            ZStack() {
              Text("/")
                .font(Font.custom("SF Pro Rounded", size: 15).weight(.semibold))
                .lineSpacing(22)
                .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.60))
                .offset(x: -18, y: -0.50)
              ZStack() {
                Text("20")
                  .font(Font.custom("SF Pro Rounded", size: 15).weight(.semibold))
                  .lineSpacing(22)
                  .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.60))
                  .offset(x: -7, y: -0.50)
                Text("人")
                  .font(Font.custom("PingFang SC", size: 12).weight(.semibold))
                  .lineSpacing(22)
                  .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                  .offset(x: 9, y: -0.50)
              }
              .frame(width: 34, height: 17)
              .offset(x: 4, y: 0.50)
            }
            .frame(width: 42, height: 18)
          }
        }
        .frame(height: 48)
        ZStack() {
          Text("图表预留处")
            .font(.system(size: 12))
            .lineSpacing(16)
            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
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
    .cornerRadius(26);
  }
}

#Preview {
  RankLineChart()
}
