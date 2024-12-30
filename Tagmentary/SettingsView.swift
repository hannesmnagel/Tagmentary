//
//  SettingsView.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import SwiftUI
import HealthKit

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("trackSleepData") var trackSleepData = false
    @AppStorage("xAxisZoom") private var xAxisZoom = 10.0
    @AppStorage("log") var logs = ""
    @Environment(HealthDataManager.self) var healthDataManager

    var body: some View {
        Form {
            Section {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .listRowBackground(Color.clear)
            }
            Section("Chart Settings"){
                HStack{
                    Text("X Axis Zoom")
                    Slider(value: $xAxisZoom, in: 1...50)
                }
            }
            Section("Import") {
                Button("Add some random sample data") {
                    let coffeeTag = Tag(name: "Coffees After 7pm")
                    let sleepTag = Tag(name: "Sleep Duration")
                    modelContext.insert(coffeeTag)
                    modelContext.insert(sleepTag)
                    generateSampleData(coffeeTag: coffeeTag, sleepTag: sleepTag).forEach { event in
                        modelContext.insert(event)
                    }
                    trackEvent("added sample data")
                }
                Toggle("Track sleep data automatically", isOn: $trackSleepData)
                    .task(id: trackSleepData) {
                        if trackSleepData {
                            do {
                                try await healthDataManager.requestAuthorization(for: [
                                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
                                ])
                                try await healthDataManager.observeSleepData()
                                trackEvent("tracking sleep data")
                            } catch {
                                trackEvent("tracking sleep failed", with: ["error" : String(describing: error)])
                                trackSleepData = false
                            }
                        } else {
                            do {
                                try await healthDataManager.stopObservingSleepData()
                                trackEvent("stopped tracking sleep")
                            } catch {
                                trackEvent("stopped tracking sleep failed", with: ["error" : String(describing: error)])
                                trackSleepData = true
                            }
                        }
                    }
            }

            Button("Delete Everything", systemImage: "trash", role: .destructive) {
                try? modelContext.delete(model: Event.self)
                try? modelContext.delete(model: Tag.self)
                trackEvent("deleted everything")
            }
            .foregroundStyle(.red)
            Section("log"){
                Text(logs)
                Button("Clear logs"){UserDefaults.standard.removeObject(forKey: "log")}
            }
        }
    }
    private func generateSampleData(coffeeTag: Tag, sleepTag: Tag) -> [Event] {
        var events: [Event] = []
        let now = Date()
        let calendar = Calendar.current

        for dayOffset in 0..<30 {
            // Calculate the date for the event
            guard let eventDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }

            // Randomly generate the number of coffees for the tag "coffeesAfterSevenPm"
            let coffeesAfterSevenPm = Double(Int.random(in: 0...5))
            let coffeesEvent = Event(timestamp: eventDate, tag: coffeeTag, value: coffeesAfterSevenPm)
            events.append(coffeesEvent)

            // Generate sleep duration inversely related to coffees with added randomness
            let baseSleepHours: Double = 8.0
            let sleepReductionPerCoffee: Double = 0.5
            let calculatedSleepDuration = baseSleepHours - (coffeesAfterSevenPm * sleepReductionPerCoffee)
            let randomOffset = Double.random(in: -0.5...0.5) // Adds up to ±0.5 hours of randomness
            let sleepDuration = max(min(calculatedSleepDuration + randomOffset, 9.0), 3.5) // Ensure reasonable bounds (3.5 to 9.0 hours)
            let sleepEvent = Event(timestamp: eventDate, tag: sleepTag, value: sleepDuration)
            events.append(sleepEvent)
        }

        return events
    }
}

#Preview {
    SettingsView()
}
