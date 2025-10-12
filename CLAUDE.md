# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination platform=iOS Simulator,name=iPhone 16 Pro clean build

# Build for testing
xcodebuild -project "The Dreamer.xcodeproj" -scheme "The Dreamer" -destination platform=iOS Simulator,name=iPhone 16 Pro test

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