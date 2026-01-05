//  PointTrackerApp.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
@main
struct PointTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [Game.self, Player.self, ScoreEntry.self, Round.self])
    }
}
