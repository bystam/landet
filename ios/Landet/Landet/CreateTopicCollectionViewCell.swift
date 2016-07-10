//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var highlighted: Bool {
        didSet {
            label.textColor = highlighted ? Colors.yellow : Colors.red
        }
    }
}
