//
//  iConFinderUITests.swift
//  iConFinderUITests
//

import XCTest

final class iConFinderUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    @MainActor
    func testSearchForQueryShouldDisplayResults() throws {
        // Given
        let searchQuery = "cat"
        let searchField = app.searchFields["searchBarTextField"]
        
        let iconsTableView = app.tables["iconsTableView"]
        
        // When
        let searchBarExists = searchField.waitForExistence(timeout: 10)
        XCTAssert(searchBarExists, "Поисковая строка (searchBar) не появилась на экране.")
        searchField.tap()
        searchField.typeText(searchQuery + "\n")
        
        // Then
        let tableViewExists = iconsTableView.waitForExistence(timeout: 10)
        XCTAssert(tableViewExists, "Таблица с результатами должна была появиться после поиска.")
        
        let cellCount = iconsTableView.cells.count
        XCTAssert(cellCount > 0, "В таблице должна быть как минимум одна ячейка с результатом.")
        
        let firstCell = iconsTableView.cells.element(boundBy: 0)
        XCTAssert(firstCell.exists)
        
        let sizeLabel = firstCell.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Size:'")).firstMatch
        XCTAssert(sizeLabel.waitForExistence(timeout: 1), "Должна быть метка с размером")
        
        let tagsLabel = firstCell.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Tags:'")).firstMatch
        XCTAssert(tagsLabel.waitForExistence(timeout: 1), "Должна быть метка с тегами")
    }
    
    @MainActor
    func testSearchAndCancelShouldReturnToInitialState() throws {
        // Given
        let searchQuery = "book"
        let searchField = app.searchFields["searchBarTextField"]
        let iconsTableView = app.tables["iconsTableView"]
        let cancelButton = app.buttons["Cancel"] // Получаем кнопку "Cancel" заранее
        
        // When: Start searching by typing text
        XCTAssert(searchField.waitForExistence(timeout: 5), "Поисковая строка не найдена")
        searchField.tap()
        
        // Вводим текст, но НЕ нажимаем Enter (\n)
        // Это оставит search controller активным, и кнопка "Cancel" будет видима
        searchField.typeText(searchQuery)
        
        // Then: Verify results are shown
        // Ожидание может быть немного дольше из-за debouncer
        XCTAssert(iconsTableView.waitForExistence(timeout: 15), "Таблица с результатами должна была появиться после поиска.")
        XCTAssert(iconsTableView.cells.count > 0, "В таблице должны быть ячейки с результатами.")
        
        // И убедимся, что кнопка "Cancel" видима
        XCTAssert(cancelButton.exists, "Кнопка 'Cancel' должна быть видима во время поиска.")
        
        // When: Cancel the search
        cancelButton.tap()
        
        // Then: Verify the view returned to the initial state
        XCTAssertFalse(iconsTableView.exists, "Таблица с результатами должна была исчезнуть после отмены поиска.")
        
        let initialStateMessageLabel = app.staticTexts["stateMessageLabel"]
        XCTAssert(initialStateMessageLabel.waitForExistence(timeout: 5), "Сообщение начального состояния должно снова появиться.")
        XCTAssertEqual(initialStateMessageLabel.label, "Start by searching for an icon", "Текст должен соответствовать начальному состоянию.")
        
        // Дополнительная проверка, что поле поиска очистилось
        XCTAssertEqual(searchField.value as? String, "Search for icons...", "Поисковое поле должно очиститься до плейсхолдера.")
    }
}
