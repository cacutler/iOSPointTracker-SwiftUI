//  PointTrackerUITestsLaunchTests.swift
//  PointTrackerUITests
//  Created by Cameron Alexander Cutler on 1/21/26.
import XCTest
final class PointTrackerUITestsLaunchTests: XCTestCase {// MARK: - Launch Tests
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Card Games"].exists)// Verify app launched successfully
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
