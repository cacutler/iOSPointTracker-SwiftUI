//  Player.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
@Model
final class Player: Identifiable {
    var id: UUID
    var name: String
    var score: Int
    var scoreHistory: [ScoreEntry]
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.score = 0
        self.scoreHistory = []
    }
    func addPoints(_ points: Int, round: Int) {
        score += points
        scoreHistory.append(ScoreEntry(points: points, round: round))
    }
    func undoLastScore() {
        guard let lastScore = scoreHistory.popLast() else {return}
        score -= lastScore.points
    }
    func scoresForRound(_ round: Int) -> [Int] {
        scoreHistory.filter {$0.round == round}.map {$0.points}
    }
    func totalForRound(_ round: Int) -> Int {
        scoresForRound(round).reduce(0, +)
    }
}
