import SwiftUI

enum ScheduleEditorPresentation: Equatable {
    case sheet
    case embedded
}

struct ScheduleEditorContainer<Content: View>: View {
    let presentation: ScheduleEditorPresentation
    let content: Content

    init(
        presentation: ScheduleEditorPresentation,
        @ViewBuilder content: () -> Content
    ) {
        self.presentation = presentation
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        switch presentation {
        case .sheet:
            NavigationStack {
                content
            }
        case .embedded:
            content
        }
    }
}
