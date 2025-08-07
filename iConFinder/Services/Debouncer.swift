//
//  Debouncer.swift
//  iConFinder
//

import Foundation

protocol DebouncerProtocol: AnyObject {
    func debounce(_ handler: @escaping () -> Void)
    func cancel()
}

final class Debouncer: DebouncerProtocol {

    // MARK: - Dependencies

    private let executor: CancellableExecutorProtocol

    // MARK: - Configuration

    private let delay: DispatchTimeInterval

    // MARK: - Init

    init(delay: DispatchTimeInterval = .milliseconds(500), executor: CancellableExecutorProtocol = CancellableExecutor()) {
        self.delay = delay
        self.executor = executor
    }

    // MARK: - DebouncerProtocol Implementation

    func debounce(_ handler: @escaping () -> Void) {
        executor.execute(delay: delay) { isCancelled in
            guard !isCancelled.isCancelled else { return }
            handler()
        }
    }

    func cancel() {
        executor.cancel()
    }
}


