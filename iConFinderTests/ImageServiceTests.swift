//
//  ImageServiceTests.swift
//  iConFinderTests
//

import XCTest
@testable import iConFinder

final class ImageServiceTests: XCTestCase {
    
    var sut: ImageService!
    var networkClient: NetworkClientMock!
    var requestBuilderMock: DownloaIconRequestBuilderMock!
    
    //MARK: - LifeCycle
    
    override func setUp() {
        super.setUp()
        
        networkClient = NetworkClientMock()
        requestBuilderMock = DownloaIconRequestBuilderMock()
        sut = ImageService(
            networkClient: networkClient,
            requestBuilder: requestBuilderMock
        )
    }
    
    override func tearDown() {
        sut = nil
        requestBuilderMock = nil
        networkClient = nil
        
        super.tearDown()
    }
    
    //MARK: - Tests
    
    func testFetchImageWhenNetworkClientReturnValidImageData() {
        // Given
        let validImageData = makeMinimalValidDataPNG()
        networkClient.result = .success(validImageData)
        
        let testURL = URL(string: "https://example.com/image.png")!
        let expectation = XCTestExpectation(description: "Successfully fetch and create an image")
        var receivedImage: UIImage?
        
        // When
        sut.fetchImage(from: testURL) { result in
            if case .success(let image) = result {
                receivedImage = image
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedImage)
        XCTAssertEqual(receivedImage?.size, CGSize(width: 1, height: 1))
    }
    
    func testFetchImageWhenNetworkClientReturnsInvalidData() {
        // Given
        let invalidData = "this is not an image".data(using: .utf8)!
        networkClient.result = .success(invalidData)
        
        let testUrl = URL(string: "https://example.com/invalid.png")!
        let expectation = XCTestExpectation(description: "Fail to create an image from invalid data")
        var receivedError: ImageServiceError?
        
        // When
        sut.fetchImage(from: testUrl) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .invalidImageData)
    }
    
    func testFetchImageWhenNetworkClientReturnsError() {
        // Given
        let expectedNetworkError = NetworkError.unauthorized
        networkClient.result = .failure(expectedNetworkError)
        
        let testURL = URL(string: "https://exapme.com/unauthorized")!
        let expectation = XCTestExpectation(description: "Propagete network error")
        var receivedError: ImageServiceError?
        
        // When
        sut.fetchImage(from: testURL) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .networkError(expectedNetworkError))
    }
}
