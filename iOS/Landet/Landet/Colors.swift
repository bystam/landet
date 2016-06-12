//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class Colors {

    static let black = UIColor(rgb: 0x252120)
    static let red = UIColor(rgb: 0xA92F41)
    static let yellow = UIColor(rgb: 0xE5DFC5)
    static let brown = UIColor(rgb: 0x848375)
    static let green = UIColor(rgb: 0x91C7A9)
    static let gray = UIColor(rgb: 0x302A29)

}

extension UIColor {

    convenience init(rgb: Int, a: CGFloat = 1.0) {
        let r = CGFloat((rgb >> 16) & 0xFF)
        let g = CGFloat((rgb >> 8) & 0xFF)
        let b = CGFloat((rgb >> 0) & 0xFF)
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

}