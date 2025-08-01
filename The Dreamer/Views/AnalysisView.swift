//
//  AnalysisView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了应用的数据分析视图界面。
// 它显示用户记录的所有考试和练习数据，并提供添加新数据和管理科目与模板的功能。

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - body: View的必需属性，定义了界面的具体内容
// - State: 用于管理视图内部的状态变量
// - Environment: 用于访问应用程序级别的环境信息
// - Query: 用于从数据库查询数据
// - NavigationView: 提供导航栏和层级导航的容器视图
// - List: 用于显示列表数据的视图
// - Sheet: 以弹窗形式显示的视图

// 导入构建用户界面所需的SwiftUI框架
import SwiftUI
// 导入用于数据存储和管理的SwiftData框架
import SwiftData

// 定义一个结构体，表示数据分析视图界面
struct AnalysisView: View {
    // 获取应用程序的数据存储上下文，用于数据操作
    // modelContext是SwiftData提供的环境变量，用于执行数据的增删改查操作
    @Environment(\.modelContext) private var modelContext
        
    // [V39] 使用@Query获取所有Exam记录，并按日期倒序排序
    // 从数据库中查询所有考试记录，并按日期从新到旧排序
    // @Query是SwiftData提供的属性包装器，用于自动查询数据
    // \Exam.date表示按Exam结构体的date属性排序
    // order: .reverse表示倒序排列（最新的在前）
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
    
    // 添加状态变量来控制是否按科目分组
    @State private var groupBySubject = false
    
    // [V1] 添加状态变量来存储要添加的数据类型
    // 定义一个状态变量，用于存储用户选择要添加的数据类型（考试或练习）
    // @State是SwiftUI提供的属性包装器，用于管理视图的状态
    @State private var addableDataType: AddableDataType? = nil
    
    // 定义一个状态变量，用于控制添加数据界面是否显示
    // showingAddDataSheet的初始值为false，表示默认不显示
    @State private var showingAddDataSheet = false
    
