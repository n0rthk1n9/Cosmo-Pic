//
//  CosmoPicUITests.swift
//  CosmoPicUITests
//
//  Created by Jan Armbrust on 20.11.23.
//

import XCTest

final class CosmoPicUITests: XCTestCase {
//  var app: XCUIApplication = .init()
//
//  override func setUp() {
//    app = XCUIApplication()
//    app.launchArguments = ["UITesting"]
//    app.launch()
//  }
//
//  func test_APODView_photoView_isLoaded() {
//    app.dismissWelcomeSheet()
//
//    let photoView = app.descendants(matching: .any)
//      .matching(identifier: "apod-view-photo")
//      .element
//
//    XCTAssertTrue(photoView.waitForExistence(timeout: 20))
//
//    screenshot(named: "apod-view-photo")
//  }
//
//  func test_APODView_favoritesButton_vanishes() {
//    app.dismissWelcomeSheet()
//
//    let photoView = app.descendants(matching: .any)
//      .matching(identifier: "apod-view-photo")
//      .element
//
//    XCTAssertTrue(photoView.waitForExistence(timeout: 20))
//
//    let favoritesTab = app.tabBars.buttons.element(boundBy: 1)
//
//    favoritesTab.tap()
//
//    let favoritesList = app.descendants(matching: .any)
//      .matching(identifier: "favorites-list")
//      .element
//
//    if favoritesList.exists {
//      let firstCell = favoritesList.cells.element(boundBy: 0)
//      if firstCell.exists {
//        firstCell.swipeLeft()
//        app.buttons["Delete"].tap()
//      }
//    }
//
//    let APODTab = app.tabBars.buttons.element(boundBy: 0)
//
//    APODTab.tap()
//
//    let favoritesButton = app.descendants(matching: .any)
//      .matching(identifier: "apod-view-favorites-button")
//      .element
//
//    XCTAssertTrue(favoritesButton.exists)
//
//    favoritesButton.tap()
//
//    XCTAssertFalse(favoritesButton.exists)
//
//    screenshot(named: "apod-view-favorites-button")
//  }
//
//  func test_photoDetailView_photoView_isLoaded() {
//    app.dismissWelcomeSheet()
//
//    let favoritesTab = app.tabBars.buttons.element(boundBy: 1)
//
//    favoritesTab.tap()
//
//    let favoritesList = app.descendants(matching: .any)
//      .matching(identifier: "favorites-list")
//      .element
//
//    if favoritesList.exists {
//      let firstCell = favoritesList.cells.element(boundBy: 0)
//      if firstCell.exists {
//        firstCell.tap()
//      }
//    }
//
//    let photoDetailViewPhotoExplanationView = app.descendants(matching: .any)
//      .matching(identifier: "photo-detail-view-photo-explanation")
//      .element
//
//    XCTAssertTrue(photoDetailViewPhotoExplanationView.waitForExistence(timeout: 20))
//
//    screenshot(named: "photo-detail-view-photo-explanation")
//  }
//
//  func test_WelcomeScreen_isLoaded() {
//    let welcomeText = app.staticTexts["Welcome to Cosmo Pic"]
//    XCTAssertTrue(welcomeText.waitForExistence(timeout: 10))
//  }
  // }
//
  // extension XCTestCase {
//  func screenshot(named name: String) {
//    let fullScreenshot = XCUIScreen.main.screenshot()
//    let screenshotAttachment = XCTAttachment(
//      uniformTypeIdentifier: "public.png",
//      name: "Screenshot-\(UIDevice.current.name)-\(name).png",
//      payload: fullScreenshot.pngRepresentation,
//      userInfo: nil
//    )
//    screenshotAttachment.lifetime = .keepAlways
//    add(screenshotAttachment)
//  }
}

extension XCUIApplication {
//  func dismissWelcomeSheet() {
//    let welcomeText = staticTexts["Welcome to Cosmo Pic"]
//    XCTAssertTrue(welcomeText.waitForExistence(timeout: 10))
//
//    if welcomeText.exists {
//      let getStartedButton = buttons["Get Started"]
//      getStartedButton.tap()
//    }
//  }
}
