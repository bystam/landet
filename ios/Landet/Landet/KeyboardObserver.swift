//
//  Copyright © 2015 Landet. All rights reserved.
//

import UIKit

public final class KeyboardObserver {

    public var keyboardWillShow: ((keyboardSize: CGSize) -> ())?

    public var keyboardWillHide: (() -> ())?

    public var enabled = true

    public init() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if !enabled { return }

        let frameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardWillShow?(keyboardSize: frameValue.CGRectValue().size)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if !enabled { return }

        keyboardWillHide?()
    }
}