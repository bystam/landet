//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LandetTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()

        let color = Colors.yellow
        textColor = color

        keyboardAppearance = .Dark

        if let placeholder = placeholder {
            let attributes = [ NSForegroundColorAttributeName : color.colorWithAlphaComponent(0.3) ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
}
