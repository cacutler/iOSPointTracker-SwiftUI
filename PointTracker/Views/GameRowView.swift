//  GameRowView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
struct GameRowView: View {
    let game: Game
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(game.name).font(.headline)
                if !game.isActive {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                }
            }
            HStack {
                Text(game.date, style: .date).font(.caption).foregroundStyle(.secondary)
                if game.isActive {
                    Text("• Round \(game.currentRound)").font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("• \(game.currentRound) rounds").font(.caption).foregroundStyle(.secondary)
                }
            }
            if let winner = game.winner, !game.isActive {
                Text("Winner: \(winner.name) (\(winner.score) pts)").font(.caption).foregroundStyle(.blue)
            }
        }
    }
}
#Preview("Game Row - Active") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, configurations: config)
    let game = Game(name: "Poker Night", playerNames: ["Alice", "Bob", "Charlie"])
    game.players[0].addPoints(150, round: 1)
    game.players[1].addPoints(100, round: 1)
    game.players[2].addPoints(120, round: 1)
    container.mainContext.insert(game)
    return List {
        GameRowView(game: game)
    }.modelContainer(container)
}
#Preview("Game Row - Completed") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, configurations: config)
    let game = Game(name: "Rummy", playerNames: ["Dave", "Eve"])
    game.players[0].addPoints(500, round: 1)
    game.players[1].addPoints(350, round: 1)
    game.isActive = false
    game.currentRound = 5
    container.mainContext.insert(game)
    return List {
        GameRowView(game: game)
    }.modelContainer(container)
}
