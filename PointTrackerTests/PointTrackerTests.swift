//  PointTrackerTests.swift
//  PointTrackerTests
//  Created by Cameron Alexander Cutler on 1/21/26.
import Testing
import SwiftData
@testable import PointTracker
@MainActor
struct PlayerTests {
    @Test("Player intializes with correct defaults")
    func testPlayerInitialization() {
        let player = Player(name: "Alice")
        let game = Game(name: "Poker", playerNames: ["Alice", "Bob", "Charlie"])
        #expect(player.name == "Alice")
        #expect(player.score == 0)
        #expect(player.scoreHistory.isEmpty)
        #expect(game.winCondition == .highScore)
    }
    @Test("Player adds points correctly")
    func testAddPoints() {
        let player = Player(name: "Bob")
        player.addPoints(50, round: 1)
        #expect(player.score == 50)
        #expect(player.scoreHistory.count == 1)
        #expect(player.scoreHistory[0].points == 50)
        #expect(player.scoreHistory[0].round == 1)
    }
    @Test("Player handles negative points")
    func testNegativePoints() {
        let player = Player(name: "Charlie")
        player.addPoints(100, round: 1)
        player.addPoints(-25, round: 2)
        #expect(player.score == 75)
        #expect(player.scoreHistory.count == 2)
    }
    @Test("Player accumulates multiple scores")
    func testMultipleScores() {
        let player = Player(name: "Diana")
        player.addPoints(10, round: 1)
        player.addPoints(20, round: 1)
        player.addPoints(30, round: 2)
        #expect(player.score == 60)
        #expect(player.scoreHistory.count == 3)
    }
    @Test("Undo last score removes entry and adjusts total")
    func testUndoLastScore() {
        let player = Player(name: "Eve")
        player.addPoints(50, round: 1)
        player.addPoints(25, round: 1)
        player.undoLastScore()
        #expect(player.score == 50)
        #expect(player.scoreHistory.count == 1)
    }
    @Test("Undo on empty history does nothing")
    func testUndoEmptyHistory() {
        let player = Player(name: "Frank")
        player.undoLastScore()
        #expect(player.score == 0)
        #expect(player.scoreHistory.isEmpty)
    }
    @Test("Scores for round returns correct entries")
    func testScoresForRound() {
        let player = Player(name: "Grace")
        player.addPoints(10, round: 1)
        player.addPoints(20, round: 1)
        player.addPoints(30, round: 2)
        player.addPoints(40, round: 2)
        let round1Scores = player.scoresForRound(1)
        let round2Scores = player.scoresForRound(2)
        #expect(round1Scores == [10, 20])
        #expect(round2Scores == [30, 40])
    }
    @Test("Total for round calculates correctly")
    func testTotalForRound() {
        let player = Player(name: "Henry")
        player.addPoints(10, round: 1)
        player.addPoints(15, round: 1)
        player.addPoints(-5, round: 1)
        let total = player.totalForRound(1)
        #expect(total == 20)
    }
    @Test("Total for nonexistent round returns zero")
    func testTotalForNonexistentRound() {
        let player = Player(name: "Ivy")
        player.addPoints(50, round: 1)
        let total = player.totalForRound(5)
        #expect(total == 0)
    }
}
@MainActor
struct GameTests {
    @Test("Game initializes with correct defaults")
    func testGameInitialization() {
        let game = Game(name: "Poker", playerNames: ["Alice", "Bob", "Charlie"])
        #expect(game.name == "Poker")
        #expect(game.isActive == true)
        #expect(game.currentRound == 1)
        #expect(game.players.count == 3)
        #expect(game.players[0].name == "Alice")
        #expect(game.players[1].name == "Bob")
        #expect(game.players[2].name == "Charlie")
        #expect(game.rounds.isEmpty)
    }
    @Test("Game advances to next round")
    func testNextRound() {
        let game = Game(name: "Hearts", playerNames: ["Dave", "Eve"])
        game.nextRound()
        #expect(game.currentRound == 2)
        game.nextRound()
        game.nextRound()
        #expect(game.currentRound == 4)
    }
    @Test("Winner is determined correctly")
    func testWinner() {
        let game = Game(name: "Spades", playerNames: ["Alice", "Bob", "Charlie"])
        game.players[0].addPoints(100, round: 1)
        game.players[1].addPoints(150, round: 1)
        game.players[2].addPoints(75, round: 1)
        let winner = game.winner
        #expect(winner?.name == "Bob")
        #expect(winner?.score == 150)
    }
    @Test("Winner handles tied scores")
    func testWinnerWithTie() {
        let game = Game(name: "Rummy", playerNames: ["Player1", "Player2", "Player3"])
        game.players[0].addPoints(100, round: 1)
        game.players[1].addPoints(100, round: 1)
        game.players[2].addPoints(50, round: 1)
        let winner = game.winner
        #expect(winner?.score == 100)// Either Player1 or Player2 should win (both have 100)
    }
    @Test("Winner with negative scores")
    func testWinnerWithNegativeScores() {
        let game = Game(name: "Hearts", playerNames: ["Alice", "Bob"])
        game.players[0].addPoints(-50, round: 1)
        game.players[1].addPoints(-25, round: 1)
        let winner = game.winner
        #expect(winner?.name == "Bob")
        #expect(winner?.score == -25)
    }
    @Test("Winner is nil when no players")
    func testWinnerNoPlayers() {
        let game = Game(name: "Empty", playerNames: [])
        let winner = game.winner
        #expect(winner == nil)
    }
    @Test("Winner wit low score win condition")
    func testWinnerLowScore() {
        let game = Game(name: "Golf", playerNames: ["Alice", "Bob", "Charlie"], winCondition: .lowScore)
        game.players[0].addPoints(100, round: 1)
        game.players[1].addPoints(50, round: 1)
        game.players[2].addPoints(75, round: 1)
        let winner = game.winner
        #expect(winner?.name == "Bob")
        #expect(winner?.score == 50)
    }
    @Test("Winner with low score and negative scores")
    func testWinnerLowScoreNegative() {
        let game = Game(name: "Golf", playerNames: ["Alice", "Bob"], winCondition: .lowScore)
        game.players[0].addPoints(-50, round: 1)
        game.players[1].addPoints(-25, round: 1)
        let winner = game.winner
        #expect(winner?.name == "Alice")
        #expect(winner?.score == -50)
    }
    @Test("Game initializes with low score win condition")
    func testLowScoreWinConditionInit() {
        let game = Game(name: "Poker", playerNames: ["Alice", "Bob"])
        #expect(game.winCondition == .highScore)
    }
    @Test("Game defaults to high score win condition")
    func testDafaultWinCondition() {
        let game = Game(name: "Golf", playerNames: ["Alice", "Bob"], winCondition: .lowScore)
        #expect(game.winCondition == .lowScore)
    }
    @Test("Winner handles tied scores with low score condition")
    func testWinnerTiedLowScore() {
        let game = Game(name: "Golf", playerNames: ["Player1", "Player2", "Player3"], winCondition: .lowScore)
        game.players[0].addPoints(50, round: 1)
        game.players[1].addPoints(50, round: 1)
        game.players[2].addPoints(100, round: 1)
        let winner = game.winner
        #expect(winner?.score == 50)
    }
}
@MainActor
struct ScoreEntryTests {
    @Test("ScoreEntry initializes correctly")
    func testScoreEntryInitialization() {
        let entry = ScoreEntry(points: 50, round: 3)
        #expect(entry.points == 50)
        #expect(entry.round == 3)
    }
    @Test("ScoreEntry handles negative points")
    func testNegativeScoreEntry() {
        let entry = ScoreEntry(points: -25, round: 1)
        #expect(entry.points == -25)
        #expect(entry.round == 1)
    }
}
@MainActor
struct RoundTests {
    @Test("Round initializes with correct number")
    func testRoundInitialization() {
        let round = Round(number: 5)
        #expect(round.number == 5)
    }
}
@MainActor
struct IntegrationTests {
    @Test("Complete game flow")
    func testCompleteGameFlow() {
        let game = Game(name: "Test Game", playerNames: ["Alice", "Bob"])// Create a new game
        #expect(game.isActive == true)
        #expect(game.currentRound == 1)
        game.players[0].addPoints(50, round: 1)// Round 1
        game.players[1].addPoints(25, round: 1)
        #expect(game.players[0].score == 50)
        #expect(game.players[1].score == 25)
        game.nextRound()// Advance to round 2
        #expect(game.currentRound == 2)
        game.players[0].addPoints(30, round: 2)// Round 2
        game.players[1].addPoints(60, round: 2)
        #expect(game.players[0].score == 80)
        #expect(game.players[1].score == 85)
        game.isActive = false// End game
        let winner = game.winner// Check winner
        #expect(winner?.name == "Bob")
        #expect(winner?.score == 85)
    }
    @Test("Multiple rounds with undo")
    func testMultipleRoundsWithUndo() {
        let game = Game(name: "Undo Test", playerNames: ["Player1"])
        let player = game.players[0]
        player.addPoints(10, round: 1)
        player.addPoints(20, round: 1)
        player.addPoints(30, round: 2)
        #expect(player.score == 60)
        player.undoLastScore()
        #expect(player.score == 30)
        #expect(player.totalForRound(1) == 30)
        #expect(player.totalForRound(2) == 0)
    }
    @Test("Complete game flow with low score win condition")
    func testCompleteGameFlowLowScore() {
        let game = Game(name: "Golf", playerNames: ["Alice", "Bob"], winCondition: .lowScore)
        #expect(game.isActive == true)
        game.players[0].addPoints(80, round: 1)
        game.players[1].addPoints(60, round: 1)
        game.nextRound()
        game.players[0].addPoints(70, round: 2)
        game.players[1].addPoints(90, round: 2)
        game.isActive = false
        let winner = game.winner
        #expect(winner?.name == "Alice")  // 150 total vs Bob's 150... adjust values as needed
        #expect(winner?.score == 150)
    }
}
