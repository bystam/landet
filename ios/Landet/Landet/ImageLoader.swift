//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class ImageLoader {

    static let cache = NSCache()

    static func loadImage(url: NSURL, completion: (image: UIImage?) -> Void) {
        if let cachedImage = cache.objectForKey(url) as? UIImage {
            completion(image: cachedImage)
            return
        }

        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, res, error) in

            if let data = data where data.length > 0 {
                let image = UIImage(data: data)

                Async.main {

                    if let image = image {
                        cache.setObject(image, forKey: url)
                    }

                    completion(image: image)
                }
            }
        }

        task.resume()
    }
}