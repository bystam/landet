//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

private enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

class APIClient {

    static var host = "localhost:3000"

    var requestSetup: ((request: NSMutableURLRequest) -> ())?

    private func request(method method: HttpMethod, towards endpoint: String, data: AnyObject?) -> NSMutableURLRequest {
        let url = NSURL(string: APIClient.host + endpoint)
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = method.rawValue

        if let data = data, body = try? NSJSONSerialization.dataWithJSONObject(data, options: []) {
            request.setValue("applicaton/json", forHTTPHeaderField: "Content-Type")
            request.setValue(String(body.length), forHTTPHeaderField: "Content-Length")
        }

        requestSetup?(request: request)

        return request
    }

}


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

    func setAsyncTask(task: (completion: () -> ()) -> ()) {
        asyncTask = task
    }

    func setCancelTask(task: () -> ()) {
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
