//
//  XCUITestExampleUITests.swift
//  XCUITestExampleUITests
//
//  Created by Jason Dobo on 17/03/2017.
//  Copyright © 2017 JasonDobo. All rights reserved.
//

import XCTest

class XCUITestExampleUITests: XCTestCase {
    
    enum ElementState: String {
        case enabled = "enabled == true"
        case notenabled = "enabled == false"
        case exists = "exists == true"
        case notexists = "exists == false"
        case hittable = "hittable == true"
        case nothittable = "hittable == false"
    }
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNavigate() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars

        tabBarsQuery.buttons["Second"].tap()
        tabBarsQuery.buttons["First"].tap()
    }
    
    func testWaitForElements() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars

        waitToExist(for: tabBarsQuery.buttons["First"])
        waitToExist(for: tabBarsQuery.buttons["Second"])
    }
    
    func testStaticText() {
        let app = XCUIApplication()
        let element = app.staticTexts["First View"]
        
        XCTAssertTrue(element.label == "First View", "This label displayed corectley")
    }
    
    func testNavigateToSecondTab() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let element = tabBarsQuery.buttons["Second"]
        
        waitFor(element: element, withState: .enabled)
        element.tap()
        
        waitFor(element: tabBarsQuery.buttons["Second"], withState: .exists)
    }
    
    fileprivate func waitToExist(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func waitToNotExist(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        let exists = NSPredicate(format: "exists == false")
        
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func waitToBeEnabled(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        waitToExist(for: element, waiting: timeout)
        
        let exists = NSPredicate(format: "enabled == true")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func waitToNotBeEnabled(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        let exists = NSPredicate(format: "enabled == false")
        
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func waitToBeHittable(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        waitToExist(for: element, waiting: timeout)
        
        let exists = NSPredicate(format: "hittable == true")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func waitToNotBeHittable(for element: XCUIElement, waiting timeout: TimeInterval = 30.0) {
        let exists = NSPredicate(format: "hittable == false")
        
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    fileprivate func runApp(for seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }
    
    fileprivate func tryWaitFor(element: XCUIElement, withState state: ElementState, waiting timeout: TimeInterval = 30.0) -> Bool {
        let exists = NSPredicate(format: state.rawValue)
        
        let testcase = XCTestCase()
        var result = true
        testcase.expectation(for: exists, evaluatedWith: element, handler: nil)
        testcase.waitForExpectations(timeout: timeout) { error in
            result = error == nil
        }
        return result
    }
    
    fileprivate func waitFor(element: XCUIElement, withState state: ElementState, waiting timeout: TimeInterval = 30.0) {
        XCTAssertTrue(tryWaitFor(element: element, withState: state, waiting: timeout), "Wait for \(element.description) \(state.rawValue) failed with timout \(timeout)s")
    }
    
    
    fileprivate func waitForElementAndTap(_ element: XCUIElement, timeout: TimeInterval = 30.0) {
        waitToExist(for: element, waiting: timeout)
        waitToBeHittable(for: element, waiting: timeout)
        runApp(for: 0.5)
        element.tap()
    }
    
    fileprivate func waitForElementAndForceTap(_ element: XCUIElement, timeout: TimeInterval = 30.0) {
        waitToExist(for: element, waiting: timeout)
        waitToBeEnabled(for: element, waiting: timeout)
        runApp(for: 0.5)
        element.forceTapElement()
    }
    
    fileprivate func advanceOneValue(pickerWheel: XCUIElement) {
        let screenHeight = XCUIApplication().windows.element(boundBy: 0).frame.height
        let screenWidth = XCUIApplication().windows.element(boundBy: 0).frame.width
        
        let pickerMidYPoint = pickerWheel.frame.midY
        let pickerMidXPoint = pickerWheel.frame.midX
        
        let scrollMidPoint = CGFloat(pickerMidXPoint/screenWidth)
        let endScrollOffset = CGFloat(pickerMidYPoint/screenHeight)
        let startScrollOffset = CGFloat(((pickerMidYPoint + screenHeight)/2)/screenHeight)
        
        let endScreenPoint = XCUIApplication().windows.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: scrollMidPoint, dy: endScrollOffset))
        let startScreenPoint = XCUIApplication().windows.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: scrollMidPoint, dy: startScrollOffset))
        startScreenPoint.press(forDuration: 0, thenDragTo: endScreenPoint)
        
    }
}

@available(iOS 9.0, *)
extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
    
    func clearAndEnter(text: String) -> Void {
        guard let currentString = self.value as? String else {
            XCTFail("Failed as XCUIElement not text field")
            return
        }
        
        let deleteString = currentString.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        self.typeText(deleteString)
        self.typeText(text)
    }
}
