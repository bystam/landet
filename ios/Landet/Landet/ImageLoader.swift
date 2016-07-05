//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class ImageLoader {

    static func loadImage(url: NSURL, completion: (image: UIImage?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, res, error) in

            if let data = data where data.length > 0 {
                let image = UIImage(data: data)

                Async.main {
                    completion(image: image)
                }
            }
        }

        task.resume()
    }
}