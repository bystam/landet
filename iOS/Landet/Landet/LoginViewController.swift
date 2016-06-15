//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerSpaceToBottom: NSLayoutConstraint!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var errorLabel: UILabel!

    static func create() -> LoginViewController {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0.0

        listenToKeyboard()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    let keyboardObserver = KeyboardObserver();

    private func listenToKeyboard() {
        keyboardObserver.keyboardWillShow = { [weak self] size in
            self?.containerSpaceToBottom.constant = size.height
            self?.view.layoutIfNeeded()
        }

        keyboardObserver.keyboardWillHide = { [weak self] size in
            self?.containerSpaceToBottom.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Actions
extension LoginViewController {

    @IBAction func loginButtonPressed(sender: AnyObject) {
        attemptLogin()
    }

    private func attemptLogin() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        UIView.animateWithDuration(0.3) {
            self.errorLabel.alpha = 0.0
        }

        UserAPI.shared.login(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "") { (error) in

            Async.main {
                if let error = error {
                    self.displayError(error)
                } else {
                    self.usernameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                }
            }
        }
    }

    private func displayError(error: NSError) {
        self.errorLabel.text = error.localizedDescription
        self.errorLabel.sizeToFit()

        UIView.animateWithDuration(0.3) {
            self.errorLabel.alpha = 1.0
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            attemptLogin()
        }

        return true
    }
}
