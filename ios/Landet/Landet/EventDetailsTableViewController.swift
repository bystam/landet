//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

protocol EventDetailsTableViewControllerDelegate: class {
    func tableViewController(tableViewController: EventDetailsTableViewController, didScrollToOffset offset: CGPoint)
}

class EventDetailsTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var event: Event!
    private var dataSource: EventDetailsTableDataSource!

    weak var delegate: EventDetailsTableViewControllerDelegate?

    private var cachedHeights = [NSIndexPath : CGFloat]()

    let keyboardObserver = KeyboardObserver()

    var comments: [EventComment]? {
        didSet(oldComments) {
            dataSource.comments = comments

            let range = ((oldComments?.count ?? 0)..<(comments?.count ?? 0))
            let inserted = range.map({ NSIndexPath(forRow: $0, inSection: 1) })

            if inserted.count > 0 {
                tableView.insertRowsAtIndexPaths(inserted, withRowAnimation: .Automatic)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = EventDetailsTableDataSource(event: event)
        tableView.dataSource = dataSource

        LandetTableViewStyle.setup(tableView, cells: [.EventDetails, .Comment, .TextField, .Spinner])
        CommentsHeaderView.install(tableView: tableView)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = CommentsHeaderView.preferredHeight
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = 0.0

        observeKeyboard()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        reloadComments()
        keyboardObserver.enabled = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.enabled = false
    }

    private func reloadComments(completion: (() -> ())? = nil) {
        EventAPI.shared.comments(forEvent: event) { (comments, error) in
            Async.main {
                self.comments = comments
                completion?()
            }
        }
    }

    private func observeKeyboard() {

        let tableView = self.tableView

        keyboardObserver.keyboardWillShow = { [weak self] size in
            guard let strongSelf = self else { return }

            let keyboardAboveTabbar = size.height - strongSelf.tabBarController!.tabBar.bounds.height

            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2),
                                             atScrollPosition: .Bottom, animated: false)
            tableView.transform = CGAffineTransformMakeTranslation(0, -keyboardAboveTabbar)
            var offset = tableView.contentOffset
            offset.y += keyboardAboveTabbar
            strongSelf.delegate?.tableViewController(strongSelf,
                                                     didScrollToOffset: offset)
            strongSelf.parentViewController?.view.layoutIfNeeded()
        }

        keyboardObserver.keyboardWillHide = { [weak self] in
            guard let strongSelf = self else { return }
            tableView.transform = CGAffineTransformIdentity
            strongSelf.delegate?.tableViewController(strongSelf,
                                                     didScrollToOffset: tableView.contentOffset)
            strongSelf.parentViewController?.view.layoutIfNeeded()
        }

        keyboardObserver.enabled = false
    }
}

extension EventDetailsTableViewController: UIScrollViewDelegate { // UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.tableViewController(self, didScrollToOffset: scrollView.contentOffset)
    }
}

extension EventDetailsTableViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeights[indexPath] ?? CommentCell.preferredHeight
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? tableView.dequeueReusableHeaderFooterViewWithIdentifier(CommentsHeaderView.reuseIdentifier) : nil
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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

