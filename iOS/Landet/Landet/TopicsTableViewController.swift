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

    private var comments: [TopicComment] {
        guard let topic = topicsRepository.currentTopic else { return [] }
        return topicsRepository.commentsRepository.comments[topic.id] ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.Comment])

        topicsRepository.commentsRepository.delegate = self
    }
}

extension TopicsTableViewController: TopicCommentsRepositoryDelegate {

    func repository(repository: TopicCommentsRepository, loadedNewCommentsInRange range: Range<Int>) {
        tableView.beginUpdates()
        let newCommentIndexPaths = range.map({ NSIndexPath(forRow: $0, inSection: 0) })
        tableView.insertRowsAtIndexPaths(newCommentIndexPaths, withRowAnimation: .Automatic)
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

extension TopicsTableViewController { // UITableViewDataSource, UITableViewDelegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentCell = tableView.dequeueLandetCell(.Comment, forIndexPath: indexPath)
        cell.configure(topicComment: comments[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
