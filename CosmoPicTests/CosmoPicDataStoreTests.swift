//
//  CosmoPicDataStoreTests.swift
//  CosmoPicDataStoreTests
//
//  Created by Jan Armbrust on 20.11.23.
//

@testable import CosmoPic
import XCTest

final class CosmoPicDataStoreTests: XCTestCase {
//  var dataStore: DataStore = .init()
//
//  override func setUp() {
//    dataStore = DataStore(
//      photoAPIService: PhotoAPIServiceMock(),
//      historyAPIService: HistoryAPIServiceMock()
//    )
//  }
//
//  override func tearDown() {
//    let fileManager = FileManager.default
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString)-history.json")
//    let photoJSONFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString).json")
//    try? fileManager.removeItem(at: historyFilePath)
//    try? fileManager.removeItem(at: photoJSONFilePath)
//  }
//
//  func test_getPhoto_forToday() async {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getPhoto(for: todayString)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertEqual(dataStore.photo, .allProperties)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getPhoto_forToday_fromFile() async {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    let dummyData = Data()
//    let photoJSONFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString).json")
//    try? dummyData.write(to: photoJSONFilePath)
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getPhoto(for: todayString)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertEqual(dataStore.photo, .allProperties)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getPhoto_forOtherDate() async {
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getPhoto(for: "2023-09-04")
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertEqual(dataStore.photo, .allProperties)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getHistory() async {
//    XCTAssertFalse(dataStore.isLoadingHistory)
//    XCTAssertEqual(dataStore.history, [])
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getHistory()
//
//    XCTAssertFalse(dataStore.isLoadingHistory)
//    XCTAssertEqual(
//      dataStore.history,
//      [
//        .allProperties,
//        .allProperties
//      ]
//    )
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getHistory_WhenFileDoesNotExist() async {
//    let fileManager = FileManager.default
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString)-history.json")
//    try? fileManager.removeItem(at: historyFilePath)
//
//    await dataStore.getHistory()
//
//    XCTAssertFalse(dataStore.isLoadingHistory)
//    XCTAssertEqual(dataStore.history.count, 2)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getHistory_WhenFileDoesExist() async {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    let dummyData = Data()
//    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString)-history.json")
//    try? dummyData.write(to: historyFilePath)
//
//    await dataStore.getHistory()
//
//    XCTAssertFalse(dataStore.isLoadingHistory)
//    XCTAssertEqual(dataStore.history.count, 2)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//  }
//
//  func test_getPhoto_errorIsHandeled_whenFileDoesExist() async throws {
//    dataStore = DataStore(
//      photoAPIService: PhotoAPIServiceErrorMock()
//    )
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//    let dummyData = Data()
//    let photoJSONFilePath = FileManager.documentsDirectoryURL.appendingPathComponent("\(todayString).json")
//    try? dummyData.write(to: photoJSONFilePath)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getPhoto(for: todayString)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertTrue(dataStore.errorIsPresented)
//    let error = try XCTUnwrap(dataStore.error)
//    XCTAssertEqual(error.localizedDescription, PhotoAPIServiceErrorMock.SomeError.anError.localizedDescription)
//  }
//
//  func test_getPhoto_errorIsHandeled_whenFileDoesNotExist() async throws {
//    dataStore = DataStore(
//      photoAPIService: PhotoAPIServiceErrorMock()
//    )
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDate = Date()
//    let todayString = dateFormatter.string(from: currentDate)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertFalse(dataStore.errorIsPresented)
//    XCTAssertNil(dataStore.error)
//
//    await dataStore.getPhoto(for: todayString)
//
//    XCTAssertFalse(dataStore.isLoading)
//    XCTAssertNil(dataStore.photo)
//    XCTAssertTrue(dataStore.errorIsPresented)
//    let error = try XCTUnwrap(dataStore.error)
//    XCTAssertEqual(error.localizedDescription, PhotoAPIServiceErrorMock.SomeError.anError.localizedDescription)
//  }
}
