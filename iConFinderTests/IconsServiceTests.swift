//
//  IconsServiceTests.swift
//  iConFinderTests
//

import XCTest
@testable import iConFinder

final class IconsServiceTests: XCTestCase {

    var sut: IconsService!
    var networkClientMock: NetworkClientMock!
    var requestBuilderMock: SearchIconsRequestBuilderMock!
    var dataParserMock: DataParserMock!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        networkClientMock = NetworkClientMock()
        requestBuilderMock = SearchIconsRequestBuilderMock()
        dataParserMock = DataParserMock()
        
        sut = IconsService(
            networkClient: networkClientMock,
            requestBuilder: requestBuilderMock,
            dataParser: dataParserMock
        )
    }

    override func tearDown() {
        sut = nil
        networkClientMock = nil
        requestBuilderMock = nil
        dataParserMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchIconsWhenSuccessfulReturnsCorrectDataAndCancellableTask() throws {
        // Given
        let expectation = XCTestExpectation(description: "Fetch icons successfully")
        
        let expectedIcon = makeIconDTO(id: 123)
        let expectedResponse = NetworkDTO.IconsSearchResponse(totalCount: 1, icons: [expectedIcon])
        
        let responseData = try JSONEncoder().encode(expectedResponse)
        networkClientMock.result = .success(responseData)
        dataParserMock.parsingResult = Result<NetworkDTO.IconsSearchResponse, ParsingError>.success(expectedResponse)
        
        var receivedResponse: NetworkDTO.IconsSearchResponse?

        // When
        let task = sut.fetchIcons(query: "test", count: 1, offset: 0) { result in
            if case .success(let response) = result {
                receivedResponse = response
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(task, "The returned task should not be nil on a successful request initiation.")
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.totalCount, 1)
        XCTAssertEqual(receivedResponse?.icons.first?.iconId, 123)
    }
    
    func testFetchIconsWhenRequestBuilderFailsReturnsRequestBuilderErrorAndNilTask() {
        // Given
        let expectation = XCTestExpectation(description: "Fail due to request builder error")
        let requestBuilderError = RequestBuilder.Error.invalidBaseURL("bad url")
        requestBuilderMock.searchResult = .failure(requestBuilderError)
        
        var receivedError: IconsServiceError?

        // When
        let task = sut.fetchIcons(query: "test", count: 1, offset: 0) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(task, "The returned task should be nil when request builder fails.")
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .requestBuilderError(requestBuilderError))
    }
    
    func testFetchIconsWhenNetworkFailsReturnsNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Fail due to network error")
        let networkError = NetworkError.unauthorized
        networkClientMock.result = .failure(networkError)
        
        var receivedError: IconsServiceError?
        
        // When
        sut.fetchIcons(query: "test", count: 1, offset: 0) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .networkError(networkError))
    }
    
    func testFetchIconsWhenParsingFailsReturnsProcessingError() throws {
        // Given
        let expectation = XCTestExpectation(description: "Fail due to parsing error")
        
        // The data can be anything, as the parser mock will be configured to fail
        let dummyData = "invalid json".data(using: .utf8)!
        networkClientMock.result = .success(dummyData)
        
        let parsingError = ParsingError.decodignError(
            NSError(domain: "TestError", code: 1, userInfo: nil)
        )
        dataParserMock.parsingResult = Result<NetworkDTO.IconsSearchResponse, ParsingError>.failure(parsingError)
        
        var receivedError: IconsServiceError?
        
        // When
        sut.fetchIcons(query: "test", count: 1, offset: 0) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
//        XCTAssertEqual(receivedError, .processingError(<#T##any Error#>))
        
        // We check for the case, as the underlying error might not be easily comparable
        guard case .processingError = receivedError else {
            XCTFail("Expected .processingError, but got \(String(describing: receivedError))")
            return
        }
    }
}
