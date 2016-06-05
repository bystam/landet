//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

enum LocationID: String {
    case SAUNA, HOUSE
}

class Location {

    let id: Int
    let locationId: LocationID
    let name: String
    let imageUrl: NSURL

    init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.locationId = LocationID(rawValue: dictionary["enum_id"] as! String)!
        self.name = dictionary["name"] as! String
        self.imageUrl = NSURL(string: dictionary["image_url"] as! String)!
    }
}