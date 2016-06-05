//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class Auth {

    static var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Auth.token") as? String
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: "Auth.token")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    static var refreshToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Auth.refreshToken") as? String
        }
        set(newRefreshToken) {
            NSUserDefaults.standardUserDefaults().setObject(newRefreshToken, forKey: "Auth.refreshToken")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

let kSessionLostNotification = "kSessionLostNotification"

struct Session {

    private(set) static var currentSession: Session?

    let token: String

    func installDefault() {
        if let token = Auth.token {
            Session.currentSession = Session(token: token)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kSessionLostNotification, object: nil)
        }
    }

    func installSessionWithToken(token: String) {
        Session.currentSession = Session(token: token)
    }

    func uninstallCurrentSession() {
        Session.currentSession = nil
        NSNotificationCenter.defaultCenter().postNotificationName(kSessionLostNotification, object: nil)
    }

}