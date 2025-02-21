import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedFilter: FilterOption = .all
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Filter pills
                    FilterPillsView(selectedFilter: $selectedFilter)
                        .padding(.bottom, 5)
                    
                    // Filtered challenges list
                    ForEach(filteredChallenges) { challenge in
                        ChallengeHistoryCard(challenge: challenge)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("History")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        appState.resetAllChallenges()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // Filter challenges based on selected filter
    private var filteredChallenges: [Challenge] {
        switch selectedFilter {
        case .all:
            return appState.challenges
        case .completed:
            return appState.challenges.filter { $0.completed }
        case .pending:
            return appState.challenges.filter { !$0.completed }
        }
    }
}

struct FilterPillsView: View {
    @Binding var selectedFilter: FilterOption
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    FilterPill(
                        title: option.rawValue,
                        isSelected: selectedFilter == option,
                        action: {
                            selectedFilter = option
                        }
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .default))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : Color(.systemGray))
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "3A366E") : Color(.systemGray5))
                )
        }
    }
}

struct ChallengeHistoryCard: View {
    let challenge: Challenge
    
    var body: some View {
        HStack(alignment: .top) {
            // Status bar indicator
            Rectangle()
                .fill(challenge.completed ? Color.green : Color(hex: "FF9500"))
                .frame(width: 4)
                .cornerRadius(2)
            
            // Challenge content
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedDate(challenge.date))
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
                Text(challenge.challengeName)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                    .padding(.bottom, 2)
                
                // Category tag
                Text(challenge.category.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .foregroundColor(Color(hex: "3A366E"))
                    .cornerRadius(10)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Completion status
            if challenge.completed {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            } else {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF9500"))
                        .frame(width: 24, height: 24)
                    
                    Text("!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Format date to "MMM D" format
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(AppState())
    }
}
