//
//  NetworkClientMock.swift
//  iConFinderTests
//

import Foundation
@testable import iConFinder

final class NetworkClientMock: NetworkClientProtocol {
    var result: Result<Data, NetworkError>?
    var returnedTask: Cancellable? = CancellableMock()
    
    func execute(with request: URLRequest, completion: @escaping (Result<Data, iConFinder.NetworkError>) -> Void) -> (any iConFinder.Cancellable)? {
        if let result {
            DispatchQueue.main.async {
                completion(result)
            }
        }
        return returnedTask
    }
}
