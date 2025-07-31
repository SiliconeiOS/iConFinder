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
        completion: @escaping (Result<[Icon], IconsServiceError>) -> Void
    ) -> Cancellable?
}

final class IconsService: IconsServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    private let dataParser: DataParserProtocol
    private let iconMapper: IconMapperProtocol
    
    init(
        networkClient: NetworkClientProtocol,
        dataParser: DataParserProtocol,
        iconMapper: IconMapperProtocol
    ) {
        self.networkClient = networkClient
        self.dataParser = dataParser
        self.iconMapper = iconMapper
    }
    
    @discardableResult
    func fetchIcons(
        query: String,
        count: Int,
        offset: Int,
        completion: @escaping (Result<[Icon], IconsServiceError>) -> Void
    ) -> Cancellable? {
        do {
            let request = try IconfinderRequestBuilder.search(query: query, count: count, offset: offset).asURLRequest()
            
            let task = networkClient.execute(with: request) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    process(data: data, completion: completion)
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
    
    private func process(data: Data, completion: @escaping (Result<[Icon], IconsServiceError>) -> Void) {
        let parsingResult: Result<NetworkDTO.IconsSearchResponse, ParsingError> = dataParser.parse(data: data)
        
        switch parsingResult {
        case .success(let responseDTO):
            let icons = iconMapper.map(responseDTO: responseDTO)
            completion(.success(icons))
        case .failure(let error):
            completion(.failure(.processingError(error)))
        }
    }
}
