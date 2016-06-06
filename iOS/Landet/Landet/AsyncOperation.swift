//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation


private enum AsyncOperationState: String {
    case Ready = "isReady"
    case Executing = "isExecuting"
    case Finished = "isFinished"
}

class AsyncOperation: NSOperation {

    private var state: AsyncOperationState {
        willSet(newState) {
            willChangeValueForKey(state.rawValue)
            willChangeValueForKey(newState.rawValue)
        }
        didSet(oldState) {
            didChangeValueForKey(oldState.rawValue)
            didChangeValueForKey(state.rawValue)
        }
    }

    private var _cancelled = false

    private var asyncTask: ((completion: () -> ()) -> ())?
    private var cancelTask: (() -> ())?

    override init() {
        state = .Ready
    }


    private func finish() {
        state = .Finished
    }


    // MARK: - Async task controllers

    func asyncTask(task: (operationCompletion: () -> ()) -> ()) {
        asyncTask = task
    }

    func cancelTask(task: () -> ()) {
        cancelTask = task
    }


    // MARK: - Overrides

    override func start() {
        if cancelled {
            finish()
            return
        }

        state = .Executing

        if let task = asyncTask {
            task(completion: finish)
        } else {
            finish()
        }

    }

    override func cancel() {
        willChangeValueForKey("isCancelled")
        cancelTask?()
        _cancelled = true
        finish()
        didChangeValueForKey("isCancelled")
    }

    override var ready: Bool { return state == .Ready }
    override var executing: Bool { return state == .Executing }
    override var finished: Bool { return state == .Finished }
    override var cancelled: Bool { return _cancelled }
    override var concurrent: Bool { return asynchronous }
    override var asynchronous: Bool { return true }
    
}
