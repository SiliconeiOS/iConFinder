//
//  Debouncer.swift
//  iConFinder
//

import Foundation

protocol DebouncerProtocol {
    func debounce(action: @escaping () -> Void)
    func cancel()
}

final class Debouncer: DebouncerProtocol {
    private let delay: DispatchTimeInterval
    private let executor: CancellableExecutorProtocol
    
    init(delay: DispatchTimeInterval, executor: CancellableExecutorProtocol = CancellableExecutor()) {
        self.delay = delay
        self.executor = executor
    }
    
    func debounce(action: @escaping () -> Void) {
        executor.execute(delay: delay) { cancalable in
            if !cancalable.isCancelled {
                action()
            }
        }
    }
    
    func cancel() {
        executor.cancel()
    }
}
