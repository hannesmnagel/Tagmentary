//
//  HealthDataManager.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/25/24.
//

import SwiftUI
import HealthKit
import SwiftData

@Observable
final class HealthDataManager {
    private let healthStore = HKHealthStore()
    private let modelContext: ModelContext

    init(context: ModelContext){
        self.modelContext = context
        guard UserDefaults.standard.bool(forKey: "trackSleepData") else { return }
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        healthStore.execute(
            HKObserverQuery(sampleType: sleepType, predicate: nil) {
                query,
                completion,
                error in
                //fetch sleep data
                Task{@MainActor in
                    var log = UserDefaults.standard.string(forKey: "log") ?? ""
                    log.append("start ")
                    log.append(Date().formatted())
                    let sleepData = try await self.fetchSleepData(fromNightEndingOn: .now)
                    let tags = try self.modelContext.fetch(FetchDescriptor<Tag>())
                    let sleepTag = tags.first { $0.name == "Sleep" } ?? {
                        let tag = Tag(name: "Sleep")
                        self.modelContext.insert(tag)
                        log.append("; created new tag: Sleep")
                        return tag
                    }()
                    let startOfToday = Calendar.current.startOfDay(for: Date())

                    sleepTag.events.filter(
                        {
                            (-$0.timestamp.timeIntervalSince(startOfToday)) <= (3600*24)
                        }
                    )
                    .forEach {
                        log.append("; deleted: \($0.tag.name) at \($0.timestamp.formatted()) with \($0.value.formatted())")
                        self.modelContext.delete(
                            $0
                        )
                    }
                    let event = Event(timestamp: Date().addingTimeInterval(-(3600*24)), tag: sleepTag, value: sleepData.total)
                    self.modelContext.insert(event)
                    log.append("; set sleep: \(sleepData.total.formatted())\n")
                    UserDefaults.standard.set(log, forKey: "log")
                    
                    completion()
                }
            }
        )
    }

    // Request authorization for multiple data types
    func requestAuthorization(for types: [HKObjectType]) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data not available on this device"])
        }

        try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set(types)) { success, error in
                if let error = error {
                    continuation.resume(with: Result<Void, any Error>.failure(error))
                } else if !success {
                    continuation.resume(with: Result<Void, any Error>.failure(NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Authorization not granted"])))
                } else {
                    continuation.resume(with: .success(Void()))
                }
            }
        }
    }
    enum HealthDataManagerError: Error {
        case authorizationNotGranted, healthDataNotAvailable, failedToFetchSleepData
    }
    func fetchSleepData(fromNightEndingOn date: Date) async throws -> (rem: Double, deep: Double, core: Double, total: Double, awakenings: Int){
        try await withCheckedThrowingContinuation{con in
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

            let calendar = Calendar.current

            let startOfPreviousNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date.addingTimeInterval(-86400))!
            let endOfPreviousNight = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!

            let predicate = HKQuery.predicateForSamples(withStart: startOfPreviousNight, end: endOfPreviousNight, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample] else {
                    // Handle no data available
                    con.resume(throwing: HealthDataManagerError.failedToFetchSleepData)
                    return
                }
                let filteredSamples = samples.filter({
                    $0.sourceRevision.source.bundleIdentifier.starts(with: "com.apple.health")
                })

                var remSleepSeconds: TimeInterval = 0
                var deepSleepSeconds: TimeInterval = 0
                var coreSleepSeconds: TimeInterval = 0
                var awakeningsCount = 0
                var totalSleepSeconds: TimeInterval = 0

                for sample in filteredSamples {
                    let value = sample.value
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)

                    switch value {
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        remSleepSeconds += duration
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        coreSleepSeconds += duration
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        deepSleepSeconds += duration
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        awakeningsCount += 1
                    default:
                        break
                    }
                }

                totalSleepSeconds = deepSleepSeconds + coreSleepSeconds + remSleepSeconds

                con.resume(returning: (remSleepSeconds/3600, deepSleepSeconds/3600, coreSleepSeconds/3600, totalSleepSeconds/3600, awakeningsCount))

            }

            healthStore.execute(query)
        }
    }
    func observeSleepData() async throws {
        try await healthStore.enableBackgroundDelivery(for: .categoryType(forIdentifier: .sleepAnalysis)!, frequency: .hourly)
    }
    func stopObservingSleepData() async throws {
        try await healthStore.disableBackgroundDelivery(for: .categoryType(forIdentifier: .sleepAnalysis)!)
    }
}
