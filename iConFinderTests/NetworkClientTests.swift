//
//  iConFinderTests.swift
//  iConFinderTests
//

import XCTest
@testable import iConFinder

final class NetworkClientTests: XCTestCase {
    
    var sut: NetworkClient!
    var urlSession: URLSession!
    
    //MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession(configuration: configuration)
        sut = NetworkClient(session: urlSession)
    }
    
    override func tearDown() {
        sut = nil
        urlSession = nil
        URLProtocolMock.requestHandler = nil
        
        super.tearDown()
    }
    
    //MARK: - Tests
    
    func testExecuteWhenRequestIsSuccessfull() {
        // Given
        let expectedData = "{\"message\":\"success\"}".data(using: .utf8)
        let testURL = URL(string: "https://api.example.com/success")!
        
        URLProtocolMock.requestHandler = { request in
            guard let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw NetworkError.invalidResponse
            }
            
            return (response, expectedData)
        }
        
        let expectation = XCTestExpectation(description: "Receive successful responase from network client")
        var receiveData: Data?
        
        // When
        sut.execute(with: URLRequest(url: testURL)) { result in
            if case .success(let data) = result {
                receiveData = data
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receiveData)
        XCTAssertEqual(expectedData, receiveData)
    }
    
    func testExecuteWhenServerReturnError500ShouldReturnUnexpectedStatusCodeError() {
        // Given
        let expectedStatusCode = 500
        let testURL = URL(string: "https://api.example.com/serverError")!
        
        URLProtocolMock.requestHandler = { request in
            guard let response = HTTPURLResponse(
                url: testURL,
                statusCode: expectedStatusCode,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw NetworkError.invalidResponse
            }
            
            return (response, nil)
        }
        
        let expectation = XCTestExpectation(description: "Receive 500 server error response")
        var receivedError: NetworkError?
        
        // When
        sut.execute(with: URLRequest(url: testURL)) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .unexpectedStatusCode(500))
    }
    
    func testExecuteWhenServerReturnError401ShouldReturnUnauthorizedError() {
        // Given
        let expectedStatusCode = 401
        let testURL = URL(string: "https://api.example.com/unauthorized")!
        
        URLProtocolMock.requestHandler = { request in
            guard let response = HTTPURLResponse(
                url: testURL,
                statusCode: expectedStatusCode,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw NetworkError.invalidResponse
            }
            
            return (response, nil)
        }
        
        let expectation = XCTestExpectation(description: "Receive 401 unauthorized error response")
        var receivedError: NetworkError?
        
        // When
        sut.execute(with: URLRequest(url: testURL)) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .unauthorized)
    }
    
    func testExecuteWhenResponseContainsNoDataShouldReturnNoDataError() {
        // Given
        let testURL = URL(string: "https://api.example.com/unauthorized")!
        
        URLProtocolMock.requestHandler = { request in
            guard let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw NetworkError.invalidResponse
            }
            return (response, nil)
        }
        
        let expectation = XCTestExpectation(description: "Receive no data error")
        var receivedError: NetworkError?
        
        // When
        sut.execute(with: URLRequest(url: testURL)) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .noData)
    }
}
