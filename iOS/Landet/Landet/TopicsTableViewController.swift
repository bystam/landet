//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

protocol TopicsTableViewControllerScrollDelegate: class {
    func topicsTableViewController(tableViewController: TopicsTableViewController,
                                   didScrollToOffset offset: CGPoint)
}

class TopicsTableViewController: UITableViewController {

    weak var scrollDelegate: TopicsTableViewControllerScrollDelegate?

    var topicsRepository: TopicsRepository!

    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.Comment, .Spinner])

        tableView.estimatedRowHeight = 62
        tableView.rowHeight = UITableViewAutomaticDimension

        topicsRepository.commentsRepository.delegate = self
    }
}

extension TopicsTableViewController: TopicCommentsRepositoryDelegate {

    func repository(repository: TopicCommentsRepository, didChangeToTopic topic: Topic) {
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 2)), withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    func repository(repository: TopicCommentsRepository, loadedNewCommentsInRange range: Range<Int>) {
        tableView.beginUpdates()
        let newCommentIndexPaths = range.map({ NSIndexPath(forRow: $0, inSection: 0) })
        tableView.insertRowsAtIndexPaths(newCommentIndexPaths, withRowAnimation: .Automatic)
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        tableView.endUpdates()

    }
    func repositoryLoadedComments(repository: TopicCommentsRepository) {
        tableView.reloadData()
    }
}

extension TopicsTableViewController { // UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollDelegate?.topicsTableViewController(self, didScrollToOffset: scrollView.contentOffset)
    }
}

extension TopicsTableViewController { // UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return topicsRepository.commentsRepository.canLoadMore ? 1 : 0 }
        return topicsRepository.commentsRepository.comments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell: SpinnerCell = tableView.dequeueLandetCell(.Spinner, forIndexPath: indexPath)
            cell.spin()
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            return cell
        }

        let cell: CommentCell = tableView.dequeueLandetCell(.Comment, forIndexPath: indexPath)
        cell.configure(topicComment: topicsRepository.commentsRepository.comments[indexPath.row])
        return cell
    }

}

extension TopicsTableViewController { // UITableViewDelegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            topicsRepository.commentsRepository.loadNextPage()
        }
    }
}
