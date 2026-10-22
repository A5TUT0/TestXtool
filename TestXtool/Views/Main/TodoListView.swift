import SwiftUI

struct TodoListView: View {
    @Bindable var store: TodoStore
    @State private var selectedItemId: UUID? = nil
    @State private var showingAddSheet: Bool = false
    @State private var quickAddText: String = ""
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedItemId) {
                // Statistics Header Card
                Section {
                    StatHeaderView(store: store)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                // Filter Tabs & Category Pills
                Section {
                    FilterChipsView(store: store)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                // Tasks List Section
                Section {
                    if store.filteredItems.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checklist")
                                .font(.system(size: 42))
                                .foregroundStyle(.secondary)
                            Text("No hay tareas")
                                .font(.headline)
                            Text("No se encontraron tareas con los filtros actuales o la búsqueda.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(store.filteredItems) { item in
                            TodoRowView(
                                item: item,
                                onToggleComplete: {
                                    store.toggleCompletion(for: item)
                                },
                                onToggleFlag: {
                                    store.toggleFlag(for: item)
                                },
                                onSelect: {
                                    selectedItemId = item.id
                                },
                                onDelete: {
                                    store.delete(item: item)
                                    if selectedItemId == item.id {
                                        selectedItemId = nil
                                    }
                                }
                            )
                            .tag(item.id)
                        }
                        .onDelete(perform: store.delete)
                    }
                } header: {
                    HStack {
                        Text("\(store.selectedFilter.rawValue) (\(store.filteredItems.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $store.searchText, prompt: "Buscar tareas o notas...")
            .navigationTitle("TestXtool")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Ordenar por", selection: $store.sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        
                        Button {
                            store.sortAscending.toggle()
                        } label: {
                            Label(
                                store.sortAscending ? "Ascendente" : "Descendente",
                                systemImage: store.sortAscending ? "arrow.up" : "arrow.down"
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Quick inline task adder bar
                HStack(spacing: 12) {
                    TextField("Añadir tarea rápida...", text: $quickAddText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            submitQuickAdd()
                        }
                    
                    Button(action: submitQuickAdd) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(quickAddText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
                    }
                    .disabled(quickAddText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoSheet(store: store)
            }
        } detail: {
            NavigationStack {
                if let selectedItemId = selectedItemId {
                    TodoDetailView(store: store, itemId: selectedItemId)
                } else {
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .opacity(0.8)
                        
                        Text("TestXtool Duo")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Selecciona una tarea de la lista para ver sus subtareas, notas y opciones detalladas.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 280)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
                    .navigationTitle("Detalles")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private func submitQuickAdd() {
        let trimmed = quickAddText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            store.add(
                title: trimmed,
                category: store.selectedCategory ?? .personal
            )
        }
        quickAddText = ""
    }
}
