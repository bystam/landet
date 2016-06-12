//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    let dataSource = EventsTableDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.EventSummary])
        tableView.dataSource = dataSource

        tableView.estimatedRowHeight = 76.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))

        reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        smartlyDeselectRows(tableView: tableView)
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = dataSource.events[indexPath.row]
        navigationController?.pushViewController(EventDetailsViewController.create(event: event), animated: true)
    }
}

extension EventsTableViewController {

    func reloadData() {
        EventAPI.shared.loadAll { (events, error) in
            Async.main {
                if let events = events {
                    self.dataSource.events = events
                    self.tableView.reloadData()
                }
            }
        }
    }
}
