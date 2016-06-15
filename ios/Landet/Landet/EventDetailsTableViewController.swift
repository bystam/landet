//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {

    var event: Event!
    private var dataSource: EventDetailsTableDataSource!

    var comments: [EventComment]? {
        didSet {
            dataSource.comments = comments
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.EventSummary, .Comment, .TextField, .Spinner])
        CommentsHeaderView.install(tableView: tableView)

        dataSource = EventDetailsTableDataSource(event: event)
        tableView.dataSource = dataSource

        tableView.estimatedRowHeight = EventSummaryCell.preferredHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = CommentsHeaderView.preferredHeight
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? tableView.dequeueReusableHeaderFooterViewWithIdentifier(CommentsHeaderView.reuseIdentifier) : nil
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TextFieldCell {
            cell.delegate = self
        }
    }

    // MARK: - Actions

}

extension EventDetailsTableViewController: TextFieldCellDelegate {

    func textWasEntered(inCell cell: TextFieldCell) {

        cell.lockWithSpinner()
//
//        dataSource.postingComment = true
//        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Fade)

        Async.main(2.0) {
            cell.unlock()
//            self.dataSource.postingComment = false
//            self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Fade)

        }
    }
}

