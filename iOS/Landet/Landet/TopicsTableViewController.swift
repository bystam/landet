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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 15
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
