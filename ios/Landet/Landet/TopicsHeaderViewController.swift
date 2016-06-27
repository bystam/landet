//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsHeaderViewController: UIViewController {

    var topics = [Topic]() {
        didSet { collectionView.reloadData() }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentTopicLabel: UILabel!

    lazy var defaultHeight: CGFloat = {
        return self.collectionView.bounds.height
    }()
    let minHeight: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        LandetCollectionViewStyle.setup(collectionView, cells: [.TopicHeader, .Spinner])

        collectionView.dataSource = self
    }

    func respondToHeight(height: CGFloat) {
        let shrink = max(defaultHeight - height, CGFloat(0))
        collectionView.alpha = 1.0 - (shrink / 80)

        currentTopicLabel.alpha = 1.0 - ((height - minHeight) / 80)
    }
}

extension TopicsHeaderViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.isEmpty ? 1 : topics.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if topics.isEmpty {
            let cell: SpinnerCollectionViewCell = collectionView.dequeueLandetCell(.Spinner, forIndexPath: indexPath)
            cell.spin()
            return cell
        }
        return collectionView.dequeueLandetCell(.TopicHeader, forIndexPath: indexPath)
    }
}
