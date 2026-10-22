import SwiftUI

struct AddTodoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: TodoStore
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var category: TodoCategory = .personal
    @State private var priority: Priority = .none
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var isFlagged: Bool = false
    @State private var subtasks: [Subtask] = []
    @State private var newSubtaskText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información básica") {
                    TextField("Título de la tarea", text: $title)
                        .font(.headline)
                    
                    TextField("Notas o descripción (opcional)", text: $notes, axis: .vertical)
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
                        Label("Destacar", systemImage: "flag.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Fecha y recordatorio") {
                    Toggle("Asignar fecha límite", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Fecha", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                        
                        HStack {
                            Button("Hoy") {
                                dueDate = Date()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Mañana") {
                                if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                                    dueDate = tomorrow
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Próx. semana") {
                                if let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
                                    dueDate = nextWeek
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption)
                    }
                }
                
                Section("Subtareas") {
                    ForEach(subtasks) { subtask in
                        Text(subtask.title)
                    }
                    .onDelete { offsets in
                        subtasks.remove(atOffsets: offsets)
                    }
                    
                    HStack {
                        TextField("Nueva subtarea", text: $newSubtaskText)
                        Button("Añadir") {
                            addSubtask()
                        }
                        .disabled(newSubtaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
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
    
    private func addSubtask() {
        let trimmed = newSubtaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        subtasks.append(Subtask(title: trimmed))
        newSubtaskText = ""
    }
    
    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        store.add(
            title: trimmedTitle,
            notes: notes,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            category: category,
            isFlagged: isFlagged,
            subtasks: subtasks
        )
        dismiss()
    }
}
