//  GameView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
struct GameView: View {
    @Bindable var game: Game
        @State private var showingScoreSheet = false
        @State private var selectedPlayer: Player?
        @State private var showingRoundHistory = false
        @State private var showingNextRoundConfirmation = false
        var sortedPlayers: [Player] {
            game.players.sorted { $0.score > $1.score }
        }
        var body: some View {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Round \(game.currentRound)")
                                .font(.headline)
                            if game.isActive {
                                Text("Tap players to add scores").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if game.isActive {
                            Button {
                                showingNextRoundConfirmation = true
                            } label: {
                                Label("Next Round", systemImage: "arrow.right.circle.fill").font(.subheadline)
                            }.buttonStyle(.bordered)
                        }
                    }
                }
                Section {
                    ForEach(sortedPlayers) {player in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.name).font(.headline)
                                HStack(spacing: 4) {
                                    if player == game.winner && !game.isActive {
                                        Text("Winner!").font(.caption).foregroundStyle(.green)
                                    }
                                    if game.isActive {
                                        let roundTotal = player.totalForRound(game.currentRound)
                                        if roundTotal != 0 {
                                            Text("This round: \(roundTotal > 0 ? "+" : "")\(roundTotal)").font(.caption).foregroundStyle(roundTotal > 0 ? .blue : .red)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            Text("\(player.score)").font(.title2).fontWeight(.semibold).foregroundStyle(player.score < 0 ? .red : .blue)
                            if game.isActive {
                                Button {
                                    selectedPlayer = player
                                    showingScoreSheet = true
                                } label: {
                                    Image(systemName: "plus.circle.fill").font(.title3)
                                }
                            }
                        }.contentShape(Rectangle()).onTapGesture {
                            if game.isActive {
                                selectedPlayer = player
                                showingScoreSheet = true
                            }
                        }
                    }
                } header: {
                    Text("Scores")
                }
            }.navigationTitle(game.name).navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingRoundHistory = true
                    } label: {
                        Label("History", systemImage: "clock")
                    }
                }
                if game.isActive {
                    ToolbarItem(placement: .secondaryAction) {
                        Button("End Game") {
                            game.isActive = false
                        }
                    }
                }
            }.sheet(isPresented: $showingScoreSheet) {
                if let player = selectedPlayer {
                    ScoreEntryView(player: player, currentRound: game.currentRound)
                }
            }.sheet(isPresented: $showingRoundHistory) {
                RoundHistoryView(game: game)
            }.alert("Start Next Round?", isPresented: $showingNextRoundConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Next Round") {
                    game.nextRound()
                }
            } message: {
                Text("Round \(game.currentRound) will be complete and Round \(game.currentRound + 1) will begin.")
            }
        }
}
#Preview("Game View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, ScoreEntry.self, configurations: config)
    let game = Game(name: "Hearts", playerNames: ["Alice", "Bob", "Charlie", "Diana"])
    game.players[0].addPoints(25, round: 1)
    game.players[0].addPoints(10, round: 1)
    game.players[1].addPoints(-15, round: 1)
    game.players[2].addPoints(30, round: 1)
    game.players[3].addPoints(5, round: 1)
    game.currentRound = 2
    container.mainContext.insert(game)
    return NavigationStack {
        GameView(game: game)
    }.modelContainer(container)
}
