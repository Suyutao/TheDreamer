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

    #if os(iOS)
    @MainActor
    func testIPadTimetableManagementUsesThreeColumns() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-useInMemoryStore", "-hasCompletedOnboarding", "YES"]
        app.launch()
        XCUIDevice.shared.orientation = .landscapeLeft

        let scheduleTab = app.descendants(matching: .any)["课程表"].firstMatch
        XCTAssertTrue(scheduleTab.waitForExistence(timeout: 5))
        scheduleTab.tap()

        let managementLink = app.buttons["管理课程与课程表"]
        XCTAssertTrue(managementLink.waitForExistence(timeout: 5))
        managementLink.tap()

        let sidebarTitle = app.descendants(matching: .any)["课程管理"].firstMatch
        let contentTitle = app.descendants(matching: .any)["课程库"].firstMatch
        let detailTitle = app.descendants(matching: .any)["选择要编辑的内容"].firstMatch

        XCTAssertTrue(sidebarTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(contentTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 5))
        XCTAssertLessThan(sidebarTitle.frame.midX, contentTitle.frame.midX)
        XCTAssertLessThan(contentTitle.frame.midX, detailTitle.frame.midX)

        let createTimetable = app.buttons["新建课程表"].firstMatch
        XCTAssertTrue(createTimetable.exists)
        createTimetable.tap()

        XCTAssertTrue(app.navigationBars["新建课程表"].waitForExistence(timeout: 5))
        let timetableName = "iPad 多窗口测试"
        let nameField = app.textFields["课程表名称"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText(timetableName)

        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        let timetable = app.descendants(matching: .any)[timetableName].firstMatch
        XCTAssertTrue(timetable.waitForExistence(timeout: 5))
        timetable.tap()

        let openWindow = app.buttons["在新窗口中打开"]
        XCTAssertTrue(openWindow.waitForExistence(timeout: 5))
        let initialWindowCount = app.windows.count
        openWindow.tap()

        XCTAssertTrue(app.windows.element(boundBy: initialWindowCount).waitForExistence(timeout: 5))
        XCTAssertGreaterThan(app.windows.count, initialWindowCount)
    }
    #endif

    #if os(macOS)
    @MainActor
    func testMacTimetableManagementOpensIndependentWindow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-useInMemoryStore", "-hasCompletedOnboarding", "YES"]
        app.launch()

        let scheduleDestination = app.descendants(matching: .any)["课程表"].firstMatch
        XCTAssertTrue(scheduleDestination.waitForExistence(timeout: 5))
        scheduleDestination.tap()

        let managementLink = app.buttons["管理课程与课程表"]
        XCTAssertTrue(managementLink.waitForExistence(timeout: 5))
        managementLink.tap()

        XCTAssertTrue(app.descendants(matching: .any)["课程管理"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["课程库"].firstMatch.exists)
        XCTAssertTrue(app.descendants(matching: .any)["选择要编辑的内容"].firstMatch.exists)

        let timetableName = "Mac 多窗口测试"
        let timetable = app.descendants(matching: .any)[timetableName].firstMatch
        if !timetable.exists {
            let createTimetable = app.descendants(matching: .any)["新建课程表"].firstMatch
            XCTAssertTrue(createTimetable.exists)
            createTimetable.tap()

            let nameField = app.textFields["课程表名称"]
            XCTAssertTrue(nameField.waitForExistence(timeout: 5))
            nameField.click()
            nameField.typeText(timetableName)
            app.buttons["保存"].click()
        }

        XCTAssertTrue(timetable.waitForExistence(timeout: 5))
        timetable.click()

        let openWindow = app.buttons["在新窗口中打开"]
        XCTAssertTrue(openWindow.waitForExistence(timeout: 5))
        openWindow.click()

        XCTAssertTrue(app.windows.element(boundBy: 1).waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(app.windows.count, 2)
    }
    #endif

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
