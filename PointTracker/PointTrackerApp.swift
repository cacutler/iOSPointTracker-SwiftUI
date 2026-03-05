//  PointTrackerApp.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
@main
struct PointTrackerApp: App {
    let container: ModelContainer = {
        let schema = Schema([Game.self, Player.self, ScoreEntry.self, Round.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // If migration fails, delete and recreate the store
            let config = ModelConfiguration(schema: schema)
            do {
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(container)
    }
}
