//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsTableDataSource: NSObject, UITableViewDataSource {

    let event: Event
    var comments: [EventComment]?

    var postingComment = false

    init(event: Event) {
        self.event = event
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return comments?.count ?? 0 }
        if section == 2 { return 1 }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: EventDetailsCell = tableView.dequeueLandetCell(.EventDetails, forIndexPath: indexPath)
            cell.configure(event: event)
            return cell
        }
        else if indexPath.section == 1  {
            let cell: CommentCell = tableView.dequeueLandetCell(.Comment, forIndexPath: indexPath)
            cell.configure(eventComment: comments![indexPath.row])
            return cell
        }
        else if indexPath.section == 2 {
            if postingComment {
                let cell: SpinnerCell = tableView.dequeueLandetCell(.Spinner, forIndexPath: indexPath)
                cell.spin()
                return cell
            } else {
                let cell: TextFieldCell = tableView.dequeueLandetCell(.TextField, forIndexPath: indexPath)
                cell.configure(placeholder: "Write comment...")
                return cell
            }
        }
        else {
            return UITableViewCell()
        }

    }
}

extension LandetTableCellIdentifier {
    static let EventDetails = LandetTableCellIdentifier("EventDetailsCell")
}