//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

func APIClientFactory(withAuthHeader authHeader: Bool = false) -> HttpClient {
    let client = HttpClient(host: "http://landet.herokuapp.com",
                            responseMiddleware: LandetAPIErrorMiddleware())
    if authHeader {
        client.requestSetup = { request in
            if let token = Session.currentSession?.token {
                request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
            }
        }
    }
    return client
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

    func signup(displayName name: String, username: String, password: String, completion: (error: NSError?) -> ()) {

        let body = [
            "name" : name,
            "username" : username,
            "password" : password
        ]
        let operation = apiClient.post("/users/create", body: body)

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
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

class TopicAPI {

    static let shared = TopicAPI()

    let apiClient = APIClientFactory(withAuthHeader: true)

    func loadAll(completion: (topics: [Topic]?, error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.get("/topics")
        })

        operation.completionBlock = {
            let res: ([Topic]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(topics: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }

    func create(title title: String, body bodyText: String, location: Location, time: NSDate,
                      completion: (error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let body = [ "title" : title ]
        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/topics/create", body: body)
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }

    func comments(forTopic topic: Topic, before: NSDate?, orAfter after: NSDate?,
                           completion: (comments: [TopicComment]?, hasMore: Bool, error: NSError?) -> ()) {
        guard let _ = Session.currentSession else { return }

        var path = "/topics/\(topic.id)/comments"
        if let before = before {
            path += "?pageBefore=\(before.UTCString)"
        }
        else if let after = after {
            path += "?after=\(after.UTCString)"
        }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.get(path)
        })

        operation.completionBlock = {
            let body = operation.apiResponse.body ?? [:]
            let comments: [TopicComment]? = APIUtil.parseArray(json: body, key: "comments")
            let hasMore = APIUtil.parseBool(json: body, key: "hasMore")

            completion(comments: comments, hasMore: hasMore, error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }

    func post(comment text: String, toTopic topic: Topic,
                      completion: (error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/topics/\(topic.id)/comments/create", body: [ "text" : text ])
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }
        
        apiQueue.addOperation(operation)
    }
}


class EventAPI {

    static let shared = EventAPI()

    let apiClient = APIClientFactory(withAuthHeader: true)

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

    func create(title title: String, body bodyText: String, location: Location, time: NSDate,
                      completion: (error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let body = [
            "title" : title,
            "body" : bodyText,
            "location_id" : location.id,
            "event_time" : time.UTCString
        ]
        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/events/create", body: body as! [String : AnyObject])
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }

    func comments(forEvent event: Event, completion: (comments: [EventComment]?, error: NSError?) -> ()) {
        guard let _ = Session.currentSession else { return }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.get("/events/\(event.id)/comments")
        })

        operation.completionBlock = {
            let res: ([EventComment]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(comments: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }

    func post(comment text: String, toEvent event: Event,
                      completion: (error: NSError?) -> ()) {

        guard let _ = Session.currentSession else { return }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/events/\(event.id)/comments/create", body: [ "text" : text ])
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
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

