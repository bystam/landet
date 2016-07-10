//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let kCreateSection = 0
private let kTopicsSection = 1

protocol TopicsHeaderViewControllerDelegate: class {
    func header(header: TopicsHeaderViewController, startedDisplayingTopic topic: Topic?)
}

class TopicsHeaderViewController: UIViewController {

    @IBOutlet weak var currentTopicLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: itemWidth, height: 249)
        }
    }

    lazy var defaultHeight: CGFloat = { return self.collectionView.bounds.height }()
    let minHeight: CGFloat = 80
    let itemWidth = UIScreen.mainScreen().bounds.width

    weak var headerDelegate: TopicsHeaderViewControllerDelegate?

    var topicsRepository: TopicsRepository!

    override func viewDidLoad() {
        super.viewDidLoad()
        LandetCollectionViewStyle.setup(collectionView, cells: [.TopicHeader, .Spinner, .Create])

        collectionView.dataSource = self
        collectionView.delegate = self

        topicsRepository.delegate = self

        currentTopicLabel.alpha = 0.0

        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: kTopicsSection),
                                               atScrollPosition: .CenteredHorizontally, animated: false)
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

        headerDelegate?.header(self, startedDisplayingTopic: repository.currentTopic)
    }
}

extension TopicsHeaderViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == kCreateSection { return 1 }
        return topicsRepository.topics.isEmpty ? 1 : topicsRepository.topics.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == kCreateSection {
            return collectionView.dequeueLandetCell(.Create, forIndexPath: indexPath)
        }

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

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView .cellForItemAtIndexPath(indexPath) as? CreateTopicCollectionViewCell {
            cell.animateTap()

            let createVC = CreateTopicViewController.create()
            createVC.topicsRepository = topicsRepository
            presentViewController(createVC, animated: true, completion: nil)
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetMiddle = collectionView.contentOffset.x + itemWidth/2
        let index = Int(offsetMiddle / itemWidth)

        if index >= 0 && index < topicsRepository.topics.count {
            topicsRepository.currentTopic = topicsRepository.topics[index]
        } else {
            topicsRepository.currentTopic = nil
        }
    }
}

private extension LandetCollectionCellIdentifier {
    static let TopicHeader = LandetCollectionCellIdentifier("TopicsHeaderCollectionViewCell")
    static let Create = LandetCollectionCellIdentifier("CreateTopicCollectionViewCell")
}
