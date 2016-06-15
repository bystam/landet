//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

func APIClientFactory() -> HttpClient {
    return HttpClient(host: "http://landet.herokuapp.com", responseMiddleware: LandetAPIErrorMiddleware())
}

private let apiQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 4
    return queue
}()


class UserAPI {

    static let shared = UserAPI()

    let apiClient: APIClient = APIClientFactory()

    func login(username username: String, password: String, completion: (error: NSError?) -> ()) {
        let operation = apiClient.post("/users/login", body: [ "username" : username, "password" : password ])

        operation.completionBlock = {
            let response = operation.apiResponse

            if let error = response.error {
                completion(error: error);
                return
            }

            let sessionData = response.body as! [String : String]
            let token = sessionData["token"]!
            let refreshToken = sessionData["refresh_token"]!

            Session.installWith(token: token, refreshToken: refreshToken)
            completion(error: nil)
        }

        apiQueue.addOperation(operation)
    }
}

private class SessionAPI {

    static let shared = SessionAPI()

    let apiClient: APIClient = APIClientFactory()

    func wrapWithAutomaticRefreshingSession(operation generator:  () -> APIOperation) -> APIOperation {

        let session = Session.currentSession!

        let totalOperation = APIOperation()

        totalOperation.asyncTask = { totalOperationCompletion in

            let firstOp = generator()
            apiQueue.addOperation(firstOp)
            firstOp.completionBlock = {

                let firstResponse = firstOp.apiResponse

                if firstResponse.error?.landetErrorCode != .InvalidToken {
                    totalOperation.apiResponse = firstResponse
                    totalOperationCompletion()
                    return
                }


                let refreshOp = self.apiClient.post("/sessions/refresh", body: [ "refresh_token" : session.refreshToken])
                apiQueue.addOperation(refreshOp)

                refreshOp.completionBlock = {

                    let refreshResponse = refreshOp.apiResponse

                    if refreshResponse.error?.landetErrorCode == .InvalidRefreshToken {
                        Session.uninstallCurrentSession()
                        totalOperation.apiResponse = refreshResponse
                        totalOperationCompletion()
                        return
                    }

                    let sessionData = refreshResponse.body as! [String : String]
                    let token = sessionData["token"]!
                    session.renew(token: token)

                    let secondOp = generator()
                    apiQueue.addOperation(secondOp)
                    secondOp.completionBlock = {

                        totalOperation.apiResponse = secondOp.apiResponse
                        totalOperationCompletion()

                    }
                }
            }
        }

        return totalOperation
    }
}

class EventAPI {

    static let shared = EventAPI()

    let apiClient: APIClient = {
        let client = APIClientFactory()
        client.requestSetup = { request in
            if let token = Session.currentSession?.token {
                request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return client
    }()

    func loadAll(completion: (events: [Event]?, error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.get("/events")
        })

        operation.completionBlock = {
            let res: ([Event]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(events: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }
}

class LocationAPI {

    static let shared = LocationAPI()

    let apiClient = APIClientFactory()

    func loadAll(completion: (locations: [Location]?, error: NSError?) -> ()) {

        let operation = apiClient.get("/locations")

        operation.completionBlock = {
            let res: ([Location]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(locations: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }

}

