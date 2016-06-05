//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

private let kGenericError = NSError(domain: "LandetErrorDomain", code: -666, userInfo: [:])

let kLoginFailedErrorCode = -4712
private let kLoginFailedError = NSError(domain: "LandetErrorDomain", code: kLoginFailedErrorCode,
                                        userInfo: [ NSLocalizedDescriptionKey : "Login failed, try again later" ])

private let apiQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 4
    return queue
}()


class UserAPI {

    static let shared = UserAPI()

    let apiClient: APIClient = HttpClient()

    func login(username username: String, password: String, completion: (error: NSError?) -> ()) {
        let operation = apiClient.post("/users/login", body: [ "username" : username, "password" : password ]) { (response) in
            if let error = response.error {
                completion(error: error);
                return
            }

            guard let sessionData = response.body as? [ String : AnyObject ] else {
                completion(error: kLoginFailedError)
                return
            }

            guard let token = sessionData["token"] as? String, refreshToken = sessionData["refreshToken"] as? String else {
                completion(error: kLoginFailedError)
                return
            }

            
            Session.installWith(token: token, refreshToken: refreshToken)
            completion(error: nil)
        }

        apiQueue.addOperation(operation)
    }
}

private class SessionAPI {

    static let shared = SessionAPI()

    let apiClient: APIClient = HttpClient()

    func refresh(session: Session, completion: (error: NSError?) -> ()) {
        let operation = apiClient.post("/sessions/refresh", body: [ "refresh_token" : session.refreshToken ]) { (response) in
            if let error = response.error {
                completion(error: error);
                return
            }

            guard let sessionData = response.body as? [ String : AnyObject ] else {
                completion(error: kLoginFailedError)
                return
            }

            guard let token = sessionData["token"] as? String else {
                completion(error: kLoginFailedError)
                return
            }

            session.renew(token: token)
            completion(error: nil)
        }

        apiQueue.addOperation(operation)
    }
}

class EventAPI {

    static let shared = EventAPI()

    let apiClient: APIClient = HttpClient()

    func loadAll(completion: (events: [Event]) -> ()) {
        
    }

}