//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    private var tableViewController: CreateEventTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! CreateEventTableViewController
        }
    }

    @IBAction func createButtonPressed(sender: AnyObject) {
        guard let title = tableViewController.nameTextField.text else { return }
        guard let time = tableViewController.time else { return }
        guard let sauna = LocationsService.fromID(.SAUNA) else { return }
        guard let body = tableViewController.bodyTextView.text else { return }

        EventAPI.shared.create(title: title, body: body, location: sauna, time: time) { (error) in
            if let error = error {
                print(error)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
