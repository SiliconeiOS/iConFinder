//
//  DataParser.swift
//  iConFinder
//

import Foundation

enum ParsingError: LocalizedError {
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
    
    //MARK: - Dependencies
    
    private let decoder: JSONDecoder
    
    //MARK: - Init
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    //MARK: - DataParserProtocol Implementation
    
    func parse<T>(data: Data) -> Result<T, ParsingError> where T : Decodable {
        do {
            let decodeObject = try decoder.decode(T.self, from: data)
            return .success(decodeObject)
        } catch let error {
            return .failure(.decodignError(error))
        }
    }
}

extension ParsingError: Equatable {
    static func ==(_ lhs: ParsingError, _ rhs: ParsingError) -> Bool {
        switch (lhs, rhs) {
        case (.decodignError(let lhsErr), .decodignError(let rhsErr)):
            let lhsNSErr = lhsErr as NSError
            let rhsNSErr = rhsErr as NSError
            return lhsNSErr.domain == rhsNSErr.domain && lhsNSErr.code == rhsNSErr.code
        }
    }
}
