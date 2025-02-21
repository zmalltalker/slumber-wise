import SwiftUI

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var challenges: [Challenge] = mockChallenges
    @Published var todaysChallenge: Challenge?
    @Published var sleepData: [SleepDay] = []
    @Published var isLoadingSleepData: Bool = false
    
    // Services
    let healthKitService = HealthKitService()
    
    init() {
        // Randomly select a challenge when app starts
        pickRandomChallenge()
        
        // Load mock sleep data for now
        sleepData = mockSleepDays
        
        // We'll replace this with real data once HealthKit is authorized
        Task {
            if healthKitService.isAuthorized {
                await loadSleepData()
            }
        }
    }
    
    // MARK: - HealthKit Data
    
    func loadSleepData(days: Int = 7) async {
        DispatchQueue.main.async {
            self.isLoadingSleepData = true
        }
        
        if let data = await healthKitService.fetchSleepData(forDays: days) {
            DispatchQueue.main.async {
                self.sleepData = data
                self.isLoadingSleepData = false
            }
        } else {
            // Fallback to mock data if HealthKit data fails
            DispatchQueue.main.async {
                self.sleepData = mockSleepDays
                self.isLoadingSleepData = false
            }
        }
    }
    
    func requestHealthKitAuthorization() async -> Bool {
        return await healthKitService.requestAuthorization()
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        
        // Once onboarding is complete, try to load real sleep data
        Task {
            if healthKitService.isAuthorized {
                await loadSleepData()
            }
        }
    }
    
    // MARK: - Challenge Management
    
    func pickRandomChallenge() {
        // Filter for uncompleted challenges
        let availableChallenges = challenges.filter { !$0.completed }
        
        // If we have available challenges, pick a random one
        if !availableChallenges.isEmpty {
            todaysChallenge = availableChallenges.randomElement()
        } else {
            // Reset all challenges if none are available (for demo purposes)
            resetAllChallenges()
            todaysChallenge = challenges.randomElement()
        }
    }
    
    func resetAllChallenges() {
        for i in 0..<challenges.count {
            challenges[i].completed = false
            challenges[i].isAccepted = false
            challenges[i].dateCompleted = nil
        }
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
                
                // Automatically pick a new challenge after some delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.pickRandomChallenge()
                }
            }
        }
    }
    
    // MARK: - Sleep Stats Helpers
    
    var todaySleepSummary: String {
        guard let today = sleepData.first else {
            return "No data"
        }
        
        return today.formatTotalSleepTime()
    }
    
    var averageSleepTime: String {
        guard !sleepData.isEmpty else {
            return "0h 0m"
        }
        
        let totalMinutes = sleepData.reduce(0) { $0 + $1.totalSleepMinutes }
        let avgMinutes = totalMinutes / Double(sleepData.count)
        
        let hours = Int(avgMinutes) / 60
        let minutes = Int(avgMinutes) % 60
        
        return "\(hours)h \(minutes)m"
    }
    
    var deepSleepPercentage: String {
        guard !sleepData.isEmpty else {
            return "0%"
        }
        
        let avgPercentage = sleepData.reduce(0) { $0 + $1.deepSleepPercentage } / Double(sleepData.count)
        return "\(Int(round(avgPercentage)))%"
    }
    
    var sleepScore: Int {
        guard !sleepData.isEmpty else {
            return 0
        }
        
        // Simple sleep score algorithm (customize as needed)
        // Factors: total sleep time, deep sleep %, rem sleep %, sleep efficiency
        
        let totalSleepFactor = min(1.0, sleepData.first!.totalSleepMinutes / 480) // Target 8 hours
        let deepSleepFactor = min(1.2, sleepData.first!.deepSleepPercentage / 20) // Target 20% deep sleep
        let remSleepFactor = min(1.2, sleepData.first!.remSleepPercentage / 25)   // Target 25% REM sleep
        let efficiencyFactor = min(1.1, sleepData.first!.sleepEfficiency / 90)    // Target 90% efficiency
        
        let rawScore = (totalSleepFactor * 40) + (deepSleepFactor * 25) + (remSleepFactor * 25) + (efficiencyFactor * 10)
        
        return min(100, Int(rawScore))
    }
    
    // Calculate average bedtime and wake time
    func averageBedTime() -> String {
        guard !sleepData.isEmpty else { return "N/A" }
        
        // For this mock implementation, we'll just return a sample bedtime
        return "11:38 PM"
    }
    
    func averageWakeTime() -> String {
        guard !sleepData.isEmpty else { return "N/A" }
        
        // For this mock implementation, we'll just return a sample wake time
        return "6:42 AM"
    }
    
    // Calculate changes in bedtime and wake time
    func bedTimeChange() -> (minutes: Int, improved: Bool) {
        // Mock data: 12 minutes earlier (improvement)
        return (12, true)
    }
    
    func wakeTimeChange() -> (minutes: Int, improved: Bool) {
        // Mock data: 5 minutes later (not an improvement)
        return (5, false)
    }
}
