//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class Topic: DictionaryInitializable {

    let id: Int
    let title: String

    let author: User

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.title = dictionary["title"] as! String
        
        self.author = User(dictionary: dictionary["author"] as! [String : AnyObject])
    }

}

class TopicComment: DictionaryInitializable {

    let id: Int
    let text: String
    let timestamp: NSDate

    let author: User

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.text = dictionary["text"] as! String
        self.timestamp = NSDate.fromUTCString(dictionary["comment_time"] as! String)!

        self.author = User(dictionary: dictionary["author"] as! [String : AnyObject])
    }
}
