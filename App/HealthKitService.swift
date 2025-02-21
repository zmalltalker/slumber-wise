import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.errorMessage = "HealthKit is not available on this device"
            return
        }
        
        healthStore.getRequestStatusForAuthorization(toShare: [], read: [sleepType]) { (status, error) in
            DispatchQueue.main.async {
                switch status {
                case .unnecessary:
                    self.isAuthorized = true
                default:
                    self.isAuthorized = false
                }
            }
        }
    }
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit is not available on this device"
            }
            return false
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
            
            DispatchQueue.main.async {
                self.isAuthorized = true
                self.errorMessage = nil
            }
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to request HealthKit authorization: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Sleep Data Retrieval
    
    func fetchSleepData(forDays days: Int = 7) async -> [SleepDay]? {
        let calendar = Calendar.current
        
        // Calculate the start and end dates
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: endDate) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to calculate date range"
            }
            return nil
        }
        
        // Create the predicate for the query
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Define the sort descriptor for the query
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // Perform the query
        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                let query = HKSampleQuery(
                    sampleType: sleepType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [sortDescriptor]
                ) { (_, samples, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let samples = samples else {
                        continuation.resume(throwing: NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No samples returned"]))
                        return
                    }
                    
                    continuation.resume(returning: samples)
                }
                
                healthStore.execute(query)
            }
            
            // Process the sleep samples
            return processSleepSamples(samples as? [HKCategorySample])
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func processSleepSamples(_ samples: [HKCategorySample]?) -> [SleepDay] {
        guard let samples = samples else { return [] }
        
        let calendar = Calendar.current
        var sleepDayDict = [String: [SleepStage]]()
        
        for sample in samples {
            // Skip samples with zero duration
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            if duration <= 0 { continue }
            
            // Get date string to group by day
            let dateString = dateFormatter.string(from: sample.startDate)
            
            // Convert HK sleep value to our enum
            guard let stageType = sleepStageFromHKCategory(sample.value) else { continue }
            
            // Calculate minutes
            let minutes = duration / 60
            
            // Add or update the stage in the dictionary
            if var stages = sleepDayDict[dateString] {
                // Check if we already have this stage
                if let index = stages.firstIndex(where: { $0.stage == stageType }) {
                    stages[index].minutes += minutes
                } else {
                    stages.append(SleepStage(stage: stageType, minutes: minutes))
                }
                sleepDayDict[dateString] = stages
            } else {
                sleepDayDict[dateString] = [SleepStage(stage: stageType, minutes: minutes)]
            }
        }
        
        // Convert dictionary to array of SleepDay
        var sleepDays: [SleepDay] = []
        for (dateString, stages) in sleepDayDict {
            if let date = dateFormatter.date(from: dateString) {
                sleepDays.append(SleepDay(date: date, stages: stages))
            }
        }
        
        // Sort by date (newest first)
        sleepDays.sort { $0.date > $1.date }
        
        return sleepDays
    }
    
    private func sleepStageFromHKCategory(_ value: Int) -> SleepStageType? {
        switch value {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return .awake
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return .core
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return .awake
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return .core
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return .deep
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return .rem
        default:
            return nil
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    // MARK: - Data Export
    
    func sleepDataToJSON(_ sleepDays: [SleepDay]) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        // Create the JSON structure
        struct SleepDataPayload: Codable {
            let sleepData: [SleepDayPayload]
        }
        
        struct SleepDayPayload: Codable {
            let date: String
            let stages: [SleepStagePayload]
        }
        
        struct SleepStagePayload: Codable {
            let stage: String
            let minutes: Double
        }
        
        // Convert our model to the payload format
        let payloadDays = sleepDays.map { day -> SleepDayPayload in
            let formattedDate = self.dateFormatter.string(from: day.date)
            let payloadStages = day.stages.map { stage -> SleepStagePayload in
                SleepStagePayload(
                    stage: stage.stage.rawValue.capitalized,
                    minutes: stage.minutes
                )
            }
            return SleepDayPayload(date: formattedDate, stages: payloadStages)
        }
        
        let payload = SleepDataPayload(sleepData: payloadDays)
        
        do {
            return try encoder.encode(payload)
        } catch {
            print("Error encoding sleep data: \(error)")
            return nil
        }
    }
}
