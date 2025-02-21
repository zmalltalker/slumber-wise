import Foundation

// MARK: - Sleep Models for HealthKit

enum SleepStageType: String, Codable {
    case core = "core"
    case deep = "deep"
    case rem = "rem"
    case awake = "awake"
}

struct SleepStage: Identifiable, Codable {
    var id = UUID()
    let stage: SleepStageType
    var minutes: Double
    
    enum CodingKeys: String, CodingKey {
        case stage, minutes
    }
    
    init(stage: SleepStageType, minutes: Double) {
        self.stage = stage
        self.minutes = minutes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stage = try container.decode(SleepStageType.self, forKey: .stage)
        minutes = try container.decode(Double.self, forKey: .minutes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stage, forKey: .stage)
        try container.encode(minutes, forKey: .minutes)
    }
}

struct SleepDay: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var stages: [SleepStage]
    
    enum CodingKeys: String, CodingKey {
        case date, stages
    }
    
    init(date: Date, stages: [SleepStage]) {
        self.date = date
        self.stages = stages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        stages = try container.decode([SleepStage].self, forKey: .stages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(stages, forKey: .stages)
    }
    
    // MARK: - Helper Methods
    
    var totalSleepMinutes: Double {
        stages.filter { $0.stage != .awake }.reduce(0) { $0 + $1.minutes }
    }
    
    var totalAwakeMinutes: Double {
        stages.filter { $0.stage == .awake }.reduce(0) { $0 + $1.minutes }
    }
    
    var deepSleepMinutes: Double {
        stages.filter { $0.stage == .deep }.reduce(0) { $0 + $1.minutes }
    }
    
    var remSleepMinutes: Double {
        stages.filter { $0.stage == .rem }.reduce(0) { $0 + $1.minutes }
    }
    
    var coreSleepMinutes: Double {
        stages.filter { $0.stage == .core }.reduce(0) { $0 + $1.minutes }
    }
    
    var deepSleepPercentage: Double {
        let total = totalSleepMinutes + totalAwakeMinutes
        guard total > 0 else { return 0 }
        return (deepSleepMinutes / total) * 100
    }
    
    var remSleepPercentage: Double {
        let total = totalSleepMinutes + totalAwakeMinutes
        guard total > 0 else { return 0 }
        return (remSleepMinutes / total) * 100
    }
    
    var sleepEfficiency: Double {
        let total = totalSleepMinutes + totalAwakeMinutes
        guard total > 0 else { return 0 }
        return (totalSleepMinutes / total) * 100
    }
    
    // Helper function to format as hours and minutes
    func formatTotalSleepTime() -> String {
        let minutes = Int(totalSleepMinutes)
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// MARK: - Mock Data for Development

let mockSleepDays: [SleepDay] = [
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 210),
            SleepStage(stage: .deep, minutes: 50),
            SleepStage(stage: .rem, minutes: 440),
            SleepStage(stage: .awake, minutes: 10)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 220),
            SleepStage(stage: .deep, minutes: 55),
            SleepStage(stage: .rem, minutes: 45),
            SleepStage(stage: .awake, minutes: 15)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 200),
            SleepStage(stage: .deep, minutes: 45),
            SleepStage(stage: .rem, minutes: 35),
            SleepStage(stage: .awake, minutes: 20)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 230),
            SleepStage(stage: .deep, minutes: 60),
            SleepStage(stage: .rem, minutes: 50),
            SleepStage(stage: .awake, minutes: 10)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 190),
            SleepStage(stage: .deep, minutes: 40),
            SleepStage(stage: .rem, minutes: 30),
            SleepStage(stage: .awake, minutes: 25)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 210),
            SleepStage(stage: .deep, minutes: 50),
            SleepStage(stage: .rem, minutes: 40),
            SleepStage(stage: .awake, minutes: 15)
        ]
    ),
    SleepDay(
        date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
        stages: [
            SleepStage(stage: .core, minutes: 200),
            SleepStage(stage: .deep, minutes: 45),
            SleepStage(stage: .rem, minutes: 40),
            SleepStage(stage: .awake, minutes: 20)
        ]
    )
]
