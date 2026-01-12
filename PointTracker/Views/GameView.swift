//  GameView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var game: Game
    @State private var showingScoreSheet = false
    @State private var selectedPlayer: Player?
    @State private var showingRoundHistory = false
    @State private var showingNextRoundConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    @State private var playerToDelete: Player?
    @State private var showingDeleteConfirmation = false
    var sortedPlayers: [Player] {
        game.players.sorted {$0.score > $1.score}
    }
    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Round \(game.currentRound)").font(.headline)
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
                    }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if game.isActive && game.players.count > 2 {
                            Button(role: .destructive) {
                                playerToDelete = player
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Remove", systemImage: "person.fill.xmark")
                            }
                        }
                    }
                }
            } header: {
                Text("Scores")
            } footer: {
                if game.isActive && game.players.count > 2 {
                    Text("Swipe left on a player to remove them from the game").font(.caption).foregroundStyle(.secondary)
                }
            }
        }.navigationTitle(game.name).navigationBarTitleDisplayMode(.inline).toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingRoundHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    if game.isActive {
                        Button {
                            showingAddPlayer = true
                        } label: {
                            Label("Add Player", systemImage: "person.badge.plus")
                        }
                        Button("End Game") {
                            game.isActive = false
                        }
                    }
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label("Reset Game", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }.sheet(item: $selectedPlayer) {player in
            ScoreEntryView(player: player, currentRound: game.currentRound).modelContainer(for: [Player.self, ScoreEntry.self])
        }.sheet(isPresented: $showingRoundHistory) {
            RoundHistoryView(game: game)
        }.alert("Add New Player", isPresented: $showingAddPlayer) {
            TextField("Player Name", text: $newPlayerName)
            Button("Cancel", role: .cancel) {
                newPlayerName = ""
            }
            Button("Add") {
                addNewPlayer()
            }.disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Enter the name of the new player to add to this game.")
        }.alert("Start Next Round?", isPresented: $showingNextRoundConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Next Round") {
                game.nextRound()
            }
        } message: {
            Text("Round \(game.currentRound) will be complete and Round \(game.currentRound + 1) will begin.")
        }.alert("Reset Game?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetGame()
            }
        } message: {
            Text("This will delete all scores and reset the game to Round 1. This action cannot be undone.")
        }.alert("Remove Player?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                playerToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let player = playerToDelete {
                    removePlayer(player)
                }
            }
        } message: {
            if let player = playerToDelete {
                Text("Remove \(player.name) from this game?  Their score history will be permanently deleted.")
            }
        }
    }
    private func addNewPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {return}
        let newPlayer = Player(name: trimmedName)
        game.players.append(newPlayer)
        newPlayerName = ""
    }
    private func removePlayer(_ player: Player) {// Remove from game's players array
        if let index = game.players.firstIndex(of: player) {
            game.players.remove(at: index)
        }
        modelContext.delete(player)// Delete the player entity from the database
        playerToDelete = nil
    }
    private func resetGame() {// Remove all score entries from all players
        for player in game.players {
            for entry in player.scoreHistory {// Delete all score entries from the database
                modelContext.delete(entry)
            }
            player.scoreHistory.removeAll()
            player.score = 0// Reset the player's score to 0
        }
        game.currentRound = 1// Reset game to round 1 and make it active
        game.isActive = true
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
