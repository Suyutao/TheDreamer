# The Dreamer Product Vision Roadmap

Date: 2026-05-01

## Why This Exists

The Dreamer should be a quiet, trustworthy learning companion for students, not a dashboard that exists only to show charts. The existing project notes converge on one product promise:

> Help students use their own learning data to gain freedom, order, and self-control.

That means every feature should answer a practical student question:

- What happened in my recent study or exams?
- Where am I improving or slipping?
- What should I pay attention to next?
- Can I record data quickly without feeling interrupted?

The app should remain local-first, free, non-commercial, and native SwiftUI.

## Product Shape

The app should organize around three daily workflows.

### 1. Record

Students need fast, low-friction data entry after an exam or practice session. Recording should feel like writing a short note, not filling out a database.

Core expectations:

- Add exam score.
- Add practice score.
- Choose subject quickly.
- Support exam groups for large exams.
- Preserve created and updated timestamps.
- Avoid invalid scores before saving.

Next improvements:

- Add date and time selection for exam records.
- Provide a native save confirmation.
- Improve score entry with a numeric stepper or picker for common totals.

### 2. Review

Students need a calm place to see what they have recorded. This is not yet deep analysis; it is orientation.

Core expectations:

- Subject overview.
- Recent exams and practices.
- Per-subject detail page.
- All data list with delete and undo where appropriate.

Next improvements:

- Group records by month, semester, and exam group.
- Make empty states explain the next useful action.
- Keep all list interactions native and predictable.

### 3. Understand

Charts should become explanations, not decoration. The goal is to help students find patterns they can act on.

Core expectations from the existing V2 roadmap:

- Trend line chart for score changes over time.
- Subject comparison bar chart.
- Single exam score-rate pie chart.
- Empty and invalid data protection.

Next improvements:

- Normalize by score rate when comparing subjects with different totals.
- Make charts robust against zero totals, missing subjects, and sparse data.
- Add short, factual insight text near charts, such as "Math improved across the last 3 exams."

## Technical Direction

Use the current native SwiftUI baseline as the foundation:

- Prefer `NavigationStack`, `List`, `Form`, `Section`, `LabeledContent`, `Toggle`, `Picker`, `ContentUnavailableView`, and system button styles.
- Keep custom visual styling minimal.
- Keep SwiftData as the only persistence layer.
- Keep the Model-View architecture unless a feature clearly needs a small helper type.
- Compile after each meaningful step on the iOS 26 simulator target.

## Proposed Next Milestones

### Milestone A: Stabilize The Daily Loop

Goal: A student can add data, browse it, and trust that nothing weird happened.

Deliverables:

- Fix any stale About/developer metadata.
- Review AddDataView after the native Form conversion.
- Ensure SubjectDetailView add-data flow stays locked to the selected subject.
- Verify delete and undo flows still compile and behave consistently.

Progress:

- 2026-05-01: Updated About metadata to iOS 26/Xcode 26.
- 2026-05-01: Added date and time selection to data entry.
- 2026-05-01: Locked subject selection when adding data from a subject detail page.

Acceptance:

- Clean simulator build.
- No duplicate or conflicting navigation bars.
- No obvious old iOS 18/Xcode 16 references in user-facing text.

### Milestone B: Chart System V2 MVP

Goal: Implement the existing V2 chart roadmap in the simplest useful form.

Deliverables:

- Trend chart fed by a shared data aggregation helper.
- Subject comparison chart using score rate by default.
- Single-exam score-rate chart with invalid-data protection.

Acceptance:

- Empty data has native empty states.
- Sparse data does not crash.
- Charts remain legible on iPhone.

### Milestone C: Student Insight Layer

Goal: Turn charts into useful interpretations.

Deliverables:

- Basic insight summaries from recent exams.
- Per-subject trend direction.
- Flags for data gaps or sudden drops.

Acceptance:

- Insights are factual and humble.
- No fake coaching or overconfident recommendations.
- All analysis stays on-device.

## Near-Term Recommendation

Start with Milestone A, then resume the existing Chart System V2 roadmap. The current codebase just regained a native, compilable baseline, so the next best move is to protect that baseline while making one student workflow excellent at a time.
