//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

struct APIResponse {
    let httpStatus: HttpStatusCode
    let body: AnyObject?
    let error: NSError?
}

protocol APIClient {
    func get(endpoint: String, completion: (response: APIResponse) -> ())
    func post(endpoint: String, body: [String : AnyObject], completion: (response: APIResponse) -> ())
    func put(endpoint: String, body: [String : AnyObject], completion: (response: APIResponse) -> ())
    func delete(endpoint: String, completion: (response: APIResponse) -> ())
}


private enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

class HttpClient {

    static let sharedUrlSession: NSURLSession = {
        let config = NSURLSessionConfiguration()
        config.timeoutIntervalForRequest = 20.0
        return NSURLSession(configuration: config)
    }()

    static var host = "192.168.1.174:3000"
    static var debugHost: String?

    var requestSetup: ((request: NSMutableURLRequest) -> ())?

    private func send(request request: NSURLRequest,
                              requestCompletion: (body: AnyObject?, response: NSHTTPURLResponse?, error: NSError?) -> ()) {
        let session = HttpClient.sharedUrlSession
        let operation = AsyncOperation()
        var task: NSURLSessionTask!

        operation.asyncTask { (operationCompletion) in
            task = session.dataTaskWithURL(request.URL!) { (body, response, error) in

                var responseError = error
                var data: AnyObject?

                if let body = body {
                    do {
                        data = try NSJSONSerialization.JSONObjectWithData(body, options: [])
                    } catch let e as NSError {
                        responseError = responseError ?? e
                    }
                }

                // run the response completion block before considering the operation done
                requestCompletion(body: data, response: response as? NSHTTPURLResponse, error: responseError)
                operationCompletion()
            }

            task.resume()
        }

        operation.cancelTask {
            task.cancel()
        }
    }

    private func request(method method: HttpMethod, towards endpoint: String, body: AnyObject?) -> NSMutableURLRequest {
        let url = NSURL(string: (HttpClient.debugHost ?? HttpClient.host) + endpoint)
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = method.rawValue

        if let body = body, data = try? NSJSONSerialization.dataWithJSONObject(body, options: []) {
            request.setValue("applicaton/json", forHTTPHeaderField: "Content-Type")
            request.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
        }

        requestSetup?(request: request)

        return request
    }
}

extension HttpClient: APIClient {

    func get(endpoint: String, completion: (response: APIResponse) -> ()) {
        let req = request(method: .GET, towards: endpoint, body: nil)

        send(request: req) { (body, response, error) in
            let status = HttpStatusCode(rawValue: response!.statusCode)!
            completion(response: APIResponse(httpStatus: status, body: body, error: error))
        }
    }

    func post(endpoint: String, body: [String : AnyObject], completion: (response: APIResponse) -> ()) {
        let req = request(method: .POST, towards: endpoint, body: body)

        send(request: req) { (body, response, error) in
            let status = HttpStatusCode(rawValue: response!.statusCode)!
            completion(response: APIResponse(httpStatus: status, body: body, error: error))
        }
    }

    func put(endpoint: String, body: [String : AnyObject], completion: (response: APIResponse) -> ()) {
        let req = request(method: .PUT, towards: endpoint, body: body)

        send(request: req) { (body, response, error) in
            let status = HttpStatusCode(rawValue: response!.statusCode)!
            completion(response: APIResponse(httpStatus: status, body: body, error: error))
        }
    }

    func delete(endpoint: String, completion: (response: APIResponse) -> ()) {
        let req = request(method: .DELETE, towards: endpoint, body: nil)

        send(request: req) { (body, response, error) in
            let status = HttpStatusCode(rawValue: response!.statusCode)!
            completion(response: APIResponse(httpStatus: status, body: body, error: error))
        }
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
