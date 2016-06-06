//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventSummaryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    func configure(event event: Event) {
        titleLabel.text = event.title
        bodyLabel.text = event.body
    }

}
