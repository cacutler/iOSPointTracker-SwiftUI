//  NewGameView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
struct NewGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var gameName = ""
    @State private var playerNames: [String] = ["", ""]
    @FocusState private var focusedField: Int?
    var body: some View {
        NavigationStack {
            Form {
                Section("Game Details") {
                    TextField("Game Name", text: $gameName)
                }
                Section("Players") {
                    ForEach(playerNames.indices, id: \.self) {index in
                        HStack {
                            TextField("Player \(index + 1)", text: $playerNames[index]).focused($focusedField, equals: index)
                            if playerNames.count > 2 {
                                Button(role: .destructive) {
                                    playerNames.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                            }
                        }
                    }
                    Button {
                        playerNames.append("")
                        focusedField = playerNames.count - 1
                    } label: {
                        Label("Add Player", systemImage: "plus.circle.fill")
                    }
                }
            }.navigationTitle("New Game").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createGame()
                    }.disabled(!isValid)
                }
            }
        }
    }
    private var isValid: Bool {
        !gameName.trimmingCharacters(in: .whitespaces).isEmpty && playerNames.filter {!$0.trimmingCharacters(in: .whitespaces).isEmpty}.count >= 2
    }
    private func createGame() {
        let validNames = playerNames.map {$0.trimmingCharacters(in: .whitespaces)}.filter {!$0.isEmpty}
        let game = Game(name: gameName, playerNames: validNames)
        modelContext.insert(game)
        dismiss()
    }
}
#Preview("New Game View") {
    NewGameView().modelContainer(for: [Game.self, Player.self], inMemory: true)
}
