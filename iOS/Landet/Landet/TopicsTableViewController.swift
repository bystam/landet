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

    var comments = [TopicComment]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.Comment])
    }
}

extension TopicsTableViewController {

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollDelegate?.topicsTableViewController(self, didScrollToOffset: scrollView.contentOffset)
    }
}

extension TopicsTableViewController {

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
