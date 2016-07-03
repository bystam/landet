//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsHeaderViewController: UIViewController {

    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: itemWidth, height: 249)
        }
    }

    lazy var defaultHeight: CGFloat = { return self.collectionView.bounds.height }()
    let minHeight: CGFloat = 60
    let itemWidth = UIScreen.mainScreen().bounds.width

    var topicsRepository: TopicsRepository!

    override func viewDidLoad() {
        super.viewDidLoad()
        LandetCollectionViewStyle.setup(collectionView, cells: [.TopicHeader, .Spinner])

        collectionView.dataSource = self
        collectionView.delegate = self

        topicsRepository.delegate = self

        currentTopicLabel.alpha = 0.0
    }
}

// Public
extension TopicsHeaderViewController {

    func respondToHeight(height: CGFloat) {
        let shrink = max(defaultHeight - height, CGFloat(0))
        collectionView.alpha = 1.0 - (shrink / 80)

        currentTopicLabel.alpha = 1.0 - ((height - minHeight) / 80)
    }
}

extension TopicsHeaderViewController: TopicsRepositoryDelegate {

    func repositoryLoadedTopics(repository: TopicsRepository) {
        collectionView.reloadData()
        repository.currentTopic = repository.topics.first

    }

    func repositoryChangedTopic(repository: TopicsRepository) {
        currentTopicLabel.text = repository.currentTopic?.title
    }
}

extension TopicsHeaderViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsRepository.topics.isEmpty ? 1 : topicsRepository.topics.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if topicsRepository.topics.isEmpty {
            let cell: SpinnerCollectionViewCell = collectionView.dequeueLandetCell(.Spinner, forIndexPath: indexPath)
            cell.spin()
            return cell
        }
        let cell: TopicsHeaderCollectionViewCell = collectionView.dequeueLandetCell(.TopicHeader, forIndexPath: indexPath)
        cell.configure(topic: topicsRepository.topics[indexPath.item])
        return cell
    }
}


extension TopicsHeaderViewController: UICollectionViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetMiddle = collectionView.contentOffset.x + itemWidth/2
        let index = Int(offsetMiddle / itemWidth)
        guard index >= 0 && index < topicsRepository.topics.count else { return }

        topicsRepository.currentTopic = topicsRepository.topics[index]
    }
}
