//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class SpinnerCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SpinnerCollectionViewCell"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func spin() {
        activityIndicator.startAnimating()
    }
}
