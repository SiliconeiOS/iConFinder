//
//  ImageLoader.swift
//  iConFinder
//

import Foundation
import UIKit

enum ImageLoaderError: Error, LocalizedError {
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

protocol ImageLoaderProtocol {
    @discardableResult
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) -> Cancellable?
}

final class ImageLoader: ImageLoaderProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) -> (any Cancellable)? {
        let request = URLRequest(url: url)
        
        let task = networkClient.execute(with: request) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(.invalidImageData))
                }
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
        
        return task
    }
}
