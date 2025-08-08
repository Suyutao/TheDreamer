{
  "projectName": "The Dreamer",
  "version": "1.0",
  
  "coreInfo": {
    "name": "The Dreamer",
    "mission": "由学生打造，为学生服务。一个旨在帮助学生通过数据分析实现"自由、秩序与自我掌控"的认知工具。",
    "principle": "本项目采用GPLv3开源协议，永不商业化，永远免费开源。"
  },

  "technicalConstraints": {
    "techStack": ["SwiftUI", "SwiftData", "Swift Charts", "Swift"],
    "targetSDK": "iOS 26",
    "architecture": "MV (Model-View)",
    "buildCommand": "xcodebuild -project The Dreamer.xcodeproj -scheme The Dreamer -destination platform=iOS Simulator,name=iPhone 16 Pro clean build",
    "forbiddenAPIs": [
      "UIKit/AppKit for UI layout",
      "CoreData",
      "UserDefaults for core business data"
    ],
    "testingMethod": "仅需编译成功，无需在真实设备或模拟器上运行"
  },

  "codeOrganizationRules": {
    "title": "代码组织与文件结构规范 (The \"Where-To-Put-Code\" Rulebook)",
    "description": "这是决定代码存放位置的最高准则。所有AI在生成或修改代码时，必须严格遵守。",
    "principles": {
      "directoryByResponsibility": {
        "Models": "唯一存放所有SwiftData @Model类型（如Subject, Exam）的地方",
        "Views": "存放所有核心的、与特定功能绑定的SwiftUI视图（如ManageSubjectsView, DashboardView）",
        "Components": "存放所有通用的、可在多个视图中复用的UI组件（如HeaderView, EmptyStateView）",
        "Utils_or_Extensions": "存放通用的辅助函数或对现有类型的扩展（如Date格式化扩展）"
      },
      "intelligentDecisionRouting": {
        "rules": [
          {"if": "是数据模型 (@Model)", "then": "必须在Models/目录下创建或修改"},
          {"if": "是可复用的UI组件", "then": "必须在Components/目录下创建或修改"},
          {"if": "是某个特定功能的主视图", "then": "必须在Views/目录下创建或修改"},
          {"if": "是通用的辅助工具", "then": "必须在Utils/目录下创建或修改"}
        ]
      },
      "modularImports": {
        "forbidden": "import TheDreamer.Models或任何类似的、对项目内部模块的显式导入",
        "explanation": "在同一个App Target内，所有非私有的类型都是默认全局可见的。你只需要导入外部框架，如SwiftUI, SwiftData, Charts"
      }
    }
  },

  "dataModels": {
    "Subject": {
      "description": "学科",
      "fields": ["name", "totalScore", "orderIndex"]
    },
    "Exam": {
      "description": "考试实例",
      "fields": ["name", "date", "totalScore"],
      "relations": ["Subject"]
    },
    "PracticeCollection": {
      "description": "练习合集",
      "fields": ["name"],
      "relations": ["Subject"]
    },
    "Practice": {
      "description": "单次练习",
      "fields": ["date", "score", "totalScore"],
      "relations": ["PracticeCollection"]
    },
    "Question": {
      "description": "题目实例",
      "fields": ["questionNumber", "score", "totalScore"],
      "relations": ["Exam", "Practice"]
    },
    "PaperTemplate": {
      "description": "卷子模板",
      "fields": ["name"],
      "relations": ["Subject"]
    },
    "QuestionTemplate": {
      "description": "题目模板",
      "fields": ["questionNumber", "totalScore"],
      "relations": ["PaperTemplate"]
    },
    "QuestionType_and_CognitiveLaw": {
      "description": "题型与考法标签",
      "fields": ["name"]
    }
  },

  "visualizations": {
    "lineChart": {
      "type": "核心图表",
      "description": "展示分数随时间的变化趋势，支持多条曲线（我的分数, 班级均分等）叠加"
    },
    "barChart": {
      "type": "柱状图/叠层柱状图",
      "description": "用于单次考试的科目对比，或历次考试中各科分数贡献的比例变化"
    },
    "pieChart": {
      "type": "占比图 (扇形图/进度图)",
      "description": "用于展示单次考试的得分率、科目/题型占比等静态构成"
    },
    "scatterPlot": {
      "type": "散点密度图",
      "description": "进阶图表，用于诊断不同分值、不同题型的得分效率"
    },
    "heatmap": {
      "type": "热力图",
      "description": "进阶图表，用于分析特定题型/考法的长期能力变化趋势"
    }
  },

  "coreFunctionModules": [
    "MainTabView",
    "ManageSubjectsView",
    "AddDataView",
    "AnalysisView (V1)",
    "DashboardView (V1)",
    "OnBoardingView",
    "TemplateManagementView",
    "DetailedDataEntryView",
    "DashboardView (V2+)",
    "AnalysisView (V2+)",
    "SearchFunctionalityView"
  ]
}
