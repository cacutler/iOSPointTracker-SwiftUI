//  RoundHistoryView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
struct RoundHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let game: Game
    var allRounds: [Int] {
        Array(1...game.currentRound).reversed()
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(allRounds, id: \.self) {round in
                    Section("Round \(round)") {
                        ForEach(game.players) {player in
                            let scores = player.scoresForRound(round)
                            let total = player.totalForRound(round)
                            if !scores.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name).font(.headline)
                                    HStack {
                                        Text(scores.map { "\($0 > 0 ? "+" : "")\($0)" }.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary)
                                        Spacer()
                                        Text("Total: \(total > 0 ? "+" : "")\(total)").font(.caption).fontWeight(.semibold).foregroundStyle(total >= 0 ? .blue : .red)
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationTitle("Round History").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview("Round History View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, ScoreEntry.self, configurations: config)
    let game = Game(name: "Spades", playerNames: ["Alice", "Bob", "Charlie"])
    game.players[0].addPoints(50, round: 1)// Round 1
    game.players[1].addPoints(25, round: 1)
    game.players[2].addPoints(75, round: 1)
    game.players[0].addPoints(-20, round: 2)// Round 2
    game.players[0].addPoints(30, round: 2)
    game.players[1].addPoints(40, round: 2)
    game.players[2].addPoints(15, round: 2)
    game.players[0].addPoints(100, round: 3)// Round 3
    game.players[1].addPoints(-50, round: 3)
    game.players[2].addPoints(60, round: 3)
    game.currentRound = 3
    container.mainContext.insert(game)
    return RoundHistoryView(game: game).modelContainer(container)
}
