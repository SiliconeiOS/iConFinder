//
//  IconMapperTests.swift
//  iConFinderTests
//

import XCTest
@testable import iConFinder

final class IconMapperTests: XCTestCase {
    
    var sut: IconMapper!
    
    //MARK: - Lyfecycle
    
    override func setUp() {
        super.setUp()
        sut = IconMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    //MARK: - Tests
    
    func testMapWhenResponseContainsOneValidIcon() {
        // Given
        let validIconDTO = makeIconDTO(
            id: 1,
            tags: ["cat", "animal"],
            size: 128,
            previewURL: "https://example.com/cat.png",
            downloadURL: "https://example.com/download/cat.png"
        )
        let responseDTO = NetworkDTO.IconsSearchResponse(
            totalCount: 1,
            icons: [validIconDTO]
        )
        
        let expectedIcon = Icon(
            id: 1,
            tags: ["cat", "animal"],
            largestSize: IconSize(width: 128, height: 128),
            previewURL: URL(string: "https://example.com/cat.png")!,
            downloadURL: URL(string: "https://example.com/download/cat.png")!
        )
        
        // When
        let icons = sut.map(responseDTO: responseDTO)
        
        // Then
        XCTAssertEqual(icons.count, 1, "Should map one valid icon.")
        XCTAssertEqual(icons.first, expectedIcon)
    }
    
    func testMapWhenIconHasNoRasterSizes() {
        // Given
        let invalidIconDTO = NetworkDTO.Icon(
            iconId: 1,
            tags: ["invalid"],
            rasterSizes: []
        )
        let responseDTO = NetworkDTO.IconsSearchResponse(
            totalCount: 1, icons: [invalidIconDTO]
        )
        
        // When
        let icons = sut.map(responseDTO: responseDTO)
        
        // Then
        XCTAssertTrue(icons.isEmpty)
    }
    
    func testMapWhenIconHasInvalidPreviewURL() {
        // Given
        let invalidIconDTO = makeIconDTO(
            id: 1,
            previewURL: ""
        )
        let responseDTO = NetworkDTO.IconsSearchResponse(
            totalCount: 1,
            icons: [invalidIconDTO]
        )
        
        // When
        let icons = sut.map(responseDTO: responseDTO)
        
        // Then
        XCTAssertTrue(icons.isEmpty, "Icon with an invalid preview URL should be filtered out.")
    }
    
    func testMapWhenResponseContainsMixedValidityIcons() {
        // Given
        let validIcon1_DTO = makeIconDTO(id: 1, tags: ["valid1"])
        let iconWithNoSizes = NetworkDTO.Icon(iconId: 2, tags: ["invalid"], rasterSizes: [])
        let validIcon2_DTO = makeIconDTO(id: 3, tags: ["valid2"])
        let iconWithBadURL = makeIconDTO(id: 4, previewURL: "")
        
        let responseDTO = NetworkDTO.IconsSearchResponse(totalCount: 4, icons: [validIcon1_DTO, iconWithNoSizes, validIcon2_DTO, iconWithBadURL])
        
        let expectedIcons = [
            Icon(testFrom: validIcon1_DTO)!,
            Icon(testFrom: validIcon2_DTO)!
        ]
        
        // When
        let icons = sut.map(responseDTO: responseDTO)
        
        // Then
        XCTAssertEqual(icons, expectedIcons)
    }
    
    func testMapWhenResponseContainsNoIcons() {
        // Given
        let responseDTO = NetworkDTO.IconsSearchResponse(totalCount: 0, icons: [])
        
        // When
        let icons = sut.map(responseDTO: responseDTO)
        
        // Then
        XCTAssertTrue(icons.isEmpty)
    }
}

//MARK: - Helpers

private extension Icon {
    init?(testFrom dto: NetworkDTO.Icon) {
        do {
            try self.init(from: dto)
        } catch {
            return nil
        }
    }
}
