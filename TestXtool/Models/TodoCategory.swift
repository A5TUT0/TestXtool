import SwiftUI

enum TodoCategory: String, CaseIterable, Identifiable, Codable {
    case personal = "Personal"
    case work = "Trabajo"
    case shopping = "Compras"
    case study = "Estudio"
    case health = "Salud"
    case ideas = "Ideas"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .shopping: return "cart.fill"
        case .study: return "book.closed.fill"
        case .health: return "heart.fill"
        case .ideas: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .personal: return .indigo
        case .work: return .blue
        case .shopping: return .teal
        case .study: return .orange
        case .health: return .pink
        case .ideas: return .yellow
        }
    }
}
