//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LocationPicker: NSObject {

    weak var locationField: UITextField!

    var selectedLocation: Location? {
        let row = picker.selectedRowInComponent(0)
        guard row < LocationsService.allLocations.count else {
            return nil
        }

        return LocationsService.allLocations[row]
    }

    lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = Colors.gray
        picker.delegate = self
        picker.dataSource = self

        return picker
    }()

    init(locationField: UITextField) {
        super.init()
        self.locationField = locationField
        locationField.inputView = picker
        locationField.keyboardAppearance = .Default
        locationField.text = selectedLocation?.name

        let line = UIView()
        line.backgroundColor = Colors.yellow.colorWithAlphaComponent(0.3)
        line.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        locationField.inputAccessoryView = line
    }
}

extension LocationPicker: UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LocationsService.allLocations.count
    }
}

extension LocationPicker: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: LocationsService.allLocations[row].name,
                                  attributes: [ NSForegroundColorAttributeName : Colors.yellow ])
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationField.text = LocationsService.allLocations[row].name
    }
}
