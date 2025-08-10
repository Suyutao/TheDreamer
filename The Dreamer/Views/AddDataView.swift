// AddDataView.swift (V18 Final Corrected Version)
// 这个文件定义了一个用于添加考试或练习数据的界面

// 功能简介：
// 这个文件实现了添加考试或练习数据的功能界面。
// 用户可以通过这个界面输入考试或练习的详细信息，并将其保存到数据库中。

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - enum: 枚举类型，用于定义一组相关的值
// - State: 用于管理视图内部的状态变量
// - Environment: 用于访问应用程序级别的环境信息
// - Query: 用于从数据库查询数据
// - NavigationView: 提供导航栏和层级导航的容器视图
// - Form: 用于组织输入控件的容器视图
// - TextField: 文本输入框控件
// - DatePicker: 日期选择器控件
// - Picker: 下拉选择器控件
// - Button: 按钮控件

// 导入构建用户界面所需的SwiftUI框架
import SwiftUI
// 导入用于数据存储和管理的SwiftData框架
import SwiftData

// 导入自定义UI组件
// CommonComponents包含FormHeader等可复用组件


// AddableDataType枚举已在AnalysisView.swift中定义

// 定义一个结构体，表示添加数据的视图界面
// struct是Swift中的一种数据结构，用于封装相关的属性和功能
// AddDataView遵循View协议，表示它是一个界面组件
// 定义一个结构体，表示添加数据的视图界面
struct AddDataView: View {
    
    // MARK: - Properties & State
    // 这个标记用于在代码中创建视觉分隔，便于阅读
    // MARK是Xcode提供的代码组织标记
    
    // 获取应用程序的数据存储上下文，用于保存新数据
    // @Environment是属性包装器，用于访问环境中的值
    // \.modelContext是SwiftData提供的环境键，用于获取数据存储上下文
    // private表示这个属性只能在当前结构体内访问
    // var表示这是一个变量（可变的）
    @Environment(\.modelContext) private var modelContext
    
    // 获取关闭当前视图的功能
    // \.dismiss是SwiftUI提供的环境键，用于关闭当前视图
    @Environment(\.dismiss) private var dismiss
    
    // 定义一个常量，表示当前要添加的数据类型（考试或练习）
    // let表示这是一个常量（不可变的）
    // dataType是在创建视图时传入的参数
    @Binding var dataType: AddableDataType?
    
    // 编辑模式：如果传入exam则为编辑模式，否则为添加模式
    let examToEdit: Exam?
    
    // 预选科目：用于从科目详情页面跳转时预先选择科目
    let preselectedSubject: Subject?
    
    // UI State（用户界面状态变量）
    // @State是属性包装器，用于管理视图的状态
    // 当状态变量的值发生变化时，界面会自动更新
    
    // 存储用户输入的考试名称
    // String表示字符串类型
    // ""表示初始值为空字符串
    @State private var examName: String = ""
    
    // 存储用户选择的日期，默认为今天
    // Date表示日期时间类型
    // .now表示当前日期时间
    @State private var date: Date = .now
    
    // 存储用户输入的成绩，以文本形式保存
    // 以文本形式保存是为了方便用户输入和验证
    @State private var scoreText: String = ""
    
    // Data Source State（数据源状态变量）
    
    // 存储用户选择的科目
    // Subject?表示Subject类型的可选值（可以为nil）
    // nil表示没有选择任何科目
    @State private var selectedSubject: Subject?
    
    // 存储用户选择的练习类别
    // PracticeCollection?表示PracticeCollection类型的可选值（可以为nil）
    @State private var selectedPracticeCollection: PracticeCollection?
    
    // 存储用户选择的考试组
    @State private var selectedExamGroup: ExamGroup?
    
    // 控制考试组选择Sheet的显示
    @State private var showingExamGroupSelection = false
    
    // Queries（数据查询）
    // @Query是SwiftData提供的属性包装器，用于自动查询数据
    
    // 从数据库中查询所有科目，并按orderIndex排序（与ManageSubjectsView保持一致）
    // sort: \Subject.orderIndex表示按Subject结构体的orderIndex属性排序
    // private var subjects: [Subject]表示定义一个私有变量subjects，类型为Subject数组
    @Query(sort: [SortDescriptor(\Subject.orderIndex)]) private var subjects: [Subject]
    
    // 从数据库中查询所有练习类别，并按名称排序
    // \PracticeCollection.name表示按PracticeCollection结构体的name属性排序
    // 从数据库中查询所有练习类别，并按名称排序
    @Query(sort: [SortDescriptor(\PracticeCollection.name)]) private var practiceCollections: [PracticeCollection]
    
