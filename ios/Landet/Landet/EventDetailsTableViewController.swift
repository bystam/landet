//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {

    var event: Event!
    private var dataSource: EventDetailsTableDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.EventSummary])

        dataSource = EventDetailsTableDataSource(event: event)
        tableView.dataSource = dataSource

        tableView.estimatedRowHeight = EventSummaryCell.preferredHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))
    }
}
