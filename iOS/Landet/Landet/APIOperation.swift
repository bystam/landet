//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

struct APIResponse {
    let httpStatus: HttpStatusCode
    let body: AnyObject?
    let error: NSError?
}

class APIOperation: AsyncOperation {

    var apiResponse: APIResponse!

}
