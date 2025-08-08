//
//  NetworkClient.swift
//  iConFinder
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL, invalidResponse, unauthorized, noData
    case requestFailed(Error)
    case unexpectedStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The provided URL is invalid."
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .invalidResponse: return "Received an invalid response from the server."
        case .unauthorized: return "Unauthorized. Please check your API key."
        case .noData: return "There's no data in response"
        case .unexpectedStatusCode(let code): return "Server returned an unexpected status code: \(code)."
        }
    }
}

protocol Cancellable { func cancel() }
extension URLSessionDataTask: Cancellable {}

protocol NetworkClientProtocol {
    @discardableResult
    func execute(with request: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) -> Cancellable?
}

final class NetworkClient: NetworkClientProtocol {
    
    //MARK: - Dependencies
    
    private let session: URLSession
    
    //MARK: - Init
    
    init(session: URLSession) {
        self.session = session
    }
    
    //MARK: - NetworkClientProtocol Implementation
    
    @discardableResult
    func execute(with request: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) -> Cancellable? {
        let completionOnMain: (Result<Data, NetworkError>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                guard (error as NSError).code != NSURLErrorCancelled  else {
                    return
                }
                
                completionOnMain(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionOnMain(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                guard httpResponse.statusCode != 401 else {
                    completionOnMain(.failure(.unauthorized))
                    return
                }
                completionOnMain(.failure(.unexpectedStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data, !data.isEmpty else {
                completionOnMain(.failure(.noData))
                return
            }
            
            completionOnMain(.success(data))
        }
        
        task.resume()
        return task
    }
}

//MARK: - NetworkError Equatable Implementation

extension NetworkError: Equatable {
    static func ==(_ lhs: NetworkError, _ rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.noData, .noData):
            return true
        case (.unexpectedStatusCode(let lhsCode), .unexpectedStatusCode(let rhsCode)):
            return lhsCode == rhsCode
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            let lhsNSError = lhsError as NSError
            let rhsNSError = rhsError as NSError
            return lhsNSError.domain == rhsNSError.domain && lhsNSError.code == rhsNSError.code
        default:
            return false
        }
    }
}
