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

private func SessionMissingError() -> NSError {
    return NSError(domain: "LandetDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey : "Session missing!" ])
}


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
        let operation = apiClient.post("/users", body: body)

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }
}

private typealias PendingOperation =
    (generator: () -> APIOperation, total: APIOperation, completion: () -> ())

// this is an absolute mess, but I couldn't figure out how to do it in a better way :(
private class SessionAPI {

    static let shared = SessionAPI()

    let apiClient: APIClient = APIClientFactory()

    private var refreshRunning = false
    private var pendingOperations: [PendingOperation] = []

    func wrapWithAutomaticRefreshingSession(operation generator: () -> APIOperation) -> APIOperation {

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


                // critical zone, try only to run a single refresh operation at once
                // save the state of this operation together with completion handlers
                var performRefresh = false
                Sync.main {
                    let pending = (
                        generator: generator,
                        total: totalOperation,
                        completion: totalOperationCompletion
                    )

                    self.pendingOperations.append(pending)

                    if !self.refreshRunning {
                        self.refreshRunning = true
                        performRefresh = true
                    }
                }

                if !performRefresh {
                    return
                }


                self.refreshSession(session)
            }
        }

        return totalOperation
    }

    private func refreshSession(session: Session) {
        let refreshOp = self.apiClient.post("/sessions/refresh", body: [ "refresh_token" : session.refreshToken])
        apiQueue.addOperation(refreshOp)

        refreshOp.completionBlock = {

            // critical zone, de-queue all pending operations and flag us as
            // not currently refreshing
            var pending: [PendingOperation] = []
            Sync.main {
                pending = self.pendingOperations
                self.refreshRunning = false
                self.pendingOperations.removeAll()
            }

            let refreshResponse = refreshOp.apiResponse


            if refreshResponse.error?.landetErrorCode == .InvalidRefreshToken {
                // the refresh failed, uninstall the session and finish all pending operations
                Session.uninstallCurrentSession()

                for p in pending {
                    p.total.apiResponse = refreshResponse
                    p.completion()
                }

            } else {
                // the refresh was successful, generate all pending operations
                // and run their corresponding completion handlers

                guard let token = (refreshResponse.body as? [String : String])?["token"] else { return }
                session.renew(token: token)

                for p in pending {
                    let pendingOp = p.generator()
                    apiQueue.addOperation(pendingOp)
                    pendingOp.completionBlock = {

                        p.total.apiResponse = pendingOp.apiResponse
                        p.completion()
                    }
                }
            }
        }
    }
}

class TopicAPI {

    static let shared = TopicAPI()

    let apiClient = APIClientFactory(withAuthHeader: true)

    func loadAll(completion: (topics: [Topic]?, error: NSError?) -> ()) {

        guard let _ = Session.currentSession else {
            completion(topics: nil, error: SessionMissingError())
            return
        }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.get("/topics")
        })

        operation.completionBlock = {
            let res: ([Topic]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(topics: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }

    func create(title title: String, completion: (error: NSError?) -> ()) {

        guard let _ = Session.currentSession else {
            completion(error: SessionMissingError())
            return
        }

        let body = [ "title" : title ]
        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/topics", body: body)
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }

    func comments(forTopic topic: Topic, before: NSDate?, orAfter after: NSDate?,
                           completion: (comments: [TopicComment]?, hasMore: Bool, error: NSError?) -> ()) {

        guard let _ = Session.currentSession else {
            completion(comments: nil, hasMore: false, error: SessionMissingError())
            return
        }

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

        guard let _ = Session.currentSession else {
            completion(error: SessionMissingError())
            return
        }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/topics/\(topic.id)/comments", body: [ "text" : text ])
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

        guard let _ = Session.currentSession else {
            completion(events: nil, error: SessionMissingError())
            return
        }

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

        guard let _ = Session.currentSession else {
            completion(error: SessionMissingError())
            return
        }

        let body = [
            "title" : title,
            "body" : bodyText,
            "location_id" : location.id,
            "event_time" : time.UTCString
        ]
        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/events", body: body as! [String : AnyObject])
        })

        operation.completionBlock = {
            completion(error: operation.apiResponse.error)
        }

        apiQueue.addOperation(operation)
    }

    func comments(forEvent event: Event, completion: (comments: [EventComment]?, error: NSError?) -> ()) {

        guard let _ = Session.currentSession else {
            completion(comments: nil, error: SessionMissingError())
            return
        }

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

        guard let _ = Session.currentSession else {
            completion(error: SessionMissingError())
            return
        }

        let operation = SessionAPI.shared.wrapWithAutomaticRefreshingSession(operation:  {
            return self.apiClient.post("/events/\(event.id)/comments", body: [ "text" : text ])
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

        let operation = apiClient.get("/locations/")

        operation.completionBlock = {
            let res: ([Location]?, NSError?) = APIUtil.parseAsArray(response: operation.apiResponse)
            completion(locations: res.0, error: res.1)
        }

        apiQueue.addOperation(operation)
    }

    func loadAll(completion: (imageUrl: String?, locations: [MapLocation]?, error: NSError?) -> ()) {

        let operation = apiClient.get("/map_content.json")

        operation.completionBlock = {
            guard let body = operation.apiResponse.body else {
                completion(imageUrl: nil, locations: nil, error: operation.apiResponse.error)
                return
            }

            let imageUrl = (body as? [String : AnyObject])?["url"] as? String
            let locations: [MapLocation]? = APIUtil.parseArray(json: body, key: "locations")

            completion(imageUrl: imageUrl, locations: locations, error: nil)
        }

        apiQueue.addOperation(operation)
    }
}

