//
//  CosmoPicUITests.swift
//  CosmoPicUITests
//
//  Created by Jan Armbrust on 20.11.23.
//

import XCTest

final class CosmoPicUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() {
    app = XCUIApplication()
    app.launch()
  }

  func test_APODView_photoView_isLoaded() {
    let photoView = app.descendants(matching: .any)
      .matching(identifier: "apod-view-photo")
      .element

    XCTAssertTrue(photoView.waitForExistence(timeout: 20))

    screenshot(named: "apod-view-photo")
  }

  func test_APODView_favoritesButton_vanishes() {
    let favoritesTab = app.tabBars.buttons.element(boundBy: 1)

    favoritesTab.tap()

    let favoritesList = app.descendants(matching: .any)
      .matching(identifier: "favorites-list")
      .element

    if favoritesList.exists {
      let firstCell = favoritesList.cells.element(boundBy: 0)
      if firstCell.exists {
        firstCell.swipeLeft()
        app.buttons["Delete"].tap()
      }
    }

    let APODTab = app.tabBars.buttons.element(boundBy: 0)

    APODTab.tap()

    let favoritesButton = app.descendants(matching: .any)
      .matching(identifier: "apod-view-favorites-button")
      .element

    XCTAssertTrue(favoritesButton.exists)

    favoritesButton.tap()

    XCTAssertFalse(favoritesButton.exists)

    screenshot(named: "apod-view-favorites-button")
  }

  func test_photoDetailView_photoView_isLoaded() {
    let favoritesTab = app.tabBars.buttons.element(boundBy: 1)

    favoritesTab.tap()

    let favoritesList = app.descendants(matching: .any)
      .matching(identifier: "favorites-list")
      .element

    if favoritesList.exists {
      let firstCell = favoritesList.cells.element(boundBy: 0)
      if firstCell.exists {
        firstCell.tap()
      }
    }

    let photoDetailViewPhotoExplanationView = app.descendants(matching: .any)
      .matching(identifier: "photo-detail-view-photo-explanation")
      .element

    XCTAssertTrue(photoDetailViewPhotoExplanationView.exists)

    screenshot(named: "photo-detail-view-photo-explanation")
  }
}

extension XCTestCase {
  func screenshot(named name: String) {
    let fullScreenshot = XCUIScreen.main.screenshot()
    let screenshotAttachment = XCTAttachment(
      uniformTypeIdentifier: "public.png",
      name: "Screenshot-\(UIDevice.current.name)-\(name).png",
      payload: fullScreenshot.pngRepresentation,
      userInfo: nil
    )
    screenshotAttachment.lifetime = .keepAlways
    add(screenshotAttachment)
  }
}
