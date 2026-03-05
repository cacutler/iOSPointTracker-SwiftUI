//  Game.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
enum WinCondition: String, Codable {
    case highScore = "highScore"
    case lowScore = "lowScore"
}
@Model
final class Game {
    var id: UUID
    var name: String
    var date: Date
    var players: [Player]
    var isActive: Bool
    var currentRound: Int
    var rounds: [Round]
    var winConditionRaw: String = WinCondition.highScore.rawValue
    var winCondition: WinCondition {
        get {
            WinCondition(rawValue: winConditionRaw) ?? .highScore
        }
        set {
            winConditionRaw = newValue.rawValue
        }
    }
    init(name: String, playerNames: [String], winCondition: WinCondition = .highScore) {
        self.id = UUID()
        self.name = name
        self.date = Date()
        self.players = playerNames.map {Player(name: $0)}
        self.isActive = true
        self.currentRound = 1
        self.rounds = []
        self.winConditionRaw = winCondition.rawValue
    }
    var winner: Player? {
        switch winCondition {
        case .highScore:
            return players.max(by: {$0.score < $1.score})
        case .lowScore:
            return players.min(by: {$0.score < $1.score})
        }
    }
    func nextRound() {
        currentRound += 1
    }
}
