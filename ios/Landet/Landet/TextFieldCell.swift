//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate: class {
    func textWasEntered(inCell cell: TextFieldCell)
}

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: LandetTextField!

    weak var delegate: TextFieldCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    func configure(placeholder placeholder: String) {
        textField.placeholder = placeholder
    }

}

extension TextFieldCell: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text where !text.isEmpty {
            delegate?.textWasEntered(inCell: self)
        }
        return false
    }
}


private let kSpinnerTag = 0x1231;

extension TextFieldCell {

    func lockWithSpinner() {
        let spinner = UIActivityIndicatorView()
        spinner.alpha = 0.0
        spinner.activityIndicatorViewStyle = .WhiteLarge
        spinner.color = Colors.yellow
        spinner.sizeToFit()
        spinner.tag = kSpinnerTag

        spinner.center = contentView.bounds.center
        contentView.addSubview(spinner)

        spinner.startAnimating()

        self.textField.userInteractionEnabled = false

        UIView.animateWithDuration(0.3) {
            self.textField.alpha = 0.2
            spinner.alpha = 1.0
        }
    }

    func unlock() {
        let spinner = contentView.viewWithTag(kSpinnerTag)

        UIView.animateWithDuration(0.3, animations: { 
            self.textField.alpha = 1.0
            spinner?.alpha = 0.0

        }) { (_) in
            self.textField.userInteractionEnabled = true
            spinner?.removeFromSuperview()
        }
    }

}