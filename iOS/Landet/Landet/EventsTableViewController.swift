//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 76.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        EventAPI.shared.loadAll { (events, error) in
            Async.main {

                if let events = events {
                    self.events = events
                    self.tableView.reloadData()
                } else {
                    print(error)
                }
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventSummaryCell", forIndexPath: indexPath) as! EventSummaryCell

        cell.configure(event: events[indexPath.row])
        return cell
    }
}
