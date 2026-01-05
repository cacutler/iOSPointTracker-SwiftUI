//  ContentView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftUI
import SwiftData
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Game> { $0.isActive }, sort: \Game.date, order: .reverse)
    private var activeGames: [Game]
    @Query(filter: #Predicate<Game> { !$0.isActive }, sort: \Game.date, order: .reverse)
    private var completedGames: [Game]
    @State private var showingNewGame = false
    var body: some View {
        NavigationStack {
            List {
                if !activeGames.isEmpty {
                    Section("Active Games") {
                        ForEach(activeGames) { game in
                            NavigationLink(destination: GameView(game: game)) {
                                GameRowView(game: game)
                            }
                        }.onDelete(perform: deleteActiveGames)
                    }
                }
                if !completedGames.isEmpty {
                    Section("Completed Games") {
                        ForEach(completedGames) { game in
                            NavigationLink(destination: GameView(game: game)) {
                                GameRowView(game: game)
                            }
                        }.onDelete(perform: deleteCompletedGames)
                    }
                }
                if activeGames.isEmpty && completedGames.isEmpty {
                    ContentUnavailableView("No Games Yet",systemImage: "suit.heart.fill", description: Text("Tap + to start tracking a new game"))
                }
            }.navigationTitle("Card Games").toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewGame = true
                    } label: {
                        Label("New Game", systemImage: "plus")
                    }
                }
            }.sheet(isPresented: $showingNewGame) {
                NewGameView()
            }
        }
    }
    private func deleteActiveGames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activeGames[index])
        }
    }
    private func deleteCompletedGames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedGames[index])
        }
    }
}
#Preview {
    ContentView().modelContainer(for: [Game.self, Player.self, ScoreEntry.self, Round.self], inMemory: true)
}
