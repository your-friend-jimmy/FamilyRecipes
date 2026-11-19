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

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        return app
    }

    @MainActor
    func testReturnAddsAnotherIngredientAndStep() {
        let app = makeApp()
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
        let app = makeApp()
        app.launch()

        app.navigationBars["Recipes"].buttons["Add Recipe"].tap()
        let uniqueID = UUID().uuidString
        let title = "Searchable Shoyu " + uniqueID
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText(title)
        app.navigationBars["New Recipe"].buttons["Save"].tap()

        app.collectionViews.firstMatch.swipeDown()
        let searchField = app.searchFields["Search recipes"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("sEaRcHaBlE sHoYu " + uniqueID.lowercased())
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 2))

        searchField.buttons["Clear text"].tap()
        searchField.typeText("No match " + UUID().uuidString)
        let noResults = app.descendants(matching: .any)["recipe-search-no-results"]
        XCTAssertTrue(noResults.waitForExistence(timeout: 2))

        searchField.buttons["Clear text"].tap()
        XCTAssertTrue(noResults.waitForNonExistence(timeout: 2))
    }

    @MainActor
    func testRecipeDeletionRequiresConfirmation() {
        let app = makeApp()
        app.launch()

        app.navigationBars["Recipes"].buttons["Add Recipe"].tap()
        let title = "Delete Me " + UUID().uuidString
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText(title)
        app.navigationBars["New Recipe"].buttons["Save"].tap()
        app.staticTexts[title].tap()

        app.navigationBars[title].buttons["More"].tap()
        app.buttons["Delete Recipe"].tap()
        XCTAssertTrue(app.alerts["Delete Recipe?"].waitForExistence(timeout: 2))
        app.alerts["Delete Recipe?"].buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars[title].exists)
        app.navigationBars[title].buttons["Recipes"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 2))
        app.staticTexts[title].tap()

        app.navigationBars[title].buttons["More"].tap()
        app.buttons["Delete Recipe"].tap()
        app.alerts["Delete Recipe?"].buttons["Delete Recipe"].tap()

        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts[title].exists)
    }

    @MainActor
    func testCollectionNameMustContainNonWhitespaceTextAndIsTrimmed() {
        let app = makeApp()
        app.launch()

        app.tabBars.buttons["Collections"].tap()
        app.navigationBars["Collections"].buttons["Create Collection"].tap()

        let nameField = app.textFields["Collection Name"]
        let saveButton = app.navigationBars["New Collection"].buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled)

        nameField.tap()
        nameField.typeText("   ")
        XCTAssertFalse(saveButton.isEnabled)

        let name = "Family Favorites " + UUID().uuidString
        nameField.typeText(name + "  ")
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["   " + name + "  "].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            makeApp().launch()
        }
    }
}
