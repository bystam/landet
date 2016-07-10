//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

enum LocationID: String {
    case SAUNA, HOUSE
}


class Location: DictionaryInitializable {

    let id: Int
    let locationId: LocationID
    let name: String
    let imageUrl: NSURL

    required init(dictionary: [String : AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.locationId = LocationID(rawValue: dictionary["enum_id"] as! String)!
        self.name = dictionary["name"] as! String
        self.imageUrl = NSURL(string: dictionary["image_url"] as! String)!
    }
}

class MapLocation: DictionaryInitializable {

    let locationId: LocationID
    let x: Int
    let y: Int

    required init(dictionary: [String : AnyObject]) {
        self.locationId = LocationID(rawValue: dictionary["id"] as! String)!
        self.x = dictionary["x"] as! Int
        self.y = dictionary["y"] as! Int
    }
}


private var locations = [Location]()

class LocationsService {

    static var allLocations: [Location] {
        get { return locations }
        set { locations = newValue }
    }


    static func fromID(locationId: LocationID) -> Location? {
        for location in allLocations {
            if location.locationId == locationId {
                return location
            }
        }
        return nil
    }

    static func reload() {

        LocationAPI.shared.loadAll { locations, error in
            if let locations = locations {
                LocationsService.allLocations = locations
            }
            else if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

