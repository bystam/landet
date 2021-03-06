//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    private var tableViewController: CreateEventTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableViewController.nameTextField.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        [ tableViewController.nameTextField,
          tableViewController.timeField,
          tableViewController.locationField,
          tableViewController.bodyTextView ].forEach({ $0.resignFirstResponder() })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! CreateEventTableViewController
        }
    }

    @IBAction func createButtonPressed(sender: AnyObject) {
        guard let title = tableViewController.nameTextField.text else { return }
        guard let time = tableViewController.time else { return }
        guard let location = tableViewController.location else { return }
        guard let body = tableViewController.bodyTextView.text else { return }

        EventAPI.shared.create(title: title, body: body, location: location, time: time) { (error) in
            if let error = error {
                print(error)
            } else {
                Async.main {
                    self.performSegueWithIdentifier("unwindToEvents", sender: self)
                }
            }
        }
    }
}

extension CreateEventViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tableViewController.nameTextField {
            tableViewController.timeField.becomeFirstResponder()
        }

        return false
    }
}