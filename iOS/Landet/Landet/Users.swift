//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class User {

    let id: Int
    let username: String
    let name: String

    init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.username = dictionary["username"] as! String
        self.name = dictionary["name"] as! String
    }
}