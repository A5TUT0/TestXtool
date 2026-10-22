import SwiftUI

enum Priority: String, CaseIterable, Identifiable, Codable, Comparable {
    case none = "Ninguna"
    case low = "Baja"
    case medium = "Media"
    case high = "Alta"
    
    var id: String { rawValue }
    
    var order: Int {
        switch self {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.order < rhs.order
    }
    
    var color: Color {
        switch self {
        case .none: return .secondary
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .none: return "circle"
        case .low: return "arrow.down.circle.fill"
        case .medium: return "equal.circle.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}
