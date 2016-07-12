//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

enum LocationID: String {
    case SAUNA, HOUSE, FRONT_LAWN, BACK_LAWN,
         NEW_GUESTHOUSE, OLD_GUESTHOUSE, TOOLSHED,
         OUTSIDE_TABLEGROUP, LAKE
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

extension Location: Equatable { }

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id && lhs.locationId == rhs.locationId &&
           lhs.name == rhs.name && lhs.imageUrl == rhs.imageUrl
}

extension Location: DictionaryPersistable {

    func asDictionary() -> [String : AnyObject] {
        return [
            "id" : id,
            "enum_id" : locationId.rawValue,
            "name" : name,
            "image_url" : imageUrl.absoluteString
        ]
    }
}


class MapLocation: DictionaryInitializable {

    let locationId: LocationID
    let x: Int
    let y: Int
    let icon: String

    required init(dictionary: [String : AnyObject]) {
        self.locationId = LocationID(rawValue: dictionary["id"] as! String)!
        self.x = dictionary["x"] as! Int
        self.y = dictionary["y"] as! Int
        self.icon = dictionary["icon"] as! String
    }
}


class LocationsService {

    static var locations: [Location] = {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let persisted = defaults.objectForKey("LocationsService.locations") as? [[String : AnyObject]] else {
            return []
        }

        return persisted.map(Location.init)
    }()

    static func fromID(locationId: LocationID) -> Location? {
        for location in locations {
            if location.locationId == locationId {
                return location
            }
        }
        return nil
    }

    static func reload() {

        LocationAPI.shared.loadAll { locations, error in
            Async.main {
                if let locations = locations where !locations.isEmpty && locations != LocationsService.locations {
                    LocationsService.locations = locations
                    LocationsService.persistLocations()
                }
                else if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }

    private static func persistLocations() {
        let dictionaries = locations.map { $0.asDictionary() }
        NSUserDefaults.standardUserDefaults().setObject(dictionaries, forKey: "LocationsService.locations")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

