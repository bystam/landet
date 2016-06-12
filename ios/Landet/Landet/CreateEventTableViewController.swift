//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateEventTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: LandetTextField!

    @IBOutlet weak var fromTimeField: LandetTextField!
    @IBOutlet weak var fromLabel: UILabel!
    private var fromDatePicker: DatePicker!
    @IBOutlet weak var toTimeField: LandetTextField!
    @IBOutlet weak var toLabel: UILabel!
    private var toDatePicker: DatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTimePickers()

        self.tableView.tableFooterView = UIView()
    }

    private func setupTimePickers() {
        fromDatePicker = DatePicker(timeField: fromTimeField, label: fromLabel)
        toDatePicker = DatePicker(timeField: toTimeField, label: toLabel)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
}


private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

private class DatePicker {

    weak var timeField: UITextField!
    weak var label: UILabel!

    var earliestDate: (() -> NSDate?)?

    lazy var picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .DateAndTime
        picker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: .ValueChanged)
        return picker
    }()

    init(timeField: UITextField, label: UILabel) {
        self.timeField = timeField
        timeField.inputView = picker
        self.label = label

        label.alpha = 0.0
        label.transform = CGAffineTransformMakeTranslation(0, 20)
    }

    @objc func dateChanged(sender: UIDatePicker) {
        self.timeField.text = dateFormatter.stringFromDate(sender.date)

        if label.alpha == 0.0 {
            UIView.animateWithDuration(0.3, animations: {
                self.label.alpha = 1.0
                self.label.transform = CGAffineTransformIdentity
            })
        }
    }

}
