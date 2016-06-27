//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

enum LandetCollectionCellIdentifier: String {
    case Spinner = "SpinnerCollectionViewCell"
    case TopicHeader = "TopicsHeaderCollectionViewCell"
}

class LandetCollectionViewStyle {

    static func setup(collectionView: UICollectionView, cells: [LandetCollectionCellIdentifier]) {
        collectionView.backgroundColor = Colors.black

        cells.forEach { identifier in
            collectionView.registerNib(UINib(nibName: identifier.rawValue, bundle: nil), forCellWithReuseIdentifier: identifier.rawValue)
        }
    }
}

extension UICollectionView {

    func dequeueLandetCell<T: UICollectionViewCell>(identifier: LandetCollectionCellIdentifier, forIndexPath indexPath: NSIndexPath) -> T  {
        return self.dequeueReusableCellWithReuseIdentifier(identifier.rawValue, forIndexPath: indexPath) as! T
    }
}
