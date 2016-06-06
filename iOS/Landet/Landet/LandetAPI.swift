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
        let operation = apiClient.post("/users/login", body: [ "username" : username, "password" : password ]) { (response) in

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

    func refresh(session: Session, completion: (error: NSError?) -> ()) {
        let operation = apiClient.post("/sessions/refresh", body: [ "refresh_token" : session.refreshToken ]) { (response) in

            if let error = response.error {
                completion(error: error);
                return
            }


            let sessionData = response.body as! [String : String]
            let token = sessionData["token"]!

            session.renew(token: token)
            completion(error: nil)
        }

        apiQueue.addOperation(operation)
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
        let operation = apiClient.get("/events") { (response) in

            if let error = response.error {
                completion(events: nil, error: error);
                return
            }

            let eventData = response.body as! [[String : AnyObject]]
            let events = eventData.map { Event(dictionary: $0) }

            completion(events: events, error: nil)
        }

        apiQueue.addOperation(operation)
    }

}
