import SwiftUI

struct CategoryBadge: View {
    let category: TodoCategory
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.iconName)
                .font(.system(size: 11, weight: .semibold))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? category.color : category.color.opacity(0.15))
        )
        .foregroundColor(isSelected ? .white : category.color)
    }
}
