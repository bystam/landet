//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerSpaceToBottom: NSLayoutConstraint!
    @IBOutlet weak var logoSpaceToUsername: NSLayoutConstraint!
    @IBOutlet weak var passwordCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var displayNameContainer: UIView!
    @IBOutlet weak var displayNameTextField: LandetTextField!

    @IBOutlet weak var usernameTextField: LandetTextField!
    @IBOutlet weak var passwordTextField: LandetTextField!

    @IBOutlet weak var submitButton: RoundRectButton!
    @IBOutlet weak var signupButton: RoundRectButton!

    @IBOutlet weak var goBackFromSignupButton: UIButton!

    @IBOutlet weak var errorLabel: UILabel!

    private var isSignupMode = false

    static func create() -> LoginViewController {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0.0

        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        listenToKeyboard()

        displayNameContainer.alpha = 0.0
        goBackFromSignupButton.alpha = 0.0

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
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

    @IBAction func signupButtonPressed(sender: AnyObject) {
        isSignupMode = true

        submitButton.setTitle("Sign up", forState: .Normal)

        UIView.animateWithDuration(0.3) {
            self.signupButton.alpha = 0.0
            self.displayNameContainer.alpha = 1.0
            self.goBackFromSignupButton.alpha = 1.0
            self.logoSpaceToUsername.constant = 90
            self.passwordCenterConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func goBackFromSignupButtonPressed(sender: AnyObject) {
        isSignupMode = false

        submitButton.setTitle("Login", forState: .Normal)

        UIView.animateWithDuration(0.3) {
            self.signupButton.alpha = 1.0
            self.displayNameContainer.alpha = 0.0
            self.goBackFromSignupButton.alpha = 0.0
            self.logoSpaceToUsername.constant = 60
            self.passwordCenterConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
    }

    @objc private func closeKeyboard() {
        displayNameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        if isSignupMode {
            attemptSignup()
        } else {
            attemptLogin()
        }
    }

    private func attemptSignup() {
        guard let name = displayNameTextField.text where !name.isEmpty,
              let username = usernameTextField.text where !username.isEmpty,
              let password = passwordTextField.text where !password.isEmpty else {
            self.displayError(message: "Missing name, username or password")
            return
        }

        closeKeyboard()
        displayError(nil)

        UserAPI.shared.signup(displayName: name, username: username, password: password) { (error) in
            if let error = error {
                Async.main { self.displayError(error) }
                return
            }

            UserAPI.shared.login(username: username, password: password, completion: { (error) in
                if let error = error {
                    self.displayError(error)
                }
            })
        }
    }

    private func attemptLogin() {
        guard let username = usernameTextField.text where !username.isEmpty,
              let password = passwordTextField.text where !password.isEmpty else {
            self.displayError(message: "Missing username or password")
            return
        }

        closeKeyboard()
        displayError(nil)

        UserAPI.shared.login(username: username, password: password) { (error) in

            Async.main {
                if let error = error {
                    self.displayError(error)
                }
            }
        }
    }

    private func displayError(error: NSError? = nil, message: String? = nil) {
        let text = error?.localizedDescription ?? message

        self.errorLabel.text = text
        self.errorLabel.sizeToFit()

        UIView.animateWithDuration(0.3) {
            self.errorLabel.alpha = text != nil ? 1.0 : 0.0
        }
    }
}


extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == displayNameTextField {
            usernameTextField.becomeFirstResponder()
        }
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            attemptLogin()
        }

        return true
    }
}
