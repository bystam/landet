//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsTableDataSource: NSObject, UITableViewDataSource {

    let event: Event

    init(event: Event) {
        self.event = event
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 5
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: EventSummaryCell = tableView.dequeueLandetCell(.EventSummary, forIndexPath: indexPath)
            cell.configure(event: event)
            return cell
        } else {
            return tableView.dequeueLandetCell(.Comment, forIndexPath: indexPath)
        }

    }
}