    // 定义一个状态变量，用于控制管理科目与模板界面是否显示
    // showingManageSheet的初始值为false，表示默认不显示
    @State private var showingManageSheet = false // 新增：控制管理科目与模板sheet的显示
    
    
    // 定义视图的主要内容
    // body是View协议要求实现的属性，定义了界面的具体内容
    var body: some View {
        // 创建一个导航视图，用于管理视图间的导航
        // NavigationView提供导航栏和返回按钮等功能
        NavigationView {
            // ZStack允许视图堆叠显示
            // ZStack是一个容器，可以将多个视图在Z轴方向上堆叠
            ZStack {
                // [V39] 如果没有数据，显示空状态
                // 检查是否有考试记录，如果没有则显示空状态提示
                // exams.isEmpty检查考试记录数组是否为空
                if exams.isEmpty {
                    // 显示空状态视图，提示用户添加数据
                    // EmptyStateView是在CommonComponents.swift中定义的组件
                    EmptyStateView(
                        iconName: "tray.fill", // 显示的图标名称
                        title: "暂无成绩记录",   // 主标题
                        message: "点击右上角的\"添加数据\"按钮，开始记录你的第一次成绩吧！" // 详细说明
                    )
                } else {
                    // [V39] 列表显示所有成绩
                    // 如果有考试记录，则显示在列表中
                    // List用于显示一组数据
                    if groupBySubject {
                        // 按科目分组显示
                        List {
                            // 先获取所有有考试的科目
                            let subjects = Array(Set(exams.compactMap { $0.subject })).sorted { $0.name < $1.name }
                            
                            ForEach(subjects) { subject in
                                Section(header: Text(subject.name)) {
                                    // 获取该科目的所有考试
                                    let subjectExams = exams.filter { $0.subject?.id == subject.id }
                                    
                                    ForEach(subjectExams) { exam in
                                        // 显示考试记录的行视图
                                        // ExamRowView是在当前文件中定义的组件
                                        ExamRowView(exam: exam)
                                    }
                                    // 为列表项添加删除功能
                                    // .onDelete是SwiftUI提供的修饰符，用于处理删除操作
                                    .onDelete { indices in
                                        deleteExams(at: indices, in: subjectExams)
                                    }
                                }
                            }
                        }
                    } else {
                        // 按时间排序显示（原有逻辑）
                        List {
                            // 遍历所有考试记录，为每条记录创建一个行视图
                            // ForEach是SwiftUI中的循环结构，用于遍历数组
                            ForEach(exams) { exam in
                                // 显示考试记录的行视图
                                // ExamRowView是在当前文件中定义的组件
                                ExamRowView(exam: exam)
                            }
                            // 为列表项添加删除功能
                            // .onDelete是SwiftUI提供的修饰符，用于处理删除操作
                            .onDelete(perform: deleteExam)
                        }
                    }
                }
            }
            // 设置导航栏标题
            // navigationTitle用于设置导航栏的标题文本
            .navigationTitle("所有数据")
            // 添加工具栏按钮
            // toolbar用于在导航栏上添加额外的按钮
            .toolbar {
                // 左上角的视图管理菜单
                // ToolbarItem定义工具栏上的一个项目
                // placement: .topBarLeading表示放置在左上角
                ToolbarItem(placement: .topBarLeading) {
                    // 创建一个下拉菜单
                    // Menu用于创建下拉菜单
                    Menu {
                        // 这里将放置我们V20讨论过的视图切换选项
                        // 按科目分组查看数据的按钮（功能待实现）
                        // Button用于创建一个可点击的按钮
                        Button("按科目分组", action: { groupBySubject = true })
                        // 按时间排序查看数据的按钮（功能待实现）
                        Button("按时间排序", action: { groupBySubject = false })
                        
                        // 在菜单中添加分割线
                        // Divider用于在菜单中添加一条分隔线
                        Divider()
                        
                        // 管理科目与模板的按钮，点击时显示管理界面
                        // 当用户点击此按钮时，将showingManageSheet设置为true以显示管理界面
                        Button("管理科目与模板...", action: { showingManageSheet = true }) // 修改：设置action为显示sheet
                        
                    } label: {
                        // 菜单的图标
                        // label定义菜单按钮的显示内容
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                // 右上角的添加数据菜单
            // placement: .primaryAction表示放置在右上角的主要操作位置
            ToolbarItem(placement: .primaryAction) {
                // 创建一个下拉菜单
                Menu {
                    // 添加考试的按钮
                    // 当用户点击此按钮时，设置数据类型为考试并显示添加界面
                    Button("添加考试") {
                        // 先设置数据类型
                        addableDataType = .exam
                        // 延迟显示sheet确保状态更新
                        DispatchQueue.main.async { showingAddDataSheet = true }
                    }
                    
                    // 添加练习的按钮
                    // 当用户点击此按钮时，设置数据类型为练习并显示添加界面
                    Button("添加练习") {
                        // 先设置数据类型
                        addableDataType = .practice
                        // 延迟显示sheet确保状态更新
                        DispatchQueue.main.async { showingAddDataSheet = true }
                    }
                } label: {
                    // 菜单的文本标签
                    Text("添加数据")
                }
            }
            }
            // 添加数据界面的弹窗
            // sheet用于以弹窗形式显示视图
            // isPresented: $showingAddDataSheet绑定状态变量，控制弹窗显示
            .sheet(isPresented: $showingAddDataSheet) {
                // [V39] 关键：为弹出的Sheet注入modelContext环境
                // 显示添加数据界面，并传递数据类型和数据存储上下文
                // AddDataView是在其他文件中定义的视图
                AddDataView(dataType: $addableDataType)
                    // 为弹出的视图注入modelContext环境变量
                    .environment(\.modelContext, modelContext)
            }
            // 管理科目与模板界面的弹窗
            // isPresented: $showingManageSheet绑定状态变量，控制弹窗显示
            .sheet(isPresented: $showingManageSheet) { // 新增：管理科目与模板的sheet
                // 显示管理科目界面，并传递数据存储上下文
                // ManageSubjectsView是在其他文件中定义的视图
                ManageSubjectsView()
                    // 为弹出的视图注入modelContext环境变量
                    .environment(\.modelContext, modelContext)
            }
        }
    }
    
    // 删除考试记录的函数
    // private表示此函数只能在当前结构体内访问
    // func表示这是一个函数定义
    // deleteExam是函数名
    // at offsets: IndexSet表示参数，IndexSet是索引集合类型
    private func deleteExam(at offsets: IndexSet) {
        // 遍历要删除的索引集合
        // for循环用于遍历集合中的每个元素
        for index in offsets {
            // 从数据存储中删除指定索引的考试记录
            // modelContext.delete用于删除数据
            // exams[index]获取指定索引的考试记录
            modelContext.delete(exams[index])
        }
    }
    
    // 新增：删除特定科目下的考试记录
    private func deleteExams(at offsets: IndexSet, in subjectExams: [Exam]) {
        for index in offsets {
            if let examIndex = exams.firstIndex(where: { $0.id == subjectExams[index].id }) {
                modelContext.delete(exams[examIndex])
            }
        }
    }
}

// [V39] 创建一个简单的行视图来显示成绩
// 定义一个结构体，表示考试记录的行视图
struct ExamRowView: View {
    // 接收一个考试记录作为参数
    // let表示常量，exam是参数名，Exam是参数类型
    let exam: Exam
    
    // 定义视图的主要内容
    var body: some View {
        // 创建一个水平堆栈布局
        // HStack用于水平排列子视图
        HStack {
            // 创建一个垂直堆栈布局，左对齐
            // VStack用于垂直排列子视图
            // alignment: .leading表示左对齐
            VStack(alignment: .leading) {
                // 显示考试名称
                // Text用于显示文本
                // .font(.headline)设置字体样式
                Text(exam.name)
                    .font(.headline)
                // 显示科目名称，如果没有关联科目则显示"未知科目"
                // exam.subject?.name表示如果有subject则显示其name，否则为nil
                // ?? "未知科目"表示如果前面的值为nil，则显示"未知科目"
                // .font(.subheadline)设置字体样式
                // .foregroundColor(.secondary)设置文字颜色为次要颜色
                Text(exam.subject?.name ?? "未知科目")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            // 添加弹性空间，将左右两部分分开
            // Spacer用于填充可用空间
            Spacer()
            // 创建一个垂直堆栈布局，右对齐
            // alignment: .trailing表示右对齐
            VStack(alignment: .trailing) {
                // 显示考试总分，保留一位小数
                // "\(exam.totalScore, specifier: "%.1f")"是字符串插值，格式化数字
                // .font(.title2)设置字体样式
                // .fontWeight(.bold)设置字体粗细
                Text("\(exam.totalScore, specifier: "%.1f")")
                    .font(.title2)
                    .fontWeight(.bold)
                // 显示考试日期
                // .date样式会自动格式化日期
                // .font(.caption)设置字体样式
                // .foregroundColor(.secondary)设置文字颜色为次要颜色
                Text(exam.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        // 为行视图添加垂直内边距
        // .padding(.vertical, 4)在垂直方向上添加4点内边距
        .padding(.vertical, 4)
    }
}

// 预览代码，用于在设计时预览界面效果
// #Preview是Xcode提供的预览功能
#Preview {
    // 创建AnalysisView实例以进行预览
    AnalysisView()
}
