//
//  TagmentaryApp.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/21/24.
//

import SwiftUI
import SwiftData
import HealthKit
import Aptabase

@main
struct TagmentaryApp: App {
    var sharedModelContainer: ModelContainer
    let healthDataManager : HealthDataManager

    init() {
        Aptabase.shared.initialize(appKey: "A-SH-0981045705", options: InitOptions(host: "https://analytics.hannesnagel.com", flushInterval: 1))
        let container : ModelContainer = {
            let schema = Schema([
                Event.self,
                Tag.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        self.sharedModelContainer = container
        self.healthDataManager = HealthDataManager(context: container.mainContext)
    }
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task(id: scenePhase) {
                    trackEvent(scenePhase == .active ? "launch" : "close")
                }
                .environment(healthDataManager)
        }
        .modelContainer(sharedModelContainer)
    }
}


func trackEvent(_ event: String, with parameters: [String: Any] = [:]) {
    Aptabase.shared.trackEvent(event, with: parameters)
}
