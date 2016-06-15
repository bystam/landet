//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

extension CGRect {

    var center: CGPoint {
        get { return CGPoint(x: origin.x + size.width/2, y: origin.y + size.height/2) }
        set(newCenter) { origin = CGPoint(x: newCenter.x - size.width/2, y: newCenter.y - size.height/2) }
    }

}