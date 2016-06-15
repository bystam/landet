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

    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyPlaceholder: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTimePickers()

        self.tableView.tableFooterView = UIView()

        timeField.keyboardAppearance = .Default

        bodyTextView.textContainerInset = UIEdgeInsetsZero
        bodyPlaceholder.textContainerInset = UIEdgeInsetsZero
        bodyTextView.delegate = self
    }

    private func setupTimePickers() {
        fromDatePicker = DatePicker(timeField: timeField, label: timeLabel)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
}

extension CreateEventTableViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        bodyPlaceholder.hidden = !textView.text.isEmpty
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

private class DatePicker: NSObject {

    weak var timeField: UITextField!
    weak var label: UILabel!

    var earliestDate: (() -> NSDate?)?

    lazy var picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .DateAndTime
        picker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: .ValueChanged)
        picker.minimumDate = parser.dateFromString("2016-07-14 10:00")
        picker.maximumDate = parser.dateFromString("2016-07-17 23:00")

        picker.setValue(Colors.yellow, forKey: "textColor")
        picker.backgroundColor = Colors.gray

        return picker
    }()

    init(timeField: UITextField, label: UILabel) {
        super.init()
        self.timeField = timeField
        timeField.inputView = picker

        let line = UIView()
        line.backgroundColor = Colors.yellow.colorWithAlphaComponent(0.3)
        line.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        timeField.inputAccessoryView = line

        self.label = label

        label.alpha = 0.0
    }


    @objc func dateChanged(sender: UIDatePicker) {
        self.timeField.text = formatter.stringFromDate(sender.date)

        if label.alpha == 0.0 {
            UIView.animateWithDuration(0.3, animations: {
                self.label.alpha = 1.0
            })
        }
    }
}
