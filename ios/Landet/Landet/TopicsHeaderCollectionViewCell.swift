//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsHeaderCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier: String = "TopicsHeaderCollectionViewCell"

    @IBOutlet weak var titleLabel: UILabel!

    func configure(topic topic: Topic) {
        titleLabel.text = topic.title
    }
}
