//
//  DataParser.swift
//  iConFinder
//

import Foundation

enum ParsingError: Error, LocalizedError {
    case decodignError(Error)
    
    var errorDescription: String? {
        switch self {
        case .decodignError(let error):
            return "Failed to decode data \(error.localizedDescription)"
        }
    }
}

protocol DataParserProtocol {
    func parse<T: Decodable>(data: Data) -> Result<T, ParsingError>
}

final class DataParser: DataParserProtocol {
    
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func parse<T>(data: Data) -> Result<T, ParsingError> where T : Decodable {
        do {
            let decodeObject = try decoder.decode(T.self, from: data)
            return .success(decodeObject)
        } catch let error {
            return .failure(.decodignError(error))
        }
    }
}
