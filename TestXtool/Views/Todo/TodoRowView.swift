import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let onToggleComplete: () -> Void
    let onToggleFlag: () -> Void
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 14) {
                // Checkbox
                Button(action: onToggleComplete) {
                    ZStack {
                        Circle()
                            .stroke(item.isCompleted ? Color.green : Color.secondary.opacity(0.4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if item.isCompleted {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 16, weight: .semibold))
                            .strikethrough(item.isCompleted, color: .secondary)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if item.isFlagged {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    if !item.notes.isEmpty {
                        Text(item.notes)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Metadata Badges (Category, Priority, Due Date, Subtasks)
                    HStack(spacing: 8) {
                        CategoryBadge(category: item.category)
                        
                        PriorityBadge(priority: item.priority)
                        
                        if let dueDate = item.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: item.isOverdue ? "exclamationmark.circle" : "calendar")
                                    .font(.system(size: 10))
                                Text(item.isDueToday ? "Hoy" : dateFormatter.string(from: dueDate))
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(item.isOverdue ? .red : (item.isDueToday ? .blue : .secondary))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(item.isOverdue ? Color.red.opacity(0.12) : Color.secondary.opacity(0.1))
                            )
                        }
                        
                        if !item.subtasks.isEmpty {
                            let completedSubtasks = item.subtasks.filter { $0.isCompleted }.count
                            HStack(spacing: 3) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 10))
                                Text("\(completedSubtasks)/\(item.subtasks.count)")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.secondary.opacity(0.1)))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading) {
            Button {
                onToggleComplete()
            } label: {
                Label(item.isCompleted ? "Desmarcar" : "Completar", systemImage: item.isCompleted ? "arrow.uturn.backward" : "checkmark")
            }
            .tint(.green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
            
            Button {
                onToggleFlag()
            } label: {
                Label(item.isFlagged ? "Quitar marca" : "Destacar", systemImage: item.isFlagged ? "flag.slash" : "flag.fill")
            }
            .tint(.orange)
        }
        .contextMenu {
            Button(action: onToggleComplete) {
                Label(item.isCompleted ? "Marcar como pendiente" : "Marcar como completada", systemImage: item.isCompleted ? "circle" : "checkmark.circle")
            }
            Button(action: onToggleFlag) {
                Label(item.isFlagged ? "Quitar destacada" : "Destacar tarea", systemImage: item.isFlagged ? "flag.slash" : "flag")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar tarea", systemImage: "trash")
            }
        }
    }
}
