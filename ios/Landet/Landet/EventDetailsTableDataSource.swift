//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsTableDataSource: NSObject, UITableViewDataSource {

    let event: Event
    var comments: [EventComment]?

    init(event: Event) {
        self.event = event
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return comments?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: EventSummaryCell = tableView.dequeueLandetCell(.EventSummary, forIndexPath: indexPath)
            cell.configure(event: event)
            return cell
        } else {
            let cell: CommentCell = tableView.dequeueLandetCell(.Comment, forIndexPath: indexPath)
            cell.configure(comment: comments![indexPath.row])
            return cell
        }

    }
}
