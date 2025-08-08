//
//  ImageLoader.swift
//  iConFinder
//

import Foundation
import UIKit

enum ImageServiceError: Error, LocalizedError {
    case requestBuilderError(Error)
    case networkError(NetworkError)
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .requestBuilderError(let error):
            return "Failed to build request: \(error.localizedDescription)"
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
    
    //MARK: - Init
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    //MARK: - ImageLoaderProtocol Implementation
    
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable? {
        do {
            let request = try RequestBuilder
                .downloadIcon(from: url)
                .asURLRequest()
            
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
        } catch {
            completion(.failure(.requestBuilderError(error)))
            return nil
        }
    }
}
