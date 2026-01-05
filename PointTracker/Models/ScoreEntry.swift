//  ScoreEntry.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
@Model
final class ScoreEntry {
    var points: Int
    var round: Int
    var timestamp: Date
    init(points: Int, round: Int) {
        self.points = points
        self.round = round
        self.timestamp = Date()
    }
}
