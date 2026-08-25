//
//  Expat_AppUITests.swift
//  Expat AppUITests
//
//  Created by Dominik Baki on 09.04.25.
//

import XCTest

final class ExpatAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOnboardingCanAdvanceToSecondPage() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding", "-skipSplash"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Willkommen bei EmigrateIn!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["Seite 1 von 4"].exists)

        app.buttons["Weiter"].tap()

        XCTAssertTrue(app.staticTexts["Infos & Checklisten an einem Ort"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["Seite 2 von 4"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
