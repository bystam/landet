//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class Event {

    let id: Int
    let title: String
    let body: String
    let time: NSDate

    let creator: User
    let location: Location

    init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.title = dictionary["title"] as! String
        self.body = dictionary["body"] as! String
        self.time = dictionary["event_time"] as! NSDate

        self.creator = User(dictionary: dictionary["user"] as! [String : AnyObject])
        self.location = Location(dictionary: dictionary["location"] as! [String : AnyObject])
    }

}