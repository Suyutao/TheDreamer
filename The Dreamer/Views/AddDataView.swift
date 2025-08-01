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


// 定义一个枚举类型，用来区分是添加考试还是练习
// enum是一种特殊的数据类型，它定义了一组相关的值
// AddableDataType表示可添加的数据类型
enum AddableDataType {
    // 表示添加考试的选项
    // case是枚举中的一个值
    case exam
    // 表示添加练习的选项
    case practice
}

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
    
    // Queries（数据查询）
    // @Query是SwiftData提供的属性包装器，用于自动查询数据
    
    // 从数据库中查询所有科目，并按名称排序
    // sort: \Subject.name表示按Subject结构体的name属性排序
    // private var subjects: [Subject]表示定义一个私有变量subjects，类型为Subject数组
    // 从数据库中查询所有科目，并按名称排序
    @Query(sort: [SortDescriptor(\Subject.name)]) private var subjects: [Subject]
    
    // 从数据库中查询所有练习类别，并按名称排序
    // \PracticeCollection.name表示按PracticeCollection结构体的name属性排序
    // 从数据库中查询所有练习类别，并按名称排序
    @Query(sort: [SortDescriptor(\PracticeCollection.name)]) private var practiceCollections: [PracticeCollection]

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
                
                // 根据数据类型显示不同的表单内容
                // switch是条件分支语句，根据dataType的值执行不同的代码块
                if let type = dataType {
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
            // 设置导航栏标题
            // navigationTitle是下面定义的计算属性
            .navigationTitle(navigationTitle)
            // 设置导航栏标题显示模式
            // .inline表示标题显示在导航栏内
            .navigationBarTitleDisplayMode(.inline)
            // 添加工具栏按钮
            // toolbar用于在导航栏上添加额外的按钮
            .toolbar {
                // 在右上角添加保存按钮
                // ToolbarItem定义工具栏上的一个项目
                // placement: .topBarTrailing表示放置在右上角
                ToolbarItem(placement: .topBarTrailing) {
                    // 创建保存按钮，点击时调用saveData函数
                    // Button用于创建一个可点击的按钮
                    // "保存"是按钮显示的文本
                    // action: saveData表示点击按钮时执行saveData函数
                    Button("保存", action: saveData)
                        // 根据表单验证结果决定按钮是否可用
                        // .disabled是修饰符，用于控制视图是否禁用
                        // isSaveButtonDisabled是下面定义的计算属性
                        .disabled(isSaveButtonDisabled)
                }
                // 在左侧添加取消按钮
                // placement: .cancellationAction表示放置在左侧取消位置
                ToolbarItem(placement: .cancellationAction) {
                    // 创建取消按钮，点击时关闭当前视图
                    // dismiss()是调用Environment中的关闭功能
                    Button("取消") { dismiss() }
                }
            }
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
            // 创建文本输入框，用于输入考试名称
            // TextField用于创建文本输入框
            // "考试名称，如：期中数学"是占位符文本
            // text: $examName绑定到examName状态变量
            TextField("考试名称，如：期中数学", text: $examName)
            
            // 创建日期选择器，用于选择考试日期
            // DatePicker用于创建日期选择器
            // "日期"是标签文本
            // selection: $date绑定到date状态变量
            // displayedComponents: .date表示只显示日期部分
            DatePicker("日期", selection: $date, displayedComponents: .date)
            
            // 创建下拉选择器，用于选择科目
            // Picker用于创建下拉选择器
            // "科目"是标签文本
            // selection: $selectedSubject绑定到selectedSubject状态变量
            Picker("科目", selection: $selectedSubject) {
                // 默认选项，提示用户选择科目
                // Text用于显示文本
                // .tag(nil as Subject?)将这个选项与nil值关联
                Text("请选择科目").tag(nil as Subject?)
                // 遍历所有科目，为每个科目创建一个选项
                // ForEach是SwiftUI中的循环结构，用于遍历数组
                ForEach(subjects) { subject in
                    // 显示科目名称，并将其与selectedSubject关联
                    // subject.name获取科目名称
                    // .tag(subject as Subject?)将这个选项与具体的subject值关联
                    Text(subject.name).tag(subject as Subject?)
                }
            }
            
            // 创建文本输入框，用于输入成绩
            TextField("成绩", text: $scoreText)
                // 设置键盘类型为数字键盘
                // .keyboardType(.decimalPad)设置键盘类型为带小数点的数字键盘
                .keyboardType(.decimalPad)
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
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Computed Properties & Functions
    // 定义计算属性和函数
    
    // 计算导航栏标题，根据数据类型返回不同的标题
    // private表示这个属性只能在当前结构体内访问
    // var表示这是一个计算属性
    // String表示返回值类型为字符串
    private var navigationTitle: String {
        // 三元运算符：如果dataType等于.exam则返回"添加考试"，否则返回"添加练习"
        dataType == .exam ? "添加考试" : "添加练习"
    }
    
    // 计算保存按钮是否禁用，用于表单验证
    private var isSaveButtonDisabled: Bool {
        // [V18] 添加简单的表单验证，确保核心信息已填写
        
        // 如果成绩为空，则禁用保存按钮
        // scoreText.isEmpty检查scoreText是否为空字符串
        // return true表示禁用按钮
        if scoreText.isEmpty { return true }
        
        // 根据数据类型进行不同的验证
        // switch是条件分支语句
        if let type = dataType {
            switch type {
            case .exam:
                // 对于考试，需要填写考试名称和选择科目
                // ||是逻辑或运算符，只要有一个条件为true，整个表达式就为true
                // examName.isEmpty检查考试名称是否为空
                // selectedSubject == nil检查是否没有选择科目
                return examName.isEmpty || selectedSubject == nil
            case .practice:
                // 对于练习，需要选择练习类别
                // selectedPracticeCollection == nil检查是否没有选择练习类别
                return selectedPracticeCollection == nil
            }
        } else {
            return true
        }
    }
    
    // 保存数据的函数
    // private表示这个函数只能在当前结构体内访问
    // func表示这是一个函数定义
    // saveData是函数名
    private func saveData() {
        // 尝试将输入的成绩文本转换为数字
        // guard是条件判断语句，用于提前退出
        // let scoreValue = Double(scoreText)尝试将scoreText转换为Double类型
        // else表示如果转换失败则执行后面的代码
        guard let scoreValue = Double(scoreText) else {
            // 如果转换失败，打印错误信息
            // print用于在控制台输出信息
            print("错误：分数格式不正确")
            return // 真实应用中应有弹窗提示
        }
        
        // 根据数据类型执行不同的保存操作
        if let type = dataType {
            switch type {
            case .exam:
                // 保存考试数据
                
                // 确保已选择科目
                guard let subject = selectedSubject else { return }
                
                // 创建新的考试实例
                let newExam = Exam(name: examName, date: date, totalScore: scoreValue, subject: subject)
                modelContext.insert(newExam)
                
            case .practice:
                // 保存练习数据
                
                // 确保已选择练习类别
                guard let collection = selectedPracticeCollection else { return }
                
                // 创建新的练习实例
                let newPractice = Practice(date: date, score: scoreValue, collection: collection)
                modelContext.insert(newPractice)
            }
            
            // 关闭当前视图
            dismiss()
        }
    }
}

// MARK: - Preview
// 预览代码，用于在设计时预览界面效果

// 考试添加界面的预览
// #Preview是Xcode提供的预览功能
#Preview("添加考试") {
    // [V18] 必须提供所有相关的模型给容器，以便预览正常工作
    // AddDataView(dataType: .exam)创建一个添加考试的视图实例
    // .modelContainer(for: [Subject.self, Exam.self])为预览提供数据模型容器
    AddDataView(dataType: Binding.constant(.exam))
        .modelContainer(for: [Subject.self, Exam.self])
}

// 练习添加界面的预览
#Preview("添加练习") {
    AddDataView(dataType: Binding.constant(.practice))
        .modelContainer(for: [PracticeCollection.self, Practice.self, Subject.self])
}

