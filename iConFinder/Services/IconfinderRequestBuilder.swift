//
//  IconfinderRequest.swift
//  iConFinder
//

import Foundation

enum RequestBuilderError: Error, LocalizedError {
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

enum IconfinderRequestBuilder {
    case search(query: String, count: Int, offset: Int)
    
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: .baseURL) else {
            throw RequestBuilderError.invalidBaseURL(.baseURL)
        }
        
        switch self {
        case .search(let query, let count, let offset):
            components.path += "/icons/search"
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "count", value: String(count)),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "premium", value: .isPremium),
                URLQueryItem(name: "vector", value: .isVector)
            ]
        }
        
        guard let url = components.url else {
            throw RequestBuilderError.invalidURLComponents
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(String.apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

private extension String {
    static var baseURL: String { "https://api.iconfinder.com/v4" }
    static var apiKey: String { "R6iEg02cuYdihhNjdWX29ZfiE4rrpl8QwGTnjFvCf3nApbcw6S6JgdrRjEB3FRSh" }
    static var isPremium: String { "false" }
    static var isVector: String { "false" }
}
