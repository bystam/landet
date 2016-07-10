//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    let dataSource = EventsTableDataSource()
    var events: [Event] {
        get { return dataSource.events }
        set(events) {
            dataSource.events = events
            tableView.reloadData()
        }
    }

    private var cachedHeights = [Int : CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.EventSummary])
        tableView.dataSource = dataSource

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        smartlyDeselectRows(tableView: tableView)
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let event = dataSource.events[indexPath.row]
        return cachedHeights[event.id] ?? EventSummaryCell.preferredHeight
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let event = dataSource.events[indexPath.row]
        cachedHeights[event.id] = cell.bounds.height
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = dataSource.events[indexPath.row]
        navigationController?.pushViewController(EventDetailsViewController.create(event: event), animated: true)
    }
}
