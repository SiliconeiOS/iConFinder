//
//  IconsService.swift
//  iConFinder
//

import Foundation

enum IconsServiceError: Error, LocalizedError {
    case requestBuilderError(Error)
    case networkError(NetworkError)
    case processingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .requestBuilderError(let error):
            return "Failed to build request: \(error.localizedDescription)"
        case .networkError(let error):
            return error.localizedDescription
        case .processingError(let error):
            return "Failed to process server data. Cause: \(error.localizedDescription)"
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
    private let dataParser: DataParserProtocol
    
    //MARK: - Init
    
    init(
        networkClient: NetworkClientProtocol,
        dataParser: DataParserProtocol
    ) {
        self.networkClient = networkClient
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
            let request = try RequestBuilder
                .search(
                    query: query,
                    count: count,
                    offset: offset
                )
                .asURLRequest()
            
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
        } catch {
            completion(.failure(.requestBuilderError(error)))
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
