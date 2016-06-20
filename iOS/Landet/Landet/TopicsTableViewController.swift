//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class TopicsTableViewController: UITableViewController {

    @IBOutlet var topicsHeaderCell: UITableViewCell!
    @IBOutlet var writeCommentHeader: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {

    }
}

extension TopicsTableViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 15
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return topicsHeaderCell
        } else {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 280 : 60
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? writeCommentHeader : nil
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 84 : 0
    }
}
