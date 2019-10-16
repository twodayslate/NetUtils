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

        app.toolbars["Toolbar"].buttons["Lookup"].tap()

        waitForElementToAppear(element: app.tables.cells.firstMatch)
        snapshot("Host")
        scrollToElement(app.tables.staticTexts["DNS"])
        app.swipeUp()
        app.swipeUp()
        snapshot("DNS")

        openVC("Connectivity")
        snapshot("Connectivity")
        app.tables.cells.containing(.staticText, identifier: "en0").firstMatch.staticTexts["en0"].tap()
        snapshot("Interface")

        openVC("Ping")
        app.toolbars["Toolbar"].buttons["ping"].tap()

        //swiftlint:disable line_length
        waitForElementToAppear(element:
            app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element)
        // swiftlint:enable vertical_whitespace line_length
        snapshot("Ping")

        openVC("View Source")
        app.toolbars["Toolbar"].buttons["View Source"].tap()
        snapshot("View Source")
    }

    private func openVC(_ key: String) {
        let tabBarsQuery = app.tabBars

        if tabBarsQuery.buttons[key].exists {
            tabBarsQuery.buttons[key].tap()
        } else if tabBarsQuery.buttons["More"].exists {
            tabBarsQuery.buttons["More"].tap()

            if app.staticTexts[key].exists {
                app.staticTexts[key].tap()
            } else {
                XCTAssert(false, "Unable to find '\(key)' View Controller (even inside the 'More' controller)")
            }
        } else {
            XCTAssert(false, "Unable to find '\(key)' View Controller")
        }
    }

    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")

        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if error != nil {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
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
