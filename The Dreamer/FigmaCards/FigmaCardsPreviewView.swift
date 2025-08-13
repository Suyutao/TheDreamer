import SwiftUI

// MARK: - FigmaCardsPreviewView
/// 展示Figma卡片组件的预览页面，用于测试和演示
struct FigmaCardsPreviewView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {// 科目分数卡片示例
                    Group {
                        Text("科目分数卡片 (28_2000)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        // 带图表数据的卡片
                        SubjectScoreCard(
                            subjectName: "数学",
                            scoreText: "125",
                            date: Date(),
                            iconSystemName: "function",
                            miniSeries: [
                                .init(
                                    name: "我的分数",
                                    type: .myScore,
                                    dataPoints: [
                                        ChartDataPoint(date: Date().addingTimeInterval(-86400*10), score: 120, totalScore: 150, examName: "周练", subject: "数学", type: .myScore),
                                        ChartDataPoint(date: Date().addingTimeInterval(-86400*5), score: 125, totalScore: 150, examName: "月考", subject: "数学", type: .myScore),
                                        ChartDataPoint(date: Date(), score: 130, totalScore: 150, examName: "期中", subject: "数学", type: .myScore)
                                    ]
                                )
                            ]
                        )
                        .padding(.horizontal)

                        // 空状态卡片
                        SubjectScoreCard(
                            subjectName: "英语",
                            scoreText: "98",
                            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                            iconSystemName: "textformat.abc",
                            miniSeries: []
                        )
                        .padding(.horizontal)
                    }

                    // 班级排名卡片示例
                    Group {
                        Text("班级排名卡片 (28_2838)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)

                        ClassRankingCard(
                            rank: 10,
                            total: 20,
                            date: Date()
                        )
                        .padding(.horizontal)

                        ClassRankingCard(
                            rank: 3,
                            total: 45,
                            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Figma 卡片预览")
            .navigationSubtitle("基于Figma设计文件28_2000和28_2838的SwiftUI实现")
        }
    }
}

#Preview {
    FigmaCardsPreviewView()
}