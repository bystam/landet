//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

private let kUTCFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return dateFormatter
}()

extension NSDate {

    var UTCString: String { return kUTCFormatter.stringFromDate(self) }

    static func fromUTCString(utcString: String) -> NSDate? {
        return kUTCFormatter.dateFromString(utcString)
    }
}
