//
//  CosmoPicDataStoreTests.swift
//  CosmoPicDataStoreTests
//
//  Created by Jan Armbrust on 20.11.23.
//

@testable import CosmoPic
import XCTest

final class CosmoPicDataStoreTests: XCTestCase {
  var dataStore: DataStore!

  override func setUp() {
    dataStore = DataStore(
      photoAPIService: PhotoAPIServiceMock()
    )
  }

  func test_getPhoto() async {
    XCTAssertFalse(dataStore.isLoading)
    XCTAssertNil(dataStore.photo)
    XCTAssertFalse(dataStore.errorIsPresented)
    XCTAssertNil(dataStore.error)

    await dataStore.getPhoto(for: "2023-09-04")

    XCTAssertFalse(dataStore.isLoading)
    XCTAssertEqual(dataStore.photo, .allProperties)
    XCTAssertFalse(dataStore.errorIsPresented)
    XCTAssertNil(dataStore.error)
  }
}
