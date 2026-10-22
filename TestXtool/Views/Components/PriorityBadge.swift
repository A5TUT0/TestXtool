import SwiftUI

struct PriorityBadge: View {
    let priority: Priority
    
    var body: some View {
        if priority != .none {
            HStack(spacing: 4) {
                Image(systemName: priority.iconName)
                    .font(.system(size: 10, weight: .bold))
                Text(priority.rawValue)
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(priority.color.opacity(0.15))
            )
            .foregroundColor(priority.color)
        }
    }
}
