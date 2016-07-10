//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsHeaderCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier: String = "TopicsHeaderCollectionViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circleView: RoundRectView!
    @IBOutlet weak var authorLabel: UILabel!

    func configure(topic topic: Topic) {
        titleLabel.text = topic.title
        authorLabel.text = "- \(topic.author.name)"
    }
}
