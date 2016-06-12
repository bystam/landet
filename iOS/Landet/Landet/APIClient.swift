//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

protocol APIClient {
    func get(endpoint: String) -> APIOperation
    func post(endpoint: String, body: [String : AnyObject]) -> APIOperation
    func put(endpoint: String, body: [String : AnyObject]) -> APIOperation
    func delete(endpoint: String) -> APIOperation
}

protocol APIResponseMiddleware {
    func errorInBody(body: AnyObject?) -> NSError?
}


private enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

class HttpClient {

    static let sharedUrlSession: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 20.0
        return NSURLSession(configuration: config)
    }()

    static var debugHost: String?

    let host: String
    let responseMiddleware: APIResponseMiddleware?

    var requestSetup: ((request: NSMutableURLRequest) -> ())?

    init(host: String, responseMiddleware: APIResponseMiddleware?) {
        self.host = host
        self.responseMiddleware = responseMiddleware
    }

    private func send(request request: NSURLRequest) -> APIOperation {
        let session = HttpClient.sharedUrlSession
        let operation = APIOperation()
        var task: NSURLSessionTask?

        operation.asyncTask = { (operationCompletion) in

            print("------> \(request.HTTPMethod!) \(request.URL!.absoluteString) ")

            task = session.dataTaskWithRequest(request) { (data, response, error) in

                var responseError = error
                var body: AnyObject?

                if let data = data {
                    do {
                        body = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    } catch let e as NSError {
                        responseError = responseError ?? e
                    }
                }

                if let apiError = self.responseMiddleware?.errorInBody(body) {
                    responseError = apiError
                }

                let httpResponse = response as? NSHTTPURLResponse
                let status = HttpStatusCode(rawValue: httpResponse?.statusCode ?? 418)!
                operation.apiResponse = APIResponse(httpStatus: status, body: body, error: responseError)

                operationCompletion()
            }

            task?.resume()
        }

        operation.cancelTask = {
            task?.cancel()
        }

        return operation
    }

    private func request(method method: HttpMethod, towards endpoint: String, body: AnyObject?) -> NSMutableURLRequest {
        let url = NSURL(string: (HttpClient.debugHost ?? host) + endpoint)
        let request = NSMutableURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 20.0)

        request.HTTPMethod = method.rawValue

        if let body = body, data = try? NSJSONSerialization.dataWithJSONObject(body, options: []) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = data
        }

        requestSetup?(request: request)

        return request
    }
}

extension HttpClient: APIClient {

    func get(endpoint: String) -> APIOperation {
        let req = request(method: .GET, towards: endpoint, body: nil)
        return send(request: req)
    }

    func post(endpoint: String, body: [String : AnyObject]) -> APIOperation {
        let req = request(method: .POST, towards: endpoint, body: body)
        return send(request: req)
    }

    func put(endpoint: String, body: [String : AnyObject]) -> APIOperation {
        let req = request(method: .PUT, towards: endpoint, body: body)
        return send(request: req)
    }

    func delete(endpoint: String) -> APIOperation {
        let req = request(method: .DELETE, towards: endpoint, body: nil)
        return send(request: req)
    }
}
