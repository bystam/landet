//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsHeaderCollectionViewController: UICollectionViewController {


}

extension TopicsHeaderCollectionViewController {

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(TopicsHeaderCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }
}
