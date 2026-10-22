import Foundation

struct TodoItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var notes: String = ""
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var dueDate: Date? = nil
    var priority: Priority = .none
    var category: TodoCategory = .personal
    var isFlagged: Bool = false
    var subtasks: [Subtask] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }
    
    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var subtasksCompletionRatio: Double {
        guard !subtasks.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
}
