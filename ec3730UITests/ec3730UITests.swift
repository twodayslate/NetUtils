//
//  ec3730UITests.swift
//  ec3730UITests
//
//  Created by Zachary Gorak on 8/22/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import XCTest

class EC3730UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSnapshots() {
        openVC("Host")
        app.buttons["Lookup"].tap()
        sleep(1)
        snapshot("Host")

        openVC("Device")
        snapshot("Device")

        openVC("Ping")
        app.buttons["ping"].tap()
        sleep(1)
        snapshot("Ping")

        openVC("Connectivity")
        snapshot("Connectivity")

        openVC("View Source")
        sleep(2)
        snapshot("ViewSource")
    }

    private func openVC(_ key: String) {
        // First we try the tab bar
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        let hostButton = elementsQuery.buttons[key]

        if hostButton.exists, hostButton.isHittable {
            hostButton.tap()
            return
        }

        // Then we try the more tab
        app.scrollViews.otherElements.buttons["More"].tap()

        let tablesQuery = app.tables
        let button = tablesQuery.buttons[key]
        if button.exists, button.isHittable {
            button.tap()
            return
        }

        // lastly we try the sidebar
        let sidebarButton = app.tables.buttons[key]
        XCTAssert(sidebarButton.exists)
        sidebarButton.tap()
    }
}

extension XCUIElement {
    /// https://stackoverflow.com/questions/32646539/scroll-until-element-is-visible-ios-ui-automation-with-xcode7
    func isVisible() -> Bool {
        if !exists || !isHittable || frame.isEmpty {
            return false
        }

        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}

extension XCTestCase {
    /// https://stackoverflow.com/questions/32646539/scroll-until-element-is-visible-ios-ui-automation-with-xcode7
    func scrollToElement(_ element: XCUIElement) {
        while !element.isVisible() {
            let app = XCUIApplication()
            let startCoord = app.tables.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -262))
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }
}
