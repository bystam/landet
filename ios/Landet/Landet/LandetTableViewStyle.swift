//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

enum LandetCellIdentifier: String {
    case EventSummary = "EventSummaryCell"
    case Comment = "CommentCell"
    case TextField = "TextFieldCell"
    case Spinner = "SpinnerCell"
}

class LandetTableViewStyle {

    static func setup(tableView: UITableView, cells: [LandetCellIdentifier]) {
        tableView.backgroundColor = Colors.black
        tableView.separatorColor = Colors.red

        if tableView.style == .Grouped {
            // avoid the 35pt top and bottom margin in grouped table views
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: CGFloat.min))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: CGFloat.min))
        } else if tableView.style == .Plain {
            // hide separators between unused cells
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }

        cells.forEach { identifier in
            tableView.registerNib(UINib(nibName: identifier.rawValue, bundle: nil), forCellReuseIdentifier: identifier.rawValue)
        }
    }
}

extension UITableView {

    func dequeueLandetCell<T: UITableViewCell>(identifier: LandetCellIdentifier, forIndexPath indexPath: NSIndexPath) -> T  {
        return self.dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath) as! T
    }
}
