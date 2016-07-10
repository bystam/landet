//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

public final class KeyboardObserver {

    public var keyboardWillShow: ((keyboardSize: CGSize) -> ())?
    public var keyboardDidShow: ((keyboardSize: CGSize) -> ())?

    public var keyboardWillHide: (() -> ())?
    public var keyboardDidHide: (() -> ())?

    public var enabled = true

    public init() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillShow(_:)),
                                       name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardDidShow(_:)),
                                       name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillHide(_:)),
                                       name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(KeyboardObserver.keyboardDidHide(_:)),
                                       name: UIKeyboardDidHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if !enabled { return }

        let frameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardWillShow?(keyboardSize: frameValue.CGRectValue().size)
    }

    @objc private func keyboardDidShow(notification: NSNotification) {
        if !enabled { return }

        let frameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardDidShow?(keyboardSize: frameValue.CGRectValue().size)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if !enabled { return }

        keyboardWillHide?()
    }

    @objc private func keyboardDidHide(notification: NSNotification) {
        if !enabled { return }

        keyboardDidHide?()
    }
}
