//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

let kSessionEstablishedNotification = "kSessionEstablishedNotification"
let kSessionLostNotification = "kSessionLostNotification"

class Session {

    private(set) static var currentSession: Session?

    private(set) var token: String
    let refreshToken: String

    init(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
    }

    func renew(token token: String) {
        self.token = token
        Credentials.token = token
    }

    static func installDefault() {
        if let token = Credentials.token, refreshToken = Credentials.refreshToken {
            currentSession = Session(token: token, refreshToken: refreshToken)
            NSNotificationCenter.defaultCenter().postNotificationName(kSessionEstablishedNotification, object: nil)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kSessionLostNotification, object: nil)
        }
    }

    static func installWith(token token: String, refreshToken: String) {
        Credentials.token = token
        Credentials.refreshToken = refreshToken
        currentSession = Session(token: token, refreshToken: refreshToken)
        NSNotificationCenter.defaultCenter().postNotificationName(kSessionEstablishedNotification, object: nil)
    }

    static func uninstallCurrentSession() {
        Credentials.token = nil
        Credentials.refreshToken = nil
        currentSession = nil
        NSNotificationCenter.defaultCenter().postNotificationName(kSessionLostNotification, object: nil)
    }

}


private class Credentials {

    static var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Credentials.token") as? String
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: "Credentials.token")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    static var refreshToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Credentials.refreshToken") as? String
        }
        set(newRefreshToken) {
            NSUserDefaults.standardUserDefaults().setObject(newRefreshToken, forKey: "Credentials.refreshToken")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
