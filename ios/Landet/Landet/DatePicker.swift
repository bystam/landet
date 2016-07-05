//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

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

class DatePicker: NSObject {

    weak var timeField: UITextField!

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

    init(timeField: UITextField) {
        super.init()
        self.timeField = timeField
        timeField.inputView = picker
        timeField.text = formatter.stringFromDate(picker.date)

        let line = UIView()
        line.backgroundColor = Colors.yellow.colorWithAlphaComponent(0.3)
        line.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        timeField.inputAccessoryView = line
    }


    func dateChanged(sender: UIDatePicker) {
        self.timeField.text = formatter.stringFromDate(sender.date)
    }
}
