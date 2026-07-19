# iPad And macOS Timetable Workspace Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a native adaptive timetable editing workspace for iPad and macOS with three-column editing and one independent window per timetable.

**Architecture:** Keep SwiftData and the existing timetable services authoritative. Add value-driven workspace selection and a `PersistentIdentifier`-driven `WindowGroup`, then reuse the existing editor business logic in embedded wide-screen editors and compact sheets.

**Tech Stack:** SwiftUI, SwiftData, EventKit, UserNotifications, Swift Testing, Xcode 26

---

### Task 1: Add window routing

**Files:**
- Modify: `The Dreamer/The_DreamerApp.swift`
- Create: `The Dreamer/Views/Schedule/TimetableWindowView.swift`
- Test: `The DreamerTests/The_DreamerTests.swift`

**Steps:**
1. Add a test proving a saved timetable can be resolved from its `PersistentIdentifier` with `registeredModel(for:)`.
2. Run the timetable test target and confirm the new test passes against the current schema.
3. Add `WindowGroup("课程表", id: "timetable-workspace", for: PersistentIdentifier.self)` to the App scene and attach the shared `ModelContainer`.
4. Implement `TimetableWindowView` with a resolved timetable workspace and a missing-object `ContentUnavailableView`.
5. Build iOS and macOS and confirm the scene declaration compiles on both.

### Task 2: Introduce workspace selection types

**Files:**
- Create: `The Dreamer/Views/Schedule/ScheduleWorkspaceSelection.swift`
- Create: `The Dreamer/Views/Schedule/ScheduleWorkspaceView.swift`
- Modify: `The Dreamer/Views/Schedule/ScheduleManagementView.swift`

**Steps:**
1. Define hashable selection values for workspace category and selected period, schedule, override, or course using `PersistentIdentifier`.
2. Build a three-column `NavigationSplitView` with timetable/course navigation, selectable content, and a stable detail column.
3. Keep `ScheduleManagementView` as the compact workflow and route regular iPad/macOS presentations to `ScheduleWorkspaceView`.
4. Add empty states for missing timetable, no category selection, and no selected object.
5. Build for iPhone and iPad simulator destinations.

### Task 3: Add native iPad and macOS collections

**Files:**
- Create: `The Dreamer/Views/Schedule/ScheduleWorkspaceSidebar.swift`
- Create: `The Dreamer/Views/Schedule/ScheduleWorkspaceContent.swift`
- Create: `The Dreamer/Views/Schedule/MacScheduleTable.swift`

**Steps:**
1. Implement an iPad selectable `List` for arrangements, periods, overrides, and courses.
2. Implement a macOS `Table` for course arrangements with weekday, time, course, teacher, location, and repeat columns.
3. Add context menus and platform-appropriate deletion actions.
4. Add the “在新窗口中打开” action using `openWindow(id:value:)` on iPad and macOS.
5. Verify selection remains valid after SwiftData insertions and deletions.

### Task 4: Refactor editors for embedded and sheet presentation

**Files:**
- Modify: `The Dreamer/Views/Schedule/ScheduleEditors.swift`
- Create: `The Dreamer/Views/Schedule/ScheduleEditorContent.swift`
- Modify: `The Dreamer/Views/Schedule/ScheduleManagementView.swift`

**Steps:**
1. Extract the reusable `Form` content and validation state from timetable, course, period, arrangement, and override editors.
2. Keep compact editors inside `NavigationStack` sheets with Cancel and Save toolbar actions.
3. Render existing-object editors directly in the wide detail column with a bounded readable form width.
4. Preserve SwiftData-save-first and EventKit/notification-refresh-second behavior.
5. Build after each editor extraction to avoid compounding generic `ViewBuilder` errors.

### Task 5: Add platform commands and window polish

**Files:**
- Modify: `The Dreamer/The_DreamerApp.swift`
- Modify: `The Dreamer/Views/Schedule/ScheduleWorkspaceView.swift`
- Modify: `The Dreamer/Views/Core/MainTabView.swift`

**Steps:**
1. Replace the macOS custom scroll sidebar with native selection-backed `List` behavior.
2. Add scoped new, save, and delete commands for the timetable workspace.
3. Set useful default and minimum window sizes without constraining iPad resizing.
4. Confirm the main window and independent timetable windows use the same model container and update each other.

### Task 6: Verify all supported platforms

**Files:**
- Modify: `The DreamerTests/The_DreamerTests.swift`
- Modify only if required by failures: timetable workspace source files

**Steps:**
1. Run `xcodebuild` for the iPhone 17 Pro simulator with `OTHER_SWIFT_FLAGS='-disable-sandbox'`.
2. Run the `The DreamerTests` target and verify all timetable tests pass.
3. Run the iPad app and capture wide, compact, and independent-window screenshots.
4. Run the macOS app, open two timetable windows, edit one timetable, and verify the second window updates.
5. Build the macOS destination and generic visionOS Simulator destination.
6. Run `git diff --check` and `plutil -lint The Dreamer.xcodeproj/project.pbxproj`.
