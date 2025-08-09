//
//  SearchIconsRequestBuilderMock.swift
//  iConFinderTests
//

import Foundation
@testable import iConFinder

final class SearchIconsRequestBuilderMock: SearchIconsRequestBuilder {
    var searchResult: Result<URLRequest, RequestBuilder.Error> = .success(URLRequest(url: URL(string: "https://test.com")!))

    func search(query: String, count: Int, offset: Int) throws -> URLRequest {
        switch searchResult {
        case .success(let request):
            return request
        case .failure(let error):
            throw error
        }
    }
}
