import SwiftUI

struct FilterChipsView: View {
    @Bindable var store: TodoStore
    
    var body: some View {
        VStack(spacing: 10) {
            // Filter Tabs (Todas, Hoy, etc)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                store.selectedFilter = tab
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 12))
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(store.selectedFilter == tab ? Color.primary : Color(uiColor: .tertiarySystemFill))
                            )
                            .foregroundColor(store.selectedFilter == tab ? Color(uiColor: .systemBackground) : .primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.selectedCategory = nil
                        }
                    } label: {
                        Text("Todas las categorías")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .strokeBorder(store.selectedCategory == nil ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(store.selectedCategory == nil ? .blue : .secondary)
                    }
                    
                    ForEach(TodoCategory.allCases) { category in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if store.selectedCategory == category {
                                    store.selectedCategory = nil
                                } else {
                                    store.selectedCategory = category
                                }
                            }
                        } label: {
                            CategoryBadge(category: category, isSelected: store.selectedCategory == category)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
