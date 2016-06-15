//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LandetTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()

        textColor = Colors.yellow
        keyboardAppearance = .Dark

        if let placeholder = placeholder {
            let attributes = [
                NSForegroundColorAttributeName : Colors.yellow.colorWithAlphaComponent(0.3)
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }

    override var placeholder: String? {
        didSet {
            guard let placeholder = placeholder else { return }

            let attributes = [
                NSForegroundColorAttributeName : Colors.yellow.colorWithAlphaComponent(0.3)
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
}
