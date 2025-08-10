import SwiftUI

// MARK: - MiniChartCard
/// 统一的小卡片容器：提供一致的 padding / 背景 / 圆角风格
struct MiniChartCard<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
    }
}

// MARK: - MiniChartHeader
/// 小卡片统一的头部：左侧图标+标题，右侧日期+chevron
struct MiniChartHeader: View {
    let iconSystemName: String
    let title: String
    let date: Date?
    var accentColor: Color = .orange
    var showChevron: Bool = true
    
    private var formattedDate: String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: iconSystemName)
                    .font(.subheadline.bold())
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(accentColor)
            }
            
            Spacer()
            
            if let formattedDate {
                HStack(alignment: .center, spacing: 6) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.85))
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary.opacity(0.60))
                    }
                }
            }
        }
    }
}