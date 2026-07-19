import SwiftUI

extension Subject {
    var systemImage: String {
        switch name {
        case let name where name.contains("语文"): return "text.book.closed"
        case let name where name.contains("数学"): return "function"
        case let name where name.contains("英语"): return "textformat.abc"
        case let name where name.contains("物理"): return "atom"
        case let name where name.contains("化学"): return "flask"
        case let name where name.contains("生物"): return "leaf"
        case let name where name.contains("历史"): return "clock"
        case let name where name.contains("地理"): return "globe.asia.australia"
        case let name where name.contains("政治"): return "building.columns"
        default: return "book"
        }
    }

    var tintColor: Color {
        switch name {
        case let name where name.contains("语文"): return .red
        case let name where name.contains("数学"): return .blue
        case let name where name.contains("英语"): return .green
        case let name where name.contains("物理"): return .purple
        case let name where name.contains("化学"): return .orange
        case let name where name.contains("生物"): return .mint
        case let name where name.contains("历史"): return .brown
        case let name where name.contains("地理"): return .cyan
        case let name where name.contains("政治"): return .indigo
        default: return .gray
        }
    }
}
