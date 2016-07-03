//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

protocol DictionaryInitializable {
    init(dictionary: [String : AnyObject])
}

class APIUtil {

    static func parse<T: DictionaryInitializable>(response response: APIResponse)
        -> (objects: T?, error: NSError?) {

            var object: T?
            var error: NSError?

            if let apiError = response.error {
                error = apiError
            }
            else if let objectData = response.body as? [String : AnyObject] {
                object = T(dictionary: objectData)
            }
            
            return (object, error)
    }

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

    static func parseArray<T: DictionaryInitializable>(json json: AnyObject, key: String) -> [T]? {
        guard let json = json as? [String : AnyObject] else { return nil }
        guard let array = json[key] as? [[String : AnyObject]] else { return nil }

        return array.map(T.init)
    }

    static func parseBool(json json: AnyObject, key: String) -> Bool {
        guard let json = json as? [String : AnyObject] else { return false }
        return (json[key] as? Bool) ?? false
    }
}
