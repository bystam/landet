//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class User: DictionaryInitializable {

    let id: Int
    let username: String
    let name: String

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.username = dictionary["username"] as! String
        self.name = dictionary["name"] as! String
    }
}