//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

struct LandetTableCellIdentifier {

    static let Comment = LandetTableCellIdentifier("CommentCell")
    static let TextField = LandetTableCellIdentifier("TextFieldCell")
    static let Spinner = LandetTableCellIdentifier("SpinnerCell")

    private let string: String

    init(_ identifier: String) {
        self.string = identifier
    }
}


class LandetTableViewStyle {

    static func setup(tableView: UITableView, cells: [LandetTableCellIdentifier]) {
        tableView.backgroundColor = Colors.black
        tableView.separatorColor = Colors.gray

        if tableView.style == .Grouped {
            // avoid the 35pt top and bottom margin in grouped table views
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: CGFloat.min))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: CGFloat.min))
        } else if tableView.style == .Plain {
            // hide separators between unused cells
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }

        cells.forEach { identifier in
            tableView.registerNib(UINib(nibName: identifier.string, bundle: nil), forCellReuseIdentifier: identifier.string)
        }
    }
}

extension UITableView {

    func dequeueLandetCell<T: UITableViewCell>(identifier: LandetTableCellIdentifier, forIndexPath indexPath: NSIndexPath) -> T  {
        return self.dequeueReusableCellWithIdentifier(identifier.string, forIndexPath: indexPath) as! T
    }
}
