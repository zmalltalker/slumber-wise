import SwiftUI

@main
struct SlumberWiseApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appState)
            } else {
                OnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var challenges: [Challenge] = mockChallenges
    @Published var todaysChallenge: Challenge? = mockChallenges.first
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func acceptChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            var updatedChallenge = challenge
            updatedChallenge.isAccepted = true
            challenges[index] = updatedChallenge
            
            if todaysChallenge?.id == challenge.id {
                todaysChallenge = updatedChallenge
            }
        }
    }
    
    func completeChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            var updatedChallenge = challenge
            updatedChallenge.completed = true
            updatedChallenge.dateCompleted = Date()
            challenges[index] = updatedChallenge
            
            if todaysChallenge?.id == challenge.id {
                todaysChallenge = updatedChallenge
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "moon.stars")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
                .tag(1)
            
            SleepStatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            // Content pages
            TabView(selection: $currentPage) {
                onboardingPage(
                    title: "Welcome to SlumberWise",
                    subtitle: "Transform your sleep habits with personalized actions",
                    imageName: "moon.stars.fill",
                    index: 0
                )
                
                onboardingPage(
                    title: "Sleep Insights",
                    subtitle: "We analyze your sleep data to find patterns and opportunities",
                    imageName: "chart.bar.fill",
                    index: 1
                )
                
                onboardingPage(
                    title: "Daily Challenges",
                    subtitle: "Get one personalized recommendation each day to improve your sleep",
                    imageName: "checklist",
                    index: 2
                )
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentPage < 2 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .padding()
                } else {
                    Button("Get Started") {
                        appState.completeOnboarding()
                    }
                    .padding()
                    .background(Capsule().fill(Color(hex: "5CBDB9")))
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func onboardingPage(title: String, subtitle: String, imageName: String, index: Int) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(Color(hex: "5CBDB9"))
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "3A366E"))
            
            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .tag(index)
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var animateCompletion = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header
                    Text(formattedDate())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let challenge = appState.todaysChallenge {
                        // Challenge Card
                        VStack(alignment: .leading, spacing: 0) {
                            // Sleep Summary Section
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SLEEP SUMMARY")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("6h 42m")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                            
                            // Challenge Content
                            VStack(alignment: .leading, spacing: 15) {
                                Text(challenge.challengeName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(challenge.category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                Text(challenge.challengeDescription)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 5)
                                
                                if challenge.completed {
                                    completedView
                                } else if challenge.isAccepted {
                                    Button(action: {
                                        withAnimation {
                                            animateCompletion = true
                                            appState.completeChallenge(challenge)
                                        }
                                    }) {
                                        Text("Complete Challenge")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(hex: "5CBDB9"))
                                            .cornerRadius(20)
                                    }
                                    .padding(.top, 10)
                                } else {
                                    Button(action: {
                                        appState.acceptChallenge(challenge)
                                    }) {
                                        Text("Accept Challenge")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(hex: "5CBDB9"))
                                            .cornerRadius(20)
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    } else {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "moon.zzz")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(hex: "3A366E"))
                            
                            Text("No Challenge Today")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Check back tomorrow for your next sleep challenge")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .overlay(
                ZStack {
                    if animateCompletion {
                        Color.black.opacity(0.2)
                            .edgesIgnoringSafeArea(.all)
                        
                        ConfettiView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    animateCompletion = false
                                }
                            }
                    }
                }
            )
        }
    }
    
    private var completedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Challenge Completed")
                .font(.headline)
                .foregroundColor(.green)
            
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - History View

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

// MARK: - Sleep Stats View

