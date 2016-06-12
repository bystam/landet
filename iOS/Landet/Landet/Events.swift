//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class Event: DictionaryInitializable {

    let id: Int
    let title: String
    let body: String
    let time: NSDate

    let creator: User
    let location: Location

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.title = dictionary["title"] as! String
        self.body = dictionary["body"] as! String
        self.time = NSDate.fromISOString(dictionary["event_time"] as! String)!

        self.creator = User(dictionary: dictionary["creator"] as! [String : AnyObject])
        self.location = Location(dictionary: dictionary["location"] as! [String : AnyObject])
    }

}