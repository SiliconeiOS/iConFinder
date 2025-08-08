//
//  CancellableMock.swift
//  iConFinderTests
//

@testable import iConFinder

final class CancellableMock: Cancellable {
    var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}
