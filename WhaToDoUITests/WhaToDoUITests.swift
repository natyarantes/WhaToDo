//
//  WhaToDoUITests.swift
//  WhaToDoUITests
//
//  Created by Natália Arantes on 06/08/26.
//

import XCTest

@MainActor
final class WhaToDoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    private func search(for city: String, in app: XCUIApplication) {
        let searchField = app.searchFields.firstMatch
        
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 3)
        )
        
        searchField.tap()
        searchField.typeText(city)
        
        let searchButton = app.keyboards.buttons["Search"]
        
        XCTAssertTrue(
            searchButton.waitForExistence(timeout: 2)
        )
        
        searchButton.tap()
    }

    func testSearchCityAndShowRecommendations() throws {
        let app = XCUIApplication()

        app.launchArguments = [
            "-ui-testing"
        ]

        app.launch()

        let initialMessage = app.staticTexts[
            "Find your next activity"
        ]

        XCTAssertTrue(
            initialMessage.waitForExistence(timeout: 3)
        )

        let searchField = app.searchFields.firstMatch

        XCTAssertTrue(
            searchField.waitForExistence(timeout: 3)
        )

        searchField.tap()
        searchField.typeText("Oslo")

        let searchButton =
            app.keyboards.buttons["Search"]

        XCTAssertTrue(
            searchButton.waitForExistence(timeout: 2)
        )

        searchButton.tap()

        let cityRow = app.buttons["city.row.1"]

        XCTAssertTrue(
            cityRow.waitForExistence(timeout: 3)
        )

        cityRow.tap()

        let navigationBar =
            app.navigationBars["Oslo"]

        XCTAssertTrue(
            navigationBar.waitForExistence(timeout: 3)
        )

        let firstActivityCard = app.descendants(
            matching: .any
        )["activity.card.1"]

        XCTAssertTrue(
            firstActivityCard.waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            firstActivityCard.label.contains("Skiing")
        )
    }
    
    func testSearchWithoutResultsShowsEmptyState() {
        let app = XCUIApplication()

        app.launchArguments = [
            "-ui-testing",
            "-ui-testing-empty"
        ]

        app.launch()

        search(for: "Unknown", in: app)

        let emptyState = app.staticTexts
            .matching(
                NSPredicate(
                    format: "label CONTAINS[c] %@",
                    "No Results"
                )
            )
            .firstMatch

        XCTAssertTrue(
            emptyState.waitForExistence(timeout: 3)
        )
    }
    
    func testSearchFailureShowsErrorAndRetryButton() {
        let app = XCUIApplication()

        app.launchArguments = [
            "-ui-testing",
            "-ui-testing-search-error"
        ]

        app.launch()

        search(for: "Oslo", in: app)

        let errorTitle = app.staticTexts[
            "Unable to search"
        ]

        XCTAssertTrue(
            errorTitle.waitForExistence(timeout: 3)
        )

        let retryButton = app.buttons["Try again"]

        XCTAssertTrue(
            retryButton.waitForExistence(timeout: 3)
        )

        let offlineMessage = app.staticTexts
            .matching(
                NSPredicate(
                    format: "label CONTAINS[c] %@",
                    "offline"
                )
            )
            .firstMatch

        XCTAssertTrue(
            offlineMessage.waitForExistence(timeout: 3)
        )
    }
}

