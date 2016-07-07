//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

protocol EventDetailsTableViewControllerDelegate: class {
    func tableViewController(tableViewController: EventDetailsTableViewController, didScrollToOffset offset: CGPoint)
}

class EventDetailsTableViewController: UITableViewController {

    var event: Event!
    private var dataSource: EventDetailsTableDataSource!

    weak var delegate: EventDetailsTableViewControllerDelegate?

    private var cachedHeights = [NSIndexPath : CGFloat]()

    var comments: [EventComment]? {
        didSet(oldComments) {
            dataSource.comments = comments

            let range = ((oldComments?.count ?? 0)..<(comments?.count ?? 0))
            let inserted = range.map({ NSIndexPath(forRow: $0, inSection: 1) })

            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths(inserted, withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LandetTableViewStyle.setup(tableView, cells: [.EventSummary, .Comment, .TextField, .Spinner])
        CommentsHeaderView.install(tableView: tableView)

        dataSource = EventDetailsTableDataSource(event: event)
        tableView.dataSource = dataSource

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = CommentsHeaderView.preferredHeight
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = 0.0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: CGFloat.min))
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        reloadComments()
    }

    private func reloadComments(completion: (() -> ())? = nil) {
        EventAPI.shared.comments(forEvent: event) { (comments, error) in
            Async.main {
                self.comments = comments
                completion?()
            }
        }
    }
}

extension EventDetailsTableViewController { // UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.tableViewController(self, didScrollToOffset: scrollView.contentOffset)
    }
}

extension EventDetailsTableViewController {

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeights[indexPath] ?? CommentCell.preferredHeight
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? tableView.dequeueReusableHeaderFooterViewWithIdentifier(CommentsHeaderView.reuseIdentifier) : nil
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? TextFieldCell {
            cell.delegate = self
        }

        cachedHeights[indexPath] = cell.bounds.height
    }
}

extension EventDetailsTableViewController: TextFieldCellDelegate {

    func text(text: String, wasEnteredInCell cell: TextFieldCell) {
        cell.textField.resignFirstResponder()
        cell.lockWithSpinner()

        // dispatch to make sure keyboard is gone
        Async.main(0.45) {
            EventAPI.shared.post(comment: text, toEvent: self.event) { (error) in
                self.reloadComments({
                    cell.textField.text = nil
                    cell.unlock()
                })
            }
        }
    }
}

