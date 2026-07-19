//
//  The_DreamerUITests.swift
//  The DreamerUITests
//
//  Created by 苏宇韬 on 7/23/25.
//

import XCTest

final class The_DreamerUITests: XCTestCase {

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
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testDatabaseEmptyStateIsCentered() throws {
        let app = XCUIApplication()
        app.launch()

        let databaseTab = app.tabBars.buttons["数据库"]
        XCTAssertTrue(databaseTab.waitForExistence(timeout: 5))
        databaseTab.tap()

        let windowCenter = app.windows.firstMatch.frame.midX
        let icon = app.images["书架"]
        let title = app.staticTexts["尚无科目"]
        let message = app.staticTexts["点击右上角的 '+' 按钮来创建你的第一个学习科目"]

        XCTAssertTrue(icon.waitForExistence(timeout: 5))
        XCTAssertEqual(icon.frame.midX, windowCenter, accuracy: 1)
        XCTAssertEqual(title.frame.midX, windowCenter, accuracy: 1)
        XCTAssertEqual(message.frame.midX, windowCenter, accuracy: 1)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
