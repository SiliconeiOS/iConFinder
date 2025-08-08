//
//  RequestBuilderTests.swift
//  iConFinderTests
//

import XCTest
@testable import iConFinder

final class RequestBuilderTests: XCTestCase {

    func testSearchWhenInitializedWithValidURLShouldCreateCorrectRequest() throws {
        // Given
        let sut = RequestBuilder(baseURL: "https://test.api.com/v1", apiKey: "TEST_API_KEY")
        let query = "cat"
        
        // When
        let request = try sut.search(query: query, count: 10, offset: 20)
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET", "HTTP method should be GET.")
        
        let url = try XCTUnwrap(request.url, "Request URL should not be nil.")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true), "URL components should be valid.")
        
        XCTAssertEqual(components.scheme, "https", "URL scheme should be https.")
        XCTAssertEqual(components.host, "test.api.com", "URL host should match the base URL.")
        XCTAssertEqual(components.path, "/v1/icons/search", "URL path should be correct.")
        
        let expectedQueryItems: Set<URLQueryItem> = [
            URLQueryItem(name: "query", value: "cat"),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "offset", value: "20"),
            URLQueryItem(name: "premium", value: "false"),
            URLQueryItem(name: "vector", value: "false")
        ]
        let actualQueryItems = Set(components.queryItems ?? [])
        
        XCTAssertEqual(actualQueryItems, expectedQueryItems, "Query items should be correctly formed.")
        
        let authorizationHeader = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer TEST_API_KEY", "Authorization header should be correctly set.")
    }
    
    func testSearchWhenInitializedWithInvalidBaseURL() {
        // Given
        let sut = RequestBuilder(baseURL: "https ://apple.com", apiKey: "TEST_API_KEY")
        
        // When
        var thrownError: Error?
        XCTAssertThrowsError(try sut.search(query: "cat", count: 10, offset: 0)) {
            thrownError = $0
        }
        
        // Then
        XCTAssertTrue(thrownError is RequestBuilder.Error, "Thrown error should be of type RequestBuilderError.")
        XCTAssertEqual(thrownError as? RequestBuilder.Error, .invalidBaseURL("https ://apple.com"), "The specific error should be .invalidBaseURL.")
    }

    // MARK: - Tests for `downloadIcon` method
    
    func testDownloadIconWhenGivenURL() {
        // Given
        let sut = RequestBuilder(baseURL: "https://test.api.com/v1", apiKey: "TEST_API_KEY")
        let downloadUrl = URL(string: "https://cdn.example.com/image.png")!
        
        // When
        let request = sut.downloadIcon(from: downloadUrl)
        
        // Then
        XCTAssertEqual(request.url, downloadUrl, "Request URL should be the same as the one provided.")
        XCTAssertEqual(request.httpMethod, "GET", "HTTP method should be GET.")
        
        let authorizationHeader = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorizationHeader, "Bearer TEST_API_KEY", "Authorization header should be correctly set.")
    }
}
