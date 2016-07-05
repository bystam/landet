//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

struct LandetCollectionCellIdentifier {
    static let Spinner = LandetCollectionCellIdentifier("SpinnerCollectionViewCell")
    static let TopicHeader = LandetCollectionCellIdentifier("TopicsHeaderCollectionViewCell")

    private let string: String

    init(_ identifier: String) {
        self.string = identifier
    }
}

class LandetCollectionViewStyle {

    static func setup(collectionView: UICollectionView, cells: [LandetCollectionCellIdentifier]) {
        collectionView.backgroundColor = Colors.black

        cells.forEach { identifier in
            collectionView.registerNib(UINib(nibName: identifier.string, bundle: nil), forCellWithReuseIdentifier: identifier.string)
        }
    }
}

extension UICollectionView {

    func dequeueLandetCell<T: UICollectionViewCell>(identifier: LandetCollectionCellIdentifier, forIndexPath indexPath: NSIndexPath) -> T  {
        return self.dequeueReusableCellWithReuseIdentifier(identifier.string, forIndexPath: indexPath) as! T
    }
}