    // 从数据库中查询所有考试组，并按创建日期排序
    @Query(sort: [SortDescriptor(\ExamGroup.createdDate, order: .reverse)]) private var examGroups: [ExamGroup]

    // MARK: - Main Body
    // 定义视图的主要内容
    // body是View协议要求实现的属性，定义了界面的具体内容
    var body: some View {
        // 创建一个导航视图，用于管理视图间的导航
        // NavigationView提供导航栏和返回按钮等功能
        NavigationView {
            // 创建一个表单，用于组织输入控件
            // Form用于创建表单界面，自动处理滚动和分组
            Form {
                // [V23] 使用新的可复用组件
                // 显示表单头部，根据数据类型显示不同的图标和标题
                // FormHeader是在CommonComponents.swift中定义的组件
                FormHeader(
                    // iconName根据数据类型选择不同的图标
                    // dataType == .exam ? "doc.text.fill" : "pencil.and.ruler.fill"是三元运算符
                    // 如果dataType等于.exam则显示"doc.text.fill"图标，否则显示"pencil.and.ruler.fill"图标
                    iconName: dataType == .exam ? "doc.text.fill" : "pencil.and.ruler.fill",
                    // title使用navigationTitle计算属性的值
                    title: navigationTitle,
                    // iconColor设置图标颜色为系统的强调色
                    iconColor: .accentColor
                )
                
                // 根据编辑模式或数据类型显示不同的表单内容
                if isEditingMode {
                    // 编辑模式下只显示考试表单
                    examForm
                } else if let type = dataType {
                    switch type {
                    case .exam:
                        // 如果是考试，则显示考试表单
                        // examForm是在下面定义的计算属性
                        examForm
                    case .practice:
                        // 如果是练习，则显示练习表单
                        // practiceForm是在下面定义的计算属性
                        practiceForm
                    }
                } else {
                    Text("请选择数据类型")
                }
            }
            // 添加工具栏按钮
            // toolbar用于在导航栏上添加额外的按钮
            .toolbar {
                // 在右上角添加保存按钮
                // ToolbarItem定义工具栏上的一个项目
                // placement: .primaryAction表示放置在右上角
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { saveData() }) {
                        Label("保存", systemImage: "checkmark")
                    }
                    .disabled(isSaveButtonDisabled)
                }
                // 在左侧添加取消按钮
                // placement: .cancellationAction表示放置在左侧取消位置
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Label("取消", systemImage: "xmark")
                    }
                }
            }
        }
        .onAppear {
            // 如果是编辑模式，初始化表单数据
            if let exam = examToEdit {
                examName = exam.name
                date = exam.date
                // 修复：保留小数精度而不是强转为Int，避免150.0 -> 150
                scoreText = String(format: "%g", exam.totalScore)
                selectedSubject = exam.subject
                selectedExamGroup = exam.examGroup
                // 编辑模式下强制设置为考试类型
                if dataType == nil {
                    dataType = .exam
                }
            } else if let preselected = preselectedSubject {
                // 如果有预选科目，设置为选中状态
                selectedSubject = preselected
            }
        }
        .onChange(of: selectedExamGroup) { oldValue, newValue in
            // 当考试组选择改变时，自动更新考试名称
            if !isEditingMode {
                examName = generateExamName(examGroup: newValue, subject: selectedSubject)
            }
        }
        .sheet(isPresented: $showingExamGroupSelection) {
            ExamGroupSelectionView(selectedGroup: $selectedExamGroup)
        }
    }
  
    // MARK: - Encapsulated View Components
    // 定义封装的视图组件
    
    // 考试表单的视图组件
    // private表示这个属性只能在当前结构体内访问
    // var表示这是一个计算属性（每次访问时都会重新计算）
    // some View表示返回一个遵循View协议的视图
    private var examForm: some View {
        // 创建一个表单区域，标题为"考试信息"
        // Section用于在Form中创建一个带标题的区域
        Section(header: Text("考试信息")) {
            // 考试组选择（添加模式和编辑模式都显示）
            Button(action: {
                showingExamGroupSelection = true
            }) {
                HStack {
                    Text("考试组")
                    Spacer()
                    Text(selectedExamGroup?.name ?? "单科考试")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            // 考试名称输入：大考时自动生成，单科考试时手动输入
            if selectedExamGroup != nil {
                // 大考模式：显示自动生成的名称，禁用手动输入
                HStack {
                    Text("考试名称")
                    Spacer()
                    Text(examName.isEmpty ? "请先选择科目" : examName)
                        .foregroundColor(examName.isEmpty ? .secondary : .primary)
                }
            } else {
                // 单科考试模式：允许手动输入
                TextField("考试名称", text: $examName)
            }
            
            // 日期选择器：只有在单科考试时才显示
            if selectedExamGroup == nil {
                // 创建日期选择器，用于选择考试日期
                // DatePicker用于创建日期选择器
                // "日期"是标签文本
                // selection: $date绑定到date状态变量
                // displayedComponents: .date表示只显示日期部分
                DatePicker("日期", selection: $date, displayedComponents: .date)
            }
            
            // 科目选择：编辑模式下显示为只读，添加模式下可选择
            if isEditingMode {
                // 编辑模式下显示当前科目，不可更改
                HStack {
                    Text("科目")
                    Spacer()
                    Text(selectedSubject?.name ?? "未知科目")
                        .foregroundColor(.secondary)
                }
            } else {
                // 添加模式下的科目选择器
                Picker("科目", selection: $selectedSubject) {
                    // 默认选项，提示用户选择科目
                    Text("请选择科目").tag(nil as Subject?)
                    // 遍历所有科目，为每个科目创建一个选项
                    ForEach(subjects) { subject in
                        // 显示科目名称，并将其与selectedSubject关联
                        Text(subject.name).tag(subject as Subject?)
                    }
                }
                .onChange(of: selectedSubject) { oldValue, newValue in
                    // 当科目选择改变时，如果是大考模式，自动更新考试名称
                    if selectedExamGroup != nil {
                        examName = generateExamName(examGroup: selectedExamGroup, subject: newValue)
                    }
                }
            }
            
            // 创建文本输入框，用于输入成绩
            TextField(selectedSubject != nil ? "成绩（满分\(Int(selectedSubject!.totalScore))）" : "成绩", text: $scoreText)
                // 设置键盘类型为数字键盘
                // .keyboardType(.decimalPad)设置键盘类型为带小数点的数字键盘
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                // 添加输入验证和格式化
                .onChange(of: scoreText) { oldValue, newValue in
                    // 过滤非数字字符（保留小数点）
                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                    if filtered != newValue {
                        scoreText = filtered
                    }
                    // 确保只有一个小数点
                    let components = filtered.components(separatedBy: ".")
                    if components.count > 2 {
                        scoreText = components[0] + "." + components[1]
                    }
                }
        }
    }
    
    // 练习表单的视图组件
    private var practiceForm: some View {
        // 创建一个表单区域，标题为"练习信息"
        Section(header: Text("练习信息")) {
            // 创建下拉选择器，用于选择练习类别
            Picker("所属类别", selection: $selectedPracticeCollection) {
                // 默认选项，提示用户选择类别
                Text("请选择类别").tag(nil as PracticeCollection?)
                // 遍历所有练习类别，为每个类别创建一个选项
                ForEach(practiceCollections) { collection in
                    // 显示类别名称，并将其与selectedPracticeCollection关联
                    Text(collection.name).tag(collection as PracticeCollection?)
                }
            }
            
            // 创建日期选择器，用于选择练习日期
            DatePicker("日期", selection: $date, displayedComponents: .date)
            
            // 创建文本输入框，用于输入成绩
            TextField("成绩", text: $scoreText)
                // 设置键盘类型为数字键盘
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                // 添加输入验证和格式化
                .onChange(of: scoreText) { oldValue, newValue in
                    // 过滤非数字字符（保留小数点）
                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                    if filtered != newValue {
                        scoreText = filtered
                    }
                    // 确保只有一个小数点
                    let components = filtered.components(separatedBy: ".")
                    if components.count > 2 {
                        scoreText = components[0] + "." + components[1]
                    }
                }
        }
    }
    
    // MARK: - Computed Properties & Functions
    // 定义计算属性和函数
    
    // 判断是否为编辑模式
    private var isEditingMode: Bool {
        examToEdit != nil
    }
    
    // 自动起名算法：为大考自动生成名称
    private func generateExamName(examGroup: ExamGroup?, subject: Subject?) -> String {
        guard let group = examGroup, let subject = subject else {
            // 单科考试保持手动输入或使用常用名称
            return ""
        }
        
        // 大考自动起名: 学期+大考名+" - "+学科
        return "\(group.semester)\(group.name) - \(subject.name)"
    }
    
    // 计算导航栏标题，根据数据类型和编辑模式返回不同的标题
    // private表示这个属性只能在当前结构体内访问
    // var表示这是一个计算属性
    // String表示返回值类型为字符串
    private var navigationTitle: String {
        if isEditingMode {
            return "编辑考试"
        } else {
            // 三元运算符：如果dataType等于.exam则返回"添加考试"，否则返回"添加练习"
            return dataType == .exam ? "添加考试" : "添加练习"
        }
    }
    
    // 计算保存按钮是否禁用，用于表单验证
    private var isSaveButtonDisabled: Bool {
        // 如果成绩为空，则禁用保存按钮
        if scoreText.isEmpty { return true }
        
        // 验证分数格式
        guard let scoreValue = Double(scoreText) else { return true }
        
        // 验证分数不能为负数
        if scoreValue < 0 { return true }
        
        if isEditingMode {
            // 编辑模式验证
            // 仅当不在大考模式（selectedExamGroup == nil）时，才要求考试名称非空
            if selectedExamGroup == nil && examName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return true
            }
            
            // 验证分数不能超过科目满分（编辑模式下科目不可更改）
            if let exam = examToEdit, let subject = exam.subject, scoreValue > subject.totalScore {
                return true
            }
            
            return false
        } else {
            // 添加模式验证
            guard let type = dataType else { return true }
            
            switch type {
            case .exam:
                // 对于考试，需要选择科目
                if selectedSubject == nil { return true }
                
                // 大考模式下，考试名称自动生成，不需要手动输入验证
                // 单科考试模式下，需要手动输入考试名称
                if selectedExamGroup == nil && examName.isEmpty { return true }
                
                // 验证分数不能超过科目满分
                if let subject = selectedSubject, scoreValue > subject.totalScore {
                    return true
                }
                
                return false
            case .practice:
                // 对于练习，需要选择练习类别
                return selectedPracticeCollection == nil
            }
        }
    }
    
    // 保存数据的函数
    private func saveData() {
        // 由于按钮禁用逻辑已经验证了所有条件，这里可以安全地进行保存
        guard let scoreValue = Double(scoreText) else { return }
        
        if isEditingMode {
            // 编辑模式：更新现有考试
            guard let exam = examToEdit else { return }
            
            do {
                exam.name = examName
                exam.date = date
                exam.totalScore = scoreValue
                // 更新考试组关联
                exam.examGroup = selectedExamGroup
                // 注意：编辑模式下不允许更改科目，所以不更新subject
                
                try modelContext.save()
                print("\(Date()) [AddDataView] 成功更新考试：\(examName), 分数：\(scoreValue), 考试组：\(selectedExamGroup?.name ?? "无")")
            } catch {
                print("\(Date()) [AddDataView] 更新考试失败：\(error.localizedDescription)")
                return
            }
        } else {
            // 添加模式：创建新记录
            guard let type = dataType else { return }
            
            switch type {
            case .exam:
                // 保存考试数据
                guard let subject = selectedSubject else { return }
                
                // 创建新的考试实例
                do {
                    let newExam = Exam(name: examName, date: date, score: scoreValue, totalScore: subject.totalScore, subject: subject)
                    // 关联考试组（如果选择了的话）
                    newExam.examGroup = selectedExamGroup
                    modelContext.insert(newExam)
                    try modelContext.save()
                    print("\(Date()) [AddDataView] 成功保存考试：\(examName), 分数：\(scoreValue), 考试组：\(selectedExamGroup?.name ?? "无")")
                } catch {
                    print("\(Date()) [AddDataView] 保存考试失败：\(error.localizedDescription)")
                    return
                }
                
            case .practice:
                // 保存练习数据
                guard let collection = selectedPracticeCollection else { return }
                
                // 创建新的练习实例
                do {
                    let newPractice = Practice(date: date, score: scoreValue, collection: collection)
                    modelContext.insert(newPractice)
                    try modelContext.save()
                    print("\(Date()) [AddDataView] 成功保存练习：\(collection.name), 分数：\(scoreValue)")
                } catch {
                    print("\(Date()) [AddDataView] 保存练习失败：\(error.localizedDescription)")
                    return
                }
            }
        }
        
        // 关闭当前视图
        dismiss()
    }
}

// MARK: - Preview
// 预览代码，用于在设计时预览界面效果

// 考试添加界面的预览
#Preview("添加考试") {
    AddDataView(dataType: Binding.constant(.exam), examToEdit: nil, preselectedSubject: nil)
        .modelContainer(for: [Subject.self, Exam.self])
}

// 练习添加界面的预览
#Preview("添加练习") {
    AddDataView(dataType: Binding.constant(.practice), examToEdit: nil, preselectedSubject: nil)
        .modelContainer(for: [PracticeCollection.self, Practice.self, Subject.self])
}

// 考试编辑界面的预览
#Preview("编辑考试") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, Exam.self, configurations: config)
    let context = container.mainContext
    
    // 创建示例科目和考试
    let subject = Subject(name: "数学", totalScore: 150, orderIndex: 0)
    context.insert(subject)
    
    let exam = Exam(name: "期中考试", date: Date(), score: 135.0, totalScore: 150.0, subject: subject)
    context.insert(exam)
    
    try? context.save()
    
    return AddDataView(dataType: Binding.constant(.exam), examToEdit: exam, preselectedSubject: nil)
        .modelContainer(container)
}

