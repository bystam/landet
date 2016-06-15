//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class EventComment: DictionaryInitializable {

    let id: Int
    let text: String
    let timestamp: NSDate

    let author: User

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.text = dictionary["text"] as! String
        self.timestamp = NSDate.fromISOString(dictionary["comment_time"] as! String)!

        self.author = User(dictionary: dictionary["author"] as! [String : AnyObject])
    }
}
