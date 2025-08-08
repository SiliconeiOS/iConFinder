//
//  ImageLoader.swift
//  iConFinder
//

import Foundation
import UIKit

enum ImageServiceError: LocalizedError {
    case networkError(NetworkError)
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Image loading failed due to a network issue: \(error.localizedDescription)"
        case .invalidImageData:
            return "Failed to create an image from the recevid data."
        }
    }
    
}

protocol ImageServiceProtocol {
    @discardableResult
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable?
}

final class ImageService: ImageServiceProtocol {
    
    //MARK: - Dependencies
    
    private let networkClient: NetworkClientProtocol
    private let requestBuilder: DownloadIconRequestBuilder
    
    //MARK: - Init
    
    init(
        networkClient: NetworkClientProtocol,
        requestBuilder: DownloadIconRequestBuilder
    ) {
        self.networkClient = networkClient
        self.requestBuilder = requestBuilder
    }
    
    //MARK: - ImageLoaderProtocol Implementation
    
    @discardableResult
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable? {
        let request = requestBuilder.downloadIcon(from: url)
        
        let task = networkClient.execute(with: request) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(.invalidImageData))
                    return
                }
                completion(.success(image))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
        
        return task
    }
}
    
    //MARK: - ImageServiceError Equatable Implementation
    
extension ImageServiceError: Equatable {
    static func ==(_ lhs: ImageServiceError, _ rhs: ImageServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidImageData, .invalidImageData):
            return true
        case (.networkError(let lhsErr), .networkError(let rhsErr)):
            return lhsErr == rhsErr
        default:
            return false
        }
    }
}

