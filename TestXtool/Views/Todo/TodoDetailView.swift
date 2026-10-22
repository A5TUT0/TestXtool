import SwiftUI

struct TodoDetailView: View {
    @Bindable var store: TodoStore
    let itemId: UUID
    @State private var newSubtaskTitle: String = ""
    @State private var showingEditSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private var item: TodoItem? {
        store.items.first(where: { $0.id == itemId })
    }
    
    private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Group {
            if let item = item {
                List {
                    // Header Section: Status & Title
                    Section {
                        HStack(alignment: .top, spacing: 14) {
                            Button {
                                store.toggleCompletion(for: item)
                            } label: {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 26))
                                    .foregroundColor(item.isCompleted ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .strikethrough(item.isCompleted, color: .secondary)
                                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                                
                                if item.isCompleted, let completedAt = item.completedAt {
                                    Text("Completada el \(fullDateFormatter.string(from: completedAt))")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                store.toggleFlag(for: item)
                            } label: {
                                Image(systemName: item.isFlagged ? "flag.fill" : "flag")
                                    .foregroundColor(item.isFlagged ? .orange : .secondary)
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Metadata Badges Section
                    Section("Detalles") {
                        HStack {
                            Label("Categoría", systemImage: "folder.fill")
                            Spacer()
                            CategoryBadge(category: item.category)
                        }
                        
                        HStack {
                            Label("Prioridad", systemImage: "line.3.horizontal.decrease.circle")
                            Spacer()
                            PriorityBadge(priority: item.priority)
                        }
                        
                        if let dueDate = item.dueDate {
                            HStack {
                                Label("Fecha límite", systemImage: "calendar")
                                Spacer()
                                Text(fullDateFormatter.string(from: dueDate))
                                    .font(.subheadline)
                                    .foregroundColor(item.isOverdue ? .red : .primary)
                            }
                        }
                    }
                    
                    // Notes Section
                    Section("Notas") {
                        if item.notes.isEmpty {
                            Text("Sin notas adicionales")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            Text(item.notes)
                                .font(.body)
                        }
                    }
                    
                    // Subtasks Checklist Section
                    Section("Subtareas / Checklist (\(item.subtasks.filter { $0.isCompleted }.count)/\(item.subtasks.count))") {
                        ForEach(item.subtasks) { subtask in
                            HStack(spacing: 12) {
                                Button {
                                    store.toggleSubtask(itemId: item.id, subtaskId: subtask.id)
                                } label: {
                                    Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 20))
                                        .foregroundColor(subtask.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                Text(subtask.title)
                                    .strikethrough(subtask.isCompleted, color: .secondary)
                                    .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                                
                                Spacer()
                            }
                        }
                        .onDelete { offsets in
                            var updated = item
                            updated.subtasks.remove(atOffsets: offsets)
                            store.update(updated)
                        }
                        
                        // Add subtask inline input
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            TextField("Añadir subtarea...", text: $newSubtaskTitle)
                                .onSubmit {
                                    addSubtask(to: item)
                                }
                            if !newSubtaskTitle.isEmpty {
                                Button("Agregar") {
                                    addSubtask(to: item)
                                }
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Danger Zone / Delete
                    Section {
                        Button(role: .destructive) {
                            store.delete(item: item)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "trash.fill")
                                Text("Eliminar Tarea")
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Detalles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Editar") {
                            showingEditSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    EditTodoSheet(store: store, item: item)
                }
            } else {
                ContentUnavailableView(
                    "Selecciona una tarea",
                    systemImage: "checklist",
                    description: Text("Elige una tarea de la lista para ver o editar sus detalles.")
                )
            }
        }
    }
    
    private func addSubtask(to currentItem: TodoItem) {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = currentItem
        updated.subtasks.append(Subtask(title: trimmed))
        store.update(updated)
        newSubtaskTitle = ""
    }
}
