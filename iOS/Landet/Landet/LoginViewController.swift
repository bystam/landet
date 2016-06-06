//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    static func create() -> LoginViewController {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

// MARK: - Actions
extension LoginViewController {

    @IBAction func loginButtonPressed(sender: AnyObject) {
        UserAPI.shared.login(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "") { (error) in
            if let error = error {
                print(error)
            }
        }
    }

}