//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleView: RoundRectView!

    private let highlightView = RoundRectView()

    override func awakeFromNib() {
        super.awakeFromNib()
        highlightView.backgroundColor = Colors.red.colorWithAlphaComponent(0.3)

        contentView.addSubview(highlightView)
        highlightView.alpha = 0.0
    }

    override var highlighted: Bool {
        didSet {
            highlightView.frame = circleView.frame
            highlightView.cornerRadius = circleView.cornerRadius
            highlightView.alpha = highlighted && !selected ? 1.0 : 0.0
        }
    }

    func animateTap() {
        UIView.animateWithDuration(0.3, animations: { 
            self.highlightView.alpha = 0.0
        })
    }
}
