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

class CommentCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    func configure(eventComment comment: EventComment) {
        userLabel.text = comment.author.name
        timestampLabel.text = formatter.stringFromDate(comment.timestamp)
        commentLabel.text = comment.text
    }

    func configure(topicComment comment: TopicComment) {
        userLabel.text = comment.author.name
        timestampLabel.text = formatter.stringFromDate(comment.timestamp)
        commentLabel.text = comment.text
    }
}