struct SleepStatsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly overview card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Quick stats
                        HStack(spacing: 15) {
                            sleepStatItem(title: "Avg. Sleep", value: "6.8h", icon: "clock")
                            sleepStatItem(title: "Sleep Score", value: "82", icon: "chart.bar")
                            sleepStatItem(title: "Deep Sleep", value: "17%", icon: "moon.fill")
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Sleep chart
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sleep Duration")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            // Mock sleep chart
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(0..<7, id: \.self) { day in
                                    VStack(spacing: 5) {
                                        // Bar chart with stacked components
                                        sleepBar(day: day)
                                        
                                        // Day label
                                        Text(dayLabel(offset: 6 - day))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 150)
                            .padding(.bottom)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Sleep breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sleep Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Pie chart
                        ZStack {
                            // This is a simplistic representation
                            Circle()
                                .trim(from: 0, to: 0.45)
                                .stroke(Color(hex: "3A366E"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.45, to: 0.65)
                                .stroke(Color(hex: "5CBDB9"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.65, to: 0.95)
                                .stroke(Color(hex: "B8B5E1"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.95, to: 1)
                                .stroke(Color(hex: "FFD485"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(height: 200)
                        .padding(.vertical)
                        
                        // Legend
                        VStack(spacing: 10) {
                            legendItem(color: Color(hex: "3A366E"), label: "Core Sleep", value: "45%")
                            legendItem(color: Color(hex: "5CBDB9"), label: "REM Sleep", value: "20%")
                            legendItem(color: Color(hex: "B8B5E1"), label: "Deep Sleep", value: "30%")
                            legendItem(color: Color(hex: "FFD485"), label: "Awake", value: "5%")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Sleep trends
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sleep Trends")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            trendItem(label: "Bedtime", value: "11:38 PM", change: "-12 min", improved: true)
                            Divider()
                            trendItem(label: "Wake time", value: "6:42 AM", change: "+5 min", improved: false)
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Sleep Stats")
        }
    }
    
    private func sleepStatItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "5CBDB9"))
                .font(.title3)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func sleepBar(day: Int) -> some View {
        // Generate random but consistent bar heights for demo
        let seed = day * 10
        let deep = CGFloat(35 + (seed % 20))
        let rem = CGFloat(25 + ((seed + 5) % 15))
        let core = CGFloat(100 + ((seed + 10) % 50))
        let awake = CGFloat(5 + (seed % 10))
        
        return VStack(spacing: 0) {
            // Awake
            Rectangle()
                .fill(Color(hex: "FFD485"))
                .frame(width: 22, height: awake)
            
            // Core
            Rectangle()
                .fill(Color(hex: "B8B5E1"))
                .frame(width: 22, height: core)
            
            // REM
            Rectangle()
                .fill(Color(hex: "5CBDB9"))
                .frame(width: 22, height: rem)
            
            // Deep
            Rectangle()
                .fill(Color(hex: "3A366E"))
                .frame(width: 22, height: deep)
        }
        .cornerRadius(4)
    }
    
    private func dayLabel(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func legendItem(color: Color, label: String, value: String) -> some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 14, height: 14)
                .cornerRadius(2)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func trendItem(label: String, value: String, change: String, improved: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 4) {
                Image(systemName: improved ? "arrow.down" : "arrow.up")
                    .font(.caption)
                    .foregroundColor(improved ? .green : .orange)
                
                Text(change)
                    .font(.caption)
                    .foregroundColor(improved ? .green : .orange)
                
                Text("vs last week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(.systemGray3))
                
                Text("Profile")
                    .font(.title)
                
                Text("Manage your sleep profile, settings, and preferences")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Supporting Views

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

// MARK: - Celebration Animation

struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confetti) { piece in
                ConfettiPieceView(
                    position: piece.position,
                    color: piece.color,
                    rotation: piece.rotation,
                    size: piece.size
                )
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        var newPieces: [ConfettiPiece] = []
        
        for _ in 0..<100 {
            let piece = ConfettiPiece(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: -100...100)
                ),
                color: [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange].randomElement()!,
                rotation: Double.random(in: 0...360),
                size: CGFloat.random(in: 5...10)
            )
            newPieces.append(piece)
        }
        
        self.confetti = newPieces
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    var rotation: Double
    let size: CGFloat
}

struct ConfettiPieceView: View {
    @State private var animatedPosition: CGPoint
    let color: Color
    @State private var animatedRotation: Double
    let size: CGFloat
    
    init(position: CGPoint, color: Color, rotation: Double, size: CGFloat) {
        self._animatedPosition = State(initialValue: position)
        self.color = color
        self._animatedRotation = State(initialValue: rotation)
        self.size = size
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .position(x: animatedPosition.x, y: animatedPosition.y)
            .rotationEffect(Angle(degrees: animatedRotation))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatCount(1, autoreverses: false)) {
                    animatedPosition.y += UIScreen.main.bounds.height
                    animatedRotation += 360
                }
            }
    }
}

// MARK: - Models

enum FilterOption: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case pending = "Pending"
}

struct Challenge: Identifiable {
    let id: UUID
    let date: Date
    let challengeName: String
    let challengeDescription: String
    let category: String
    var isAccepted: Bool
    var completed: Bool
    var dateCompleted: Date?
}

// MARK: - Mock Data

let mockChallenges: [Challenge] = [
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
        challengeName: "Earlier Bedtime",
        challengeDescription: "Try going to bed 30 minutes earlier tonight to increase your deep sleep duration.",
        category: "Bedtime",
        isAccepted: false,
        completed: false,
        dateCompleted: nil
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        challengeName: "Reduce Screen Time",
        challengeDescription: "Avoid screens for at least 30 minutes before going to bed to improve sleep quality.",
        category: "Evening",
        isAccepted: true,
        completed: true,
        dateCompleted: Calendar.current.date(byAdding: .day, value: -1, to: Date())
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        challengeName: "Breathing Exercise",
        challengeDescription: "Try a 5-minute deep breathing exercise before bed to help your body relax.",
        category: "Routine",
        isAccepted: true,
        completed: false,
        dateCompleted: nil
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        challengeName: "Consistent Wake Time",
        challengeDescription: "Wake up at the same time as yesterday to help regulate your sleep cycle.",
        category: "Morning",
        isAccepted: true,
        completed: true,
        dateCompleted: Calendar.current.date(byAdding: .day, value: -3, to: Date())
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
        challengeName: "Room Temperature",
        challengeDescription: "Lower your bedroom temperature by 1-2 degrees to promote better sleep.",
        category: "Environment",
        isAccepted: true,
        completed: false,
        dateCompleted: nil
    )
]

// MARK: - Helper Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
                .environmentObject(AppState())
                .previewDisplayName("Onboarding")
            
            MainTabView()
                .environmentObject(AppState())
                .previewDisplayName("Main App")
        }
    }
}

