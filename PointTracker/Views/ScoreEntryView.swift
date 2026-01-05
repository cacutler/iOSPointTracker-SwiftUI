//  ScoreEntryView.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
struct ScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    let currentRound: Int
    @State private var points = ""
    @State private var isNegative = false
    @FocusState private var isFocused: Bool
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(player.name).font(.headline)
                Text("Round \(currentRound)").font(.subheadline).foregroundStyle(.secondary)
                HStack {
                    Button {
                        isNegative.toggle()
                    } label: {
                        Image(systemName: isNegative ? "minus.circle.fill" : "plus.circle.fill").font(.title).foregroundStyle(isNegative ? .red : .blue)
                    }
                    TextField("Points", text: $points).textFieldStyle(.roundedBorder).keyboardType(.numberPad).font(.system(size: 48, weight: .bold)).multilineTextAlignment(.center).focused($isFocused)
                }.padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Quick Add").font(.caption).foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        ForEach([1, 5, 10, 25, 50], id: \.self) {value in
                            Button("\(isNegative ? "-" : "+")\(value)") {
                                addQuickPoints(isNegative ? -value : value)
                            }.buttonStyle(.bordered).tint(isNegative ? .red : .blue)
                        }
                    }
                }
                if !player.scoreHistory.isEmpty {
                    Divider().padding(.vertical)
                    Button(role: .destructive) {
                        player.undoLastScore()
                        dismiss()
                    } label: {
                        let lastEntry = player.scoreHistory.last!
                        Label("Undo Last (\(lastEntry.points > 0 ? "+" : "")\(lastEntry.points))", systemImage: "arrow.uturn.backward")
                    }.buttonStyle(.bordered)
                }
                Spacer()
            }.padding().navigationTitle("Add Points").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addPoints()
                    }.disabled(points.isEmpty)
                }
            }.onAppear {
                isFocused = true
            }
        }
    }
    private func addQuickPoints(_ value: Int) {
        player.addPoints(value, round: currentRound)
        dismiss()
    }
    private func addPoints() {
        guard let value = Int(points) else {return}
        let finalValue = isNegative ? -value : value
        player.addPoints(finalValue, round: currentRound)
        dismiss()
    }
}
#Preview("Score Entry View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Player.self, ScoreEntry.self, configurations: config)
    let player = Player(name: "Alice")
    player.addPoints(25, round: 1)
    player.addPoints(15, round: 2)
    container.mainContext.insert(player)
    return ScoreEntryView(player: player, currentRound: 2).modelContainer(container)
}
