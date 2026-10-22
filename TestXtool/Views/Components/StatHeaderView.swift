import SwiftUI

struct StatHeaderView: View {
    let store: TodoStore
    
    var body: some View {
        VStack(spacing: 14) {
            // Top banner with Progress Bar
            HStack(spacing: 16) {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 6)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(store.completionRate))
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.completionRate)
                    
                    Text("\(Int(store.completionRate * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progreso General")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(store.completedCount) de \(store.totalCount) tareas completadas")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            
            // Grid of 4 quick cards
            HStack(spacing: 10) {
                QuickStatCard(title: "Hoy", count: store.todayCount, icon: "calendar.day.timeline.leading", color: .blue)
                QuickStatCard(title: "Pendientes", count: store.pendingCount, icon: "clock.fill", color: .orange)
                QuickStatCard(title: "Destacadas", count: store.flaggedCount, icon: "flag.fill", color: .red)
                QuickStatCard(title: "Completas", count: store.completedCount, icon: "checkmark.circle.fill", color: .green)
            }
        }
    }
}

private struct QuickStatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}
