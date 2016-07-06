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


extension CGPoint {
    var asTranslation: CGAffineTransform {
        return CGAffineTransformMakeTranslation(x, y)
    }
}

func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

func transform(fromRect r1: CGRect, toRect r2: CGRect) -> CGAffineTransform {
    let t = (r2.center - r1.center).asTranslation
    return CGAffineTransformScale(t, r2.size.width/r1.size.width, r2.size.height/r1.size.height)
}