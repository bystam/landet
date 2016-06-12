//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventsTableDataSource: NSObject, UITableViewDataSource {

    var events = [Event]()

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventSummaryCell", forIndexPath: indexPath) as! EventSummaryCell

        cell.configure(event: events[indexPath.row])
        return cell
    }

}
