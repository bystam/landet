//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

private let kISOFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.locale = NSLocale.currentLocale()
    return dateFormatter
}()

extension NSDate {

    static func fromISOString(isoString: String) -> NSDate? {
        return kISOFormatter.dateFromString(isoString)
    }
}
