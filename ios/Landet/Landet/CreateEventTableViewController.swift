//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateEventTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: LandetTextField!

    @IBOutlet weak var fromTimeField: LandetTextField!
    @IBOutlet weak var fromLabel: UILabel!
    private var fromDatePicker: DatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTimePickers()

        self.tableView.tableFooterView = UIView()
    }

    private func setupTimePickers() {
        fromDatePicker = DatePicker(timeField: fromTimeField, label: fromLabel)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
}


private let formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEEE HH:mm"
    formatter.locale = NSLocale.currentLocale()
    return formatter
}()

private let parser: NSDateFormatter = {
    let parser = NSDateFormatter()
    parser.dateFormat = "yyyy-MM-dd HH:mm"
    parser.locale = NSLocale.currentLocale()
    return parser
}()

private class DatePicker {

    weak var timeField: UITextField!
    weak var label: UILabel!

    var earliestDate: (() -> NSDate?)?

    lazy var picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .DateAndTime
        picker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: .ValueChanged)
        picker.minimumDate = parser.dateFromString("2016-07-14 10:00")
        picker.maximumDate = parser.dateFromString("2016-07-17 23:00")
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
        self.timeField.text = formatter.stringFromDate(sender.date)

        if label.alpha == 0.0 {
            UIView.animateWithDuration(0.3, animations: {
                self.label.alpha = 1.0
                self.label.transform = CGAffineTransformIdentity
            })
        }
    }
}
