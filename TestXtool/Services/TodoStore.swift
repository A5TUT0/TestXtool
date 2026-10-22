import SwiftUI
import Observation

enum FilterTab: String, CaseIterable, Identifiable {
    case all = "Todas"
    case today = "Hoy"
    case upcoming = "Próximas"
    case flagged = "Destacadas"
    case completed = "Completadas"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "tray.full.fill"
        case .today: return "calendar.day.timeline.leading"
        case .upcoming: return "calendar.badge.clock"
        case .flagged: return "flag.fill"
        case .completed: return "checkmark.seal.fill"
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dueDate = "Fecha de entrega"
    case priority = "Prioridad"
    case title = "Título"
    case createdAt = "Fecha de creación"
    
    var id: String { rawValue }
}

@Observable
@MainActor
final class TodoStore {
    var items: [TodoItem] = [] {
        didSet {
            save()
        }
    }
    
    var selectedFilter: FilterTab = .all
    var selectedCategory: TodoCategory? = nil
    var searchText: String = ""
    var sortOption: SortOption = .dueDate
    var sortAscending: Bool = true
    
    private let saveURL: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("todos_testXtool.json")
    }()
    
    init() {
        load()
        if items.isEmpty {
            loadSampleData()
        }
    }
    
    // MARK: - Computed Statistics
    
    var totalCount: Int {
        items.count
    }
    
    var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }
    
    var pendingCount: Int {
        items.filter { !$0.isCompleted }.count
    }
    
    var todayCount: Int {
        items.filter { !$0.isCompleted && $0.isDueToday }.count
    }
    
    var flaggedCount: Int {
        items.filter { $0.isFlagged && !$0.isCompleted }.count
    }
    
    var completionRate: Double {
        guard !items.isEmpty else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    // MARK: - Filtered and Sorted Items
    
    var filteredItems: [TodoItem] {
        items.filter { item in
            // Search text
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                let matchesTitle = item.title.lowercased().contains(query)
                let matchesNotes = item.notes.lowercased().contains(query)
                if !matchesTitle && !matchesNotes {
                    return false
                }
            }
            
            // Category filter
            if let selectedCategory, item.category != selectedCategory {
                return false
            }
            
            // Tab filter
            switch selectedFilter {
            case .all:
                return true
            case .today:
                return item.isDueToday
            case .upcoming:
                guard let dueDate = item.dueDate, !item.isCompleted else { return false }
                return dueDate >= Calendar.current.startOfDay(for: Date())
            case .flagged:
                return item.isFlagged
            case .completed:
                return item.isCompleted
            }
        }.sorted { lhs, rhs in
            let comparison: Bool
            switch sortOption {
            case .dueDate:
                let leftDate = lhs.dueDate ?? Date.distantFuture
                let rightDate = rhs.dueDate ?? Date.distantFuture
                comparison = leftDate < rightDate
            case .priority:
                comparison = lhs.priority > rhs.priority
            case .title:
                comparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            case .createdAt:
                comparison = lhs.createdAt > rhs.createdAt
            }
            return sortAscending ? comparison : !comparison
        }
    }
    
    // MARK: - Actions
    
    func add(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: Priority = .none,
        category: TodoCategory = .personal,
        isFlagged: Bool = false,
        subtasks: [Subtask] = []
    ) {
        let newItem = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes,
            dueDate: dueDate,
            priority: priority,
            category: category,
            isFlagged: isFlagged,
            subtasks: subtasks
        )
        items.insert(newItem, at: 0)
    }
    
    func update(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.updatedAt = Date()
            items[index] = updated
        }
    }
    
    func toggleCompletion(for item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                items[index].isCompleted.toggle()
                items[index].completedAt = items[index].isCompleted ? Date() : nil
            }
        }
    }
    
    func toggleFlag(for item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                items[index].isFlagged.toggle()
            }
        }
    }
    
    func delete(item: TodoItem) {
        items.removeAll(where: { $0.id == item.id })
    }
    
    func delete(at offsets: IndexSet) {
        let currentFiltered = filteredItems
        for index in offsets {
            let itemToDelete = currentFiltered[index]
            delete(item: itemToDelete)
        }
    }
    
    func toggleSubtask(itemId: UUID, subtaskId: UUID) {
        guard let itemIndex = items.firstIndex(where: { $0.id == itemId }),
              let subIndex = items[itemIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items[itemIndex].subtasks[subIndex].isCompleted.toggle()
            
            // If all subtasks completed, auto-complete parent or vice versa if needed
            let allSubtasksDone = items[itemIndex].subtasks.allSatisfy { $0.isCompleted }
            if allSubtasksDone && !items[itemIndex].subtasks.isEmpty {
                items[itemIndex].isCompleted = true
                items[itemIndex].completedAt = Date()
            }
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: saveURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error saving todos: \(error)")
        }
    }
    
    private func load() {
        do {
            guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
            let data = try Data(contentsOf: saveURL)
            items = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("Error loading todos: \(error)")
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
        let nextWeek = calendar.date(byAdding: .day, value: 5, to: today)
        
        items = [
            TodoItem(
                title: "Explorar TestXtool en iPhone Duo",
                notes: "Probar la vista adaptativa de dos pantallas con NavigationSplitView.",
                dueDate: today,
                priority: .high,
                category: .work,
                isFlagged: true,
                subtasks: [
                    Subtask(title: "Abrir simulador iPhone Duo", isCompleted: true),
                    Subtask(title: "Comprobar layout dividido", isCompleted: false),
                    Subtask(title: "Verificar logo de la app", isCompleted: false)
                ]
            ),
            TodoItem(
                title: "Diseñar interfaz moderna en SwiftUI",
                notes: "Usar colores dinámicos, glassmorphism, SF Symbols y animaciones de resorte.",
                dueDate: today,
                priority: .medium,
                category: .ideas,
                isFlagged: true,
                subtasks: [
                    Subtask(title: "Definir paleta de colores", isCompleted: true),
                    Subtask(title: "Crear componentes modulares", isCompleted: true),
                    Subtask(title: "Añadir soporte Dark Mode", isCompleted: true)
                ]
            ),
            TodoItem(
                title: "Preparar demo de funcionalidades locales",
                notes: "Persistencia JSON atómica, filtros en tiempo real, checklist de subtareas.",
                dueDate: tomorrow,
                priority: .high,
                category: .study,
                isFlagged: false,
                subtasks: [
                    Subtask(title: "Filtros por categoría", isCompleted: true),
                    Subtask(title: "Selector de prioridad", isCompleted: false)
                ]
            ),
            TodoItem(
                title: "Hacer compras semanales",
                notes: "Frutas, verduras frescas, café en grano y avena.",
                dueDate: tomorrow,
                priority: .low,
                category: .shopping,
                isFlagged: false,
                subtasks: [
                    Subtask(title: "Manzanas y plátanos", isCompleted: false),
                    Subtask(title: "Café de especialidad", isCompleted: false)
                ]
            ),
            TodoItem(
                title: "Entrenamiento funcional de 45 min",
                notes: "Cardio y fuerza en el gimnasio.",
                dueDate: nextWeek,
                priority: .medium,
                category: .health,
                isFlagged: false
            ),
            TodoItem(
                title: "Organizar repositorio Git en GitHub",
                notes: "Primer commit, rama main y remote origin configurados.",
                isCompleted: true,
                completedAt: Date(),
                dueDate: today,
                priority: .medium,
                category: .work,
                isFlagged: false
            )
        ]
    }
}
