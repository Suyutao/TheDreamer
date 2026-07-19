import SwiftUI

extension Color {
    static var groupedBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static var secondaryGroupedBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var tertiaryGroupedBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .tertiarySystemGroupedBackground)
        #else
        Color(nsColor: .underPageBackgroundColor)
        #endif
    }

    static var tertiaryLabelColor: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .tertiaryLabel)
        #else
        Color(nsColor: .tertiaryLabelColor)
        #endif
    }

    static var separatorColor: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .separator)
        #else
        Color(nsColor: .separatorColor)
        #endif
    }

    static var systemGray5Color: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .systemGray5)
        #else
        Color.gray.opacity(0.2)
        #endif
    }

    static var systemGray6Color: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .systemGray6)
        #else
        Color.gray.opacity(0.1)
        #endif
    }
}
