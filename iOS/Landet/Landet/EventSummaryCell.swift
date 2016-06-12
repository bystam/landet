//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

class EventSummaryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAndLocationLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    func configure(event event: Event) {
        titleLabel.text = event.title

        let time = formatter.stringFromDate(event.time)
        timeAndLocationLabel.text = "\(time) at \(event.location.name)"

        creatorLabel.text = "by \(event.creator.name)"

        bodyLabel.text = event.body
    }
}
