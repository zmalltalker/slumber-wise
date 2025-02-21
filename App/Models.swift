import SwiftUI

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
        completed: false,
        dateCompleted: nil
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
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        challengeName: "Evening Herbal Tea",
        challengeDescription: "Try a cup of caffeine-free herbal tea like chamomile an hour before bed to help you relax.",
        category: "Nutrition",
        isAccepted: true,
        completed: true,
        dateCompleted: Calendar.current.date(byAdding: .day, value: -5, to: Date())
    ),
    Challenge(
        id: UUID(),
        date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
        challengeName: "Daytime Exercise",
        challengeDescription: "Get at least 30 minutes of moderate exercise today, but not within 2 hours of bedtime.",
        category: "Activity",
        isAccepted: true,
        completed: true,
        dateCompleted: Calendar.current.date(byAdding: .day, value: -6, to: Date())
    )
]
