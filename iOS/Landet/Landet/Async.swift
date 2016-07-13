//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

class Async {

    static func main(delay: NSTimeInterval? = nil, closure: dispatch_block_t) {
        if let delay = delay {
            dispatch_after(toDispatchTime(delay), dispatch_get_main_queue(), closure)
        } else {
            dispatch_async(dispatch_get_main_queue(), closure)
        }
    }

    private static func toDispatchTime(delay: NSTimeInterval) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    }

}

class Sync {

    static func main(closure: dispatch_block_t) {
        dispatch_sync(dispatch_get_main_queue(), closure)
    }
}