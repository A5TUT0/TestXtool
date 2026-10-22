import SwiftUI

struct EditTodoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: TodoStore
    let item: TodoItem
    
    @State private var title: String
    @State private var notes: String
    @State private var category: TodoCategory
    @State private var priority: Priority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var isFlagged: Bool
    
    init(store: TodoStore, item: TodoItem) {
        self.store = store
        self.item = item
        _title = State(initialValue: item.title)
        _notes = State(initialValue: item.notes)
        _category = State(initialValue: item.category)
        _priority = State(initialValue: item.priority)
        _hasDueDate = State(initialValue: item.dueDate != nil)
        _dueDate = State(initialValue: item.dueDate ?? Date())
        _isFlagged = State(initialValue: item.isFlagged)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información básica") {
                    TextField("Título de la tarea", text: $title)
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Clasificación") {
                    Picker("Categoría", selection: $category) {
                        ForEach(TodoCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                        }
                    }
                    
                    Picker("Prioridad", selection: $priority) {
                        ForEach(Priority.allCases) { pri in
                            Label(pri.rawValue, systemImage: pri.iconName).tag(pri)
                        }
                    }
                    
                    Toggle(isOn: $isFlagged) {
                        Label("Destacada", systemImage: "flag.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Fecha y recordatorio") {
                    Toggle("Asignar fecha límite", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Fecha", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle("Editar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func save() {
        var updated = item
        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.notes = notes
        updated.category = category
        updated.priority = priority
        updated.dueDate = hasDueDate ? dueDate : nil
        updated.isFlagged = isFlagged
        store.update(updated)
        dismiss()
    }
}
