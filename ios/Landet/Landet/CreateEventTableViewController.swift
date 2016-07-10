//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateEventTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: LandetTextField!

    @IBOutlet weak var timeField: LandetTextField!
    @IBOutlet weak var timeLabel: UILabel!
    private var fromDatePicker: DatePicker!
    var time: NSDate? { return fromDatePicker.picker.date }

    @IBOutlet weak var locationField: LandetTextField!
    @IBOutlet weak var locationLabel: UILabel!
    private var locationPicker: LocationPicker!
    var location: Location? { return locationPicker.selectedLocation }


    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyPlaceholder: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        fromDatePicker = DatePicker(timeField: timeField)
        locationPicker = LocationPicker(locationField: locationField)

        self.tableView.tableFooterView = UIView()

        timeField.keyboardAppearance = .Default

        bodyTextView.textContainerInset = UIEdgeInsetsZero
        bodyPlaceholder.textContainerInset = UIEdgeInsetsZero
        bodyTextView.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    @IBAction func locationPictureButtonPressed(sender: AnyObject) {
        guard let location = location else { return }
        presentViewController(LocationDetailsViewController.fromStoryboard(location: location),
                              animated: true, completion: nil)
    }
}

extension CreateEventTableViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        bodyPlaceholder.hidden = !textView.text.isEmpty
    }
}

