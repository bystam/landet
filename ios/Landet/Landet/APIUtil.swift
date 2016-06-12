//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

protocol DictionaryInitializable {
    init(dictionary: [String : AnyObject])
}

class APIUtil {

    static func parseAsArray<T: DictionaryInitializable>(response response: APIResponse)
        -> (objects: [T]?, error: NSError?) {

        var objects: [T]?
        var error: NSError?

        if let apiError = response.error {
            error = apiError
        }
        else if let objectData = response.body as? [[String : AnyObject]] {
            objects = objectData.map(T.init)
        }

        return (objects, error)
    }

}
