//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

enum LandetAPIErrorCode: String {
    case UsernameTaken = "LE-101"
    case WrongCredentials = "LE-102"

    case TokenInvalid = "LE-201"
    case TokenExpired = "LE-202"
    case InvalidRefreshToken = "LE-203"
};

let LandetAPIErrorDomain = "kLandetAPIErrorDomain"
private let LandetAPIErrorCodeKey = "LandetAPIErrorCodeKey"

class LandetAPIErrorMiddleware: APIResponseMiddleware {

    func errorInBody(body: AnyObject?) -> NSError? {
        guard let body = body as? [String : AnyObject] else { return nil }
        guard let errorData = body["landet_error"] else { return nil }

        let userInfo = [
            NSLocalizedDescriptionKey : errorData["message"] as! String,
            LandetAPIErrorCodeKey : errorData["api_code"] as! String
        ]
        return NSError(domain: LandetAPIErrorDomain, code: 4711, userInfo: userInfo)
    }
}

extension NSError {
    var landetErrorCode: LandetAPIErrorCode? {
        guard let code = userInfo[LandetAPIErrorCodeKey] as? String else { return nil }
        return LandetAPIErrorCode(rawValue: code)
    }
}