//
//  FamilyRecipesUITests.swift
//  FamilyRecipesUITests
//
//  Created by James Phillips on 11/17/26.
//

import XCTest

final class FamilyRecipesUITests: XCTestCase {

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
    func testReturnAddsAnotherIngredientAndStep() {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars["Recipes"].buttons["Add Recipe"].tap()
        let title = "Multiline Recipe " + UUID().uuidString
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText(title)

        let ingredients = app.textViews["Ingredients"]
        ingredients.tap()
        ingredients.typeText("Garlic, minced\nShoyu")

        let steps = app.textViews["Steps"]
        if !steps.isHittable {
            app.swipeUp()
        }
        steps.tap()
        steps.typeText("Mix the sauce.\nSimmer the chicken.")

        app.navigationBars["New Recipe"].buttons["Save"].tap()
        app.staticTexts[title].tap()

        XCTAssertTrue(app.staticTexts["Garlic, minced"].exists)
        XCTAssertTrue(app.staticTexts["Shoyu"].exists)
        XCTAssertTrue(app.staticTexts["1. Mix the sauce."].exists)
        XCTAssertTrue(app.staticTexts["2. Simmer the chicken."].exists)
    }

    @MainActor
    func testRecipeTitleSearchFiltersAndShowsNoResults() {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars["Recipes"].buttons["Add Recipe"].tap()
        let title = "Searchable Shoyu " + UUID().uuidString
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText(title)
        app.navigationBars["New Recipe"].buttons["Save"].tap()

        app.collectionViews.firstMatch.swipeDown()
        let searchField = app.searchFields["Search recipes"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("sEaRcHaBlE")
        XCTAssertTrue(app.staticTexts[title].exists)

        searchField.buttons["Clear text"].tap()
        searchField.typeText("No match " + UUID().uuidString)
        let noResults = app.descendants(matching: .any)["recipe-search-no-results"]
        XCTAssertTrue(noResults.waitForExistence(timeout: 2))

        searchField.buttons["Clear text"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
