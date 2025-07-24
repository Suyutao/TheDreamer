//
//  DataDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//

import SwiftData
import SwiftUI

struct DataDetailView: View {
    var score: SubjectScore
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("科目：\(score.subject)")
            Text("分数：\(score.score)")
            Text("满分：\(score.fullScore)")
            Text("备注：\(score.remark ?? "无")")
            Text("是否大考：\(score.isUnited ? "是" : "否")")
            Text("是否赋分：\(score.isCurved ? "是" : "否")")
            Text("班级排名：\(score.classRank ?? 0)")
            Text("班级总人数：\(score.classTotal ?? 0)")
            Text("年级排名：\(score.gradeRank ?? 0)")
            Text("年级总人数：\(score.gradeTotal ?? 0)")
        }
        .padding()
        .navigationTitle("成绩详情")
    }
}

#Preview {
    DataDetailView(score: SubjectScore(
        isUnited: false,
        subject: "数学",
        score: 120,
        fullScore: 150,
        isCurved: false,
        isElective: false,
        scoreRatio: 120.0 / 150.0,
        remark: "期中考"
    ))
}
