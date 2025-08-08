//
//  IconfinderRequest.swift
//  iConFinder
//

import Foundation

protocol SearchIconsRequestBuilder {
    func search(query: String, count: Int, offset: Int) throws -> URLRequest
}

protocol DownloadIconRequestBuilder {
    func downloadIcon(from url: URL) -> URLRequest
}

struct RequestBuilder {
    
    enum Error: LocalizedError {
        case invalidBaseURL(String)
        case invalidURLComponents
        
        var errorDescription: String? {
            switch self {
            case .invalidBaseURL(let url):
                return "The base URL '\(url)' is invalid."
            case .invalidURLComponents:
                return "Failed to create URL from components."
            }
        }
    }
    
    private let baseURL: String
    private let apiKey: String
    
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}

//MARK: - SearchIconsRequestBuilder Implementation

extension RequestBuilder: SearchIconsRequestBuilder {
    
    func search(query: String, count: Int, offset: Int) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw Error.invalidBaseURL(baseURL)
        }
        
        components.path += "/icons/search"
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "count", value: String(count)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "premium", value: .isPremium),
            URLQueryItem(name: "vector", value: .isVector)
        ]
        
        guard let url = components.url else {
            throw Error.invalidURLComponents
        }
        
        return authorizedRequest(for: url)
    }
}

//MARK: - DownloadIconRequestBuilder Implementaion

extension RequestBuilder: DownloadIconRequestBuilder {
    func downloadIcon(from url: URL) -> URLRequest {
        return authorizedRequest(for: url)
    }
}

//MARK: - Private Section

private extension RequestBuilder {
    
    func authorizedRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}


//MARK: - RequestBuilder.Error Equatable Implementation

extension RequestBuilder.Error: Equatable {
    static func ==(_ lhs: RequestBuilder.Error, _ rhs: RequestBuilder.Error) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURLComponents, .invalidURLComponents):
            return true
        case (.invalidBaseURL(let lhsURL), .invalidBaseURL(let rhsURL)):
            return lhsURL == rhsURL
        default:
            return false
        }
    }
}

//MARK: - Private Constatns

private extension String {
    static var isPremium: String { "false" }
    static var isVector: String { "false" }
}
