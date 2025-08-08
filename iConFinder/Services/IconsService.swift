//
//  IconsService.swift
//  iConFinder
//

import Foundation

enum IconsServiceError: LocalizedError {
    case requestBuilderError(RequestBuilder.Error)
    case networkError(NetworkError)
    case processingError(ParsingError)
    case unexpectedError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .requestBuilderError(let error):
            return "Failed to build request: \(error.localizedDescription)"
        case .networkError(let error):
            return error.localizedDescription
        case .processingError(let error):
            return "Failed to process server data. Cause: \(error.localizedDescription)"
        case .unexpectedError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

protocol IconsServiceProtocol {
    @discardableResult
    func fetchIcons(
        query: String,
        count: Int,
        offset: Int,
        completion: @escaping (Result<NetworkDTO.IconsSearchResponse, IconsServiceError>) -> Void
    ) -> Cancellable?
}

final class IconsService: IconsServiceProtocol {
    
    //MARK: - Dependencies
    
    private let networkClient: NetworkClientProtocol
    private let requestBuilder: SearchIconsRequestBuilder
    private let dataParser: DataParserProtocol
    
    //MARK: - Init
    
    init(
        networkClient: NetworkClientProtocol,
        requestBuilder: SearchIconsRequestBuilder,
        dataParser: DataParserProtocol
    ) {
        self.networkClient = networkClient
        self.requestBuilder = requestBuilder
        self.dataParser = dataParser
    }
    
    //MARK: - IconsServiceProtocol Implementation
    
    @discardableResult
    func fetchIcons(
        query: String,
        count: Int,
        offset: Int,
        completion: @escaping (Result<NetworkDTO.IconsSearchResponse, IconsServiceError>) -> Void
    ) -> Cancellable? {
        do {
            let request = try requestBuilder.search(query: query, count: count, offset: offset)
            
            let task = networkClient.execute(with: request) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    parse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }
            
            return task
        } catch let error as RequestBuilder.Error {
            completion(.failure(.requestBuilderError(error)))
            return nil
        } catch {
            completion(.failure(.unexpectedError(error)))
            return nil
        }
    }
    
    //MARK: - Private Section
    
    private func parse(data: Data, completion: @escaping (Result<NetworkDTO.IconsSearchResponse, IconsServiceError>) -> Void) {
        let parsingResult: Result<NetworkDTO.IconsSearchResponse, ParsingError> = dataParser.parse(data: data)
        
        switch parsingResult {
        case .success(let responseDTO):
            completion(.success(responseDTO))
        case .failure(let error):
            completion(.failure(.processingError(error)))
        }
    }
}

extension IconsServiceError: Equatable {
    static func == (lhs: IconsServiceError, rhs: IconsServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.requestBuilderError(let lhsErr), .requestBuilderError(let rhsErr)):
            return lhsErr == rhsErr
        case (.networkError(let lhsErr), .networkError(let rhsErr)):
            return lhsErr == rhsErr
        case (.processingError(let lhsErr), .processingError(let rhsErr)):
            return lhsErr == rhsErr
        case (.unexpectedError(let lhsErr), .unexpectedError(let rhsErr)):
            let lhsNSErr = lhsErr as NSError
            let rhsNSErr = rhsErr as NSError
            return lhsNSErr.domain == rhsNSErr.domain && lhsNSErr.code == rhsNSErr.code
            
        default:
            return false
        }
    }
}
