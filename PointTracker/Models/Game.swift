//  Game.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
@Model
final class Game {
    var id: UUID
    var name: String
    var date: Date
    var players: [Player]
    var isActive: Bool
    var currentRound: Int
    var rounds: [Round]
    init(name: String, playerNames: [String]) {
        self.id = UUID()
        self.name = name
        self.date = Date()
        self.players = playerNames.map {Player(name: $0)}
        self.isActive = true
        self.currentRound = 1
        self.rounds = []
    }
    var winner: Player? {
        players.max(by: {$0.score < $1.score})
    }
    func nextRound() {
        currentRound += 1
    }
}
