//  PointTrackerUITests.swift
//  PointTrackerUITests
//  Created by Cameron Alexander Cutler on 1/21/26.
import XCTest
final class PointTrackerUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    override func tearDownWithError() throws {
        app = nil
    }
    @MainActor// MARK: - New Game Tests
    func testCreateNewGame() throws {
        app.navigationBars["Card Games"].buttons["New Game"].tap()// Tap the + button
        let gameNameField = app.textFields["Game Name"]// Enter game name
        gameNameField.tap()
        gameNameField.typeText("Poker Night")
        let player1Field = app.textFields["Player 1"]// Enter player names
        player1Field.tap()
        player1Field.typeText("Alice")
        let player2Field = app.textFields["Player 2"]
        player2Field.tap()
        player2Field.typeText("Bob")
        app.navigationBars["New Game"].buttons["Start"].tap()// Tap Start button
        XCTAssertTrue(app.staticTexts["Poker Night"].exists)// Verify game was created
    }
    @MainActor
    func testCreateGameWithMultiplePlayers() throws {
        app.navigationBars["Card Games"].buttons["New Game"].tap()
        app.textFields["Game Name"].tap()// Enter game name
        app.textFields["Game Name"].typeText("Hearts")
        app.textFields["Player 1"].tap()// Add initial players
        app.textFields["Player 1"].typeText("Alice")
        app.textFields["Player 2"].tap()
        app.textFields["Player 2"].typeText("Bob")
        app.buttons["Add Player"].tap()// Add a third player
        app.textFields["Player 3"].tap()
        app.textFields["Player 3"].typeText("Charlie")
        app.buttons["Add Player"].tap()// Add a fourth player
        app.textFields["Player 4"].tap()
        app.textFields["Player 4"].typeText("Diana")
        app.navigationBars["New Game"].buttons["Start"].tap()
        XCTAssertTrue(app.staticTexts["Hearts"].exists)// Verify game exists
    }
    @MainActor
    func testCannotCreateGameWithoutName() throws {
        app.navigationBars["Card Games"].buttons["New Game"].tap()
        app.textFields["Player 1"].tap()// Enter only player names, no game name
        app.textFields["Player 1"].typeText("Alice")
        app.textFields["Player 2"].tap()
        app.textFields["Player 2"].typeText("Bob")
        let startButton = app.navigationBars["New Game"].buttons["Start"]// Start button should be disabled
        XCTAssertFalse(startButton.isEnabled)
    }
    @MainActor
    func testCannotCreateGameWithOnePlayer() throws {
        app.navigationBars["Card Games"].buttons["New Game"].tap()
        app.textFields["Game Name"].tap()
        app.textFields["Game Name"].typeText("Solo Game")
        app.textFields["Player 1"].tap()
        app.textFields["Player 1"].typeText("Alice")
        let startButton = app.navigationBars["New Game"].buttons["Start"]// Don't fill in Player 2; start button should be disabled
        XCTAssertFalse(startButton.isEnabled)
    }
    @MainActor
    func testCancelNewGame() throws {
        app.navigationBars["Card Games"].buttons["New Game"].tap()
        app.textFields["Game Name"].tap()
        app.textFields["Game Name"].typeText("Test Game")
        app.navigationBars["New Game"].buttons["Cancel"].tap()// Tap Cancel
        XCTAssertTrue(app.navigationBars["Card Games"].exists)// Should be back at main screen
        XCTAssertFalse(app.staticTexts["Test Game"].exists)
    }
    @MainActor// MARK: - Score Entry Tests
    func testAddPositiveScore() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()// Tap on game to open it
        app.staticTexts["Alice"].tap()// Tap on Alice to add score
        app.textFields["Points"].tap()// Enter points
        app.textFields["Points"].typeText("50")
        app.navigationBars["Add Points"].buttons["Add"].tap()// Tap Add button
        XCTAssertTrue(app.staticTexts["50"].exists)// Verify score was added
    }
    @MainActor
    func testAddNegativeScore() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.staticTexts["Alice"].tap()
        app.buttons["Subtract Points"].tap()// Switch to subtract points
        app.textFields["Points"].tap()// Enter points
        app.textFields["Points"].typeText("25")
        app.navigationBars["Add Points"].buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["-25"].exists)// Verify negative score (look for red text or -25)
    }
    @MainActor
    func testQuickAddButtons() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.staticTexts["Alice"].tap()
        app.buttons["+10"].tap()// Tap the +10 quick add button
        XCTAssertTrue(app.staticTexts["10"].exists)// Should dismiss and show score
    }
    @MainActor
    func testUndoLastScore() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.staticTexts["Alice"].tap()// Add a score to Alice
        app.buttons["+50"].tap()
        app.staticTexts["Alice"].tap()// Add another score
        XCTAssertTrue(app.buttons["Undo Last (+50)"].exists)// Undo button should exist
        app.buttons["Undo Last (+50)"].tap()
        XCTAssertTrue(app.staticTexts["0"].exists)// Score should be 0 again
    }
    @MainActor// MARK: - Game Flow Tests
    func testNextRound() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        XCTAssertTrue(app.staticTexts["Round 1"].exists)
        app.buttons["Next Round"].firstMatch.tap()// Tap the Next Round button on the screen (not in the alert)
        app.alerts["Start Next Round?"].buttons["Next Round"].tap()// Now tap the Next Round button in the confirmation alert
        XCTAssertTrue(app.staticTexts["Round 2"].exists)
    }
    @MainActor
    func testEndGame() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.buttons["OverflowBarButtonItem"].tap()// Open the More menu
        app.buttons["More"].firstMatch.tap()// The menu appears as a collapsed banner at the top; Tap on the "More" text/button to expand it
        app.buttons["End Game"].tap()// Now tap End Game
        XCTAssertFalse(app.buttons["Next Round"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Completed Games"].exists)
    }
    @MainActor
    func testResetGame() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.staticTexts["Alice"].tap()
        app.buttons["+50"].tap()
        app.staticTexts["Bob"].tap()
        app.buttons["+25"].tap()
        app.buttons["OverflowBarButtonItem"].tap()// Open the More menu
        app.buttons["More"].firstMatch.tap()// Tap the More banner to expand it
        app.buttons["Reset Game"].tap()// Tap Reset Game
        app.buttons["Reset"].tap()// Confirm the reset
        XCTAssertTrue(app.staticTexts["Round 1"].exists)
        let scoreLabels = app.staticTexts.matching(identifier: "0")
        XCTAssertTrue(scoreLabels.count >= 2)
    }
    @MainActor// MARK: - Round History Tests
    func testViewRoundHistory() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.staticTexts["Alice"].tap()
        app.buttons["+50"].tap()
        app.buttons["Next Round"].firstMatch.tap()// Use firstMatch to get the first Next Round button (on the screen)
        app.alerts["Start Next Round?"].buttons["Next Round"].tap()// Tap the confirmation button in the alert
        app.staticTexts["Alice"].tap()
        app.buttons["+25"].tap()
        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["Round 2"].exists)
        XCTAssertTrue(app.staticTexts["Round 1"].exists)
        app.buttons["Done"].tap()
    }
    @MainActor// MARK: - Player Management Tests
    func testAddPlayerDuringGame() throws {
        createTestGame()
        app.staticTexts["Test Game"].tap()
        app.buttons["OverflowBarButtonItem"].tap()// Open the More menu
        app.buttons["More"].firstMatch.tap()// Tap the More banner to expand it
        app.buttons["Add Player"].tap()// Tap Add Player
        app.textFields["Player Name"].tap()
        app.textFields["Player Name"].typeText("Charlie")
        app.alerts["Add New Player"].buttons["Add"].tap()// Tap the Add button specifically in the alert
        XCTAssertTrue(app.staticTexts["Charlie"].exists)
    }
    @MainActor
    func testDeleteGame() throws {
        createTestGame()
        let gameCell = app.staticTexts["Test Game"]// Swipe to delete
        gameCell.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["Test Game"].exists)// Game should no longer exist
    }
    private func createTestGame() {// MARK: - Helper Methods
        app.navigationBars["Card Games"].buttons["New Game"].tap()
        app.textFields["Game Name"].tap()
        app.textFields["Game Name"].typeText("Test Game")
        app.textFields["Player 1"].tap()
        app.textFields["Player 1"].typeText("Alice")
        app.textFields["Player 2"].tap()
        app.textFields["Player 2"].typeText("Bob")
        app.navigationBars["New Game"].buttons["Start"].tap()
    }
}
