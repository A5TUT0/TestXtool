import SwiftUI

struct ContentView: View {
    @State private var store = TodoStore()
    
    var body: some View {
        TodoListView(store: store)
    }
}

#Preview {
    ContentView()
}
