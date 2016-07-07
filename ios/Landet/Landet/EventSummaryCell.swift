//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEEE HH:mm"
    return formatter
}()

class EventSummaryCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAndLocationLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    static let preferredHeight: CGFloat = 93.0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(event event: Event) {
        titleLabel.text = event.title

        let time = formatter.stringFromDate(event.time)
        timeAndLocationLabel.text = "\(time) at \(event.location.name)"

        creatorLabel.text = "by \(event.creator.name)"

        bodyLabel.text = event.body
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cardView.backgroundColor = selected ? Colors.brown : Colors.gray
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        cardView.backgroundColor = highlighted ? Colors.brown : Colors.gray
    }
}
