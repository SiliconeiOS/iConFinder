//
//  DataParserMock.swift
//  iConFinderTests
//
//  Created by Иван Дроботов on 8/9/25.
//

import Foundation
@testable import iConFinder

final class DataParserMock: DataParserProtocol {
    var parsingResult: Any?

    func parse<T: Decodable>(data: Data) -> Result<T, ParsingError> {
        if let result = parsingResult as? Result<T, ParsingError> {
            return result
        }
        let error = NSError(domain: "DataParserMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock result not set or of wrong type"])
        return .failure(.decodignError(error))
    }
}
