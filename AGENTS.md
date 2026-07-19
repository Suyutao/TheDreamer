# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**The Dreamer** is a data-driven learning analytics tool built by students, for students. It helps students track exam scores, practice sessions, and learning progress through visualization and analysis. The project follows a "by students, for students" philosophy and is committed to remaining free, open-source, and non-commercial.

## Development Environment

### Requirements
- **Xcode**: 26+
- **iOS SDK**: 26+
- **Swift**: 5.0+
- **Platforms**: iOS, macOS, visionOS

### Build Commands
```bash
# Build the project
xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination platform=iOS Simulator,name=iPhone 17 Pro clean build

# Build for testing
xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination platform=iOS Simulator,name=iPhone 17 Pro test

# Archive for distribution
xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination generic/platform=iOS archive
```

## Architecture

### Core Technology Stack
- **UI Framework**: SwiftUI (native iOS experience)
- **Data Persistence**: SwiftData (local-first, no external databases)
- **Charts & Visualization**: Swift Charts (custom interactive charts)
- **Architecture Pattern**: MV (Model-View) - lightweight, no complex view models

### File Organization Rules
The project follows strict file organization rules defined in `.trae/rules/project_rules.md`:

```
The Dreamer/
├── Models/                    # All SwiftData @Model classes ONLY
│   └── Models.swift          # Core data models (Subject, Exam, Practice, etc.)
├── Views/                     # Feature-specific SwiftUI views
│   ├── Core/                 # Main app views (Dashboard, Database, Analysis)
│   ├── Subject/              # Subject management views
│   └── Settings/             # Settings and configuration views
├── Components/               # Reusable UI components
│   └── TimeRangeSelector.swift
├── Charts/                   # Visualization components
│   ├── LineChartView.swift
│   ├── BarChartView.swift
│   └── Apple.Inc-SwiftChartsWWDC24/  # Advanced chart examples
├── Cards/                    # Data display cards
└── Resources/                # Assets and resources
```

**Important**: Never import internal project modules (e.g., `import TheDreamer.Models`). All types are globally visible within the app target.

### Data Model Architecture

The core data models are built around several key concepts:

#### Core Entities
- **Subject**: The central hub - represents academic subjects (Math, English, etc.)
- **Exam**: Individual test instances with scores and dates
- **PracticeCollection**: Groups of similar practice sessions
- **Practice**: Lightweight practice session records
- **PaperTemplate**: Reusable exam structures
- **QuestionTemplate/QuestionDefinition**: Template and definition for questions

#### Relationships
- Subjects contain multiple exams, practice collections, and paper templates
- Exams contain individual question results
- Practice collections contain multiple practice sessions
- Templates define reusable structures for consistent data entry

#### Key Features
- **Local-first**: All data stored on-device using SwiftData
- **Template System**: Reusable exam and practice templates
- **Rich Relationships**: Complex data relationships with cascade deletion
- **Timestamps**: Automatic creation and update tracking
- **Data Aggregation**: Computed properties for analytics and insights

### UI Architecture

#### Main Views
- **MainTabView**: Root navigation with tab bar
- **DashboardView**: Main analytics dashboard with charts
- **Database**: Data management and browsing
- **AddDataView**: Unified data entry interface
- **SubjectDetailView**: Detailed subject analytics

#### Chart Components
- **LineChartView**: Score trends over time
- **BarChartView**: Comparative analysis
- **Heatmaps**: Long-term pattern analysis
- **Scatter plots**: Performance distribution analysis

#### Reusable Components
- **TimeRangeSelector**: Date range filtering
- **SubjectScoreCard**: Subject summary cards
- **EmptyStateView**: Handling empty data states

## Development Guidelines

### Code Standards
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add Chinese comments for complex business logic (project is bilingual)
- Ensure code compiles without warnings
- Use SwiftData for all persistent data

### File Organization Principles
- **Models/**: Only @Model classes
- **Views/**: Feature-specific views only
- **Components/**: Reusable UI components only
- **Charts/**: Visualization components only

### Testing Philosophy
The project takes a pragmatic approach to testing:
- Focus on compilation success rather than extensive unit tests
- AI-assisted development means maintainer has basic understanding of codebase
- Priority is on functionality and student user experience

### Data Management
- Never use Core Data - use SwiftData exclusively
- Never use UserDefaults for core business data
- All data relationships should use SwiftData's @Relationship
- Implement proper cascade deletion rules
- Include timestamps (createdAt, updatedAt) for auditability

## Project Philosophy

### Core Principles
1. **By Students, For Students**: Every feature should address real student pain points
2. **Privacy First**: All data stays on the device
3. **Free Forever**: No commercialization, no ads, no in-app purchases
4. **Open Source**: Apache License 2.0, encourage learning and contribution
5. **Simplicity**: Clean, focused interface that doesn't overwhelm

### Development Approach
- **AI-Assisted**: Primary development uses AI tools with human oversight
- **Practical**: Focus on solving real problems over theoretical perfection
- **Iterative**: Gradual improvement based on user feedback
- **Community-Driven**: Open to contributions that align with the mission

## Common Development Tasks

### Adding New Features
1. Define data models in `Models.swift` if needed
2. Create views in appropriate `Views/` subdirectory
3. Add reusable components to `Components/`
4. Update navigation in `MainTabView` if needed
5. Test with sample data

### Working with Charts
1. Use existing chart components in `Charts/`
2. Refer to `Apple.Inc-SwiftChartsWWDC24/` for advanced examples
3. Ensure charts work with the `ChartDataPoint` structure
4. Support time range filtering

### Data Entry Improvements
1. Extend `AddDataView` for new data types
2. Update templates in `PaperTemplate` and related models
3. Ensure form validation and user feedback
4. Maintain consistency with existing entry patterns

## License and Attribution

- **License**: Apache License 2.0
- **Attribution**: Include proper attribution for third-party components
- **Commercial Use**: Project must remain non-commercial
- **Modifications**: Derivative works must maintain the same license

## Special Considerations

### Internationalization
- Project supports Chinese and English
- Use String Catalogs for localization
- Comments can be in Chinese for complex business logic

### Performance
- SwiftData handles local storage efficiently
- Charts should handle large datasets gracefully
- Use lazy loading for large data sets
- Implement proper memory management for chart rendering

### Privacy
- No external data transmission
- All processing happens on-device
- No analytics or tracking
- User has full control over their data
- {
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
    "buildCommand": "xcodebuild -project The Dreamer.xcodeproj -scheme The Dreamer -destination platform=iOS Simulator,name=iPhone 17 Pro clean build",
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

