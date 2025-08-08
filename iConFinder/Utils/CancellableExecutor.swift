//
//  CancellableExecutor.swift
//  iConFinder
//

import Foundation

protocol IsCancelled {
    var isCancelled: Bool { get }
}
extension DispatchWorkItem: IsCancelled { }

protocol CancellableExecutorProtocol: AnyObject {
    func execute(delay: DispatchTimeInterval, handler: @escaping (IsCancelled) -> Void)
    func cancel()
}

final class CancellableExecutor: CancellableExecutorProtocol {
    
    //MARK: - Dependencies
    
    private let queue: DispatchQueue
    
    //MARK: - State
    
    private var pendingWorkItem: DispatchWorkItem?

    //MARK: - Init
    
    init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    //MARK: - Dinit
    
    deinit {
        cancel()
    }
    
    //MARK: - CancellableExecutorProtocol Implementation
    
    func execute(delay: DispatchTimeInterval, handler: @escaping (IsCancelled) -> Void) {
        cancel()
        
        var workItem: DispatchWorkItem?
        
        workItem = DispatchWorkItem {
            handler(workItem ?? StubIsCancelled(isCancelled: true))
            workItem = nil
        }
        
        pendingWorkItem = workItem

        workItem.map {
            queue.asyncAfter(deadline: .now() + delay, execute: $0)
        }
    }

    func cancel() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
    }
}

//MARK: - Private Section

private extension CancellableExecutor {
    
    struct StubIsCancelled: IsCancelled {
        let isCancelled: Bool
    }
}
