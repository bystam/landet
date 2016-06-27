//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let kHeaderHeight: CGFloat = 250
private let kCommentViewHeight: CGFloat = 50

class TopicsViewController: UIViewController {

    private var tableViewController: TopicsTableViewController!

    private var headerViewController: TopicsHeaderViewController!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addCommentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController.tableView.contentInset.top = kHeaderHeight + kCommentViewHeight

        loadAllTopics()
        observeKeyboard()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! TopicsTableViewController
            tableViewController.scrollDelegate = self
        } else if segue.identifier == "embedHeader" {
            headerViewController = segue.destinationViewController as! TopicsHeaderViewController
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    private let keyboardObserver = KeyboardObserver()

    private func observeKeyboard() {
        keyboardObserver.keyboardWillShow = { [weak self] _ in
            guard let strongSelf = self else { return }

            var offsetY = (strongSelf.headerViewController.defaultHeight - strongSelf.headerViewController.minHeight)
            offsetY -= strongSelf.tableViewController.tableView.contentInset.top
            strongSelf.tableViewController.tableView.contentOffset = CGPoint(x: 0, y: offsetY)
            strongSelf.view.layoutIfNeeded()
        }
    }
}

// actions
extension TopicsViewController {

    @IBAction func beganEditingComment(sender: AnyObject) {
    }
}

extension TopicsViewController: TopicsTableViewControllerScrollDelegate {

    func topicsTableViewController(tableViewController: TopicsTableViewController,
                                   didScrollToOffset offset: CGPoint) {
        let offsetY = tableViewController.tableView.contentInset.top + offset.y
        let headerHeight = max(headerViewController.defaultHeight - offsetY,
                               headerViewController.minHeight)

        headerHeightConstraint.constant = headerHeight
        headerViewController.respondToHeight(headerHeight)
    }
}

extension TopicsViewController {

    func loadAllTopics() {
        TopicAPI.shared.loadAll { (topics, error) in
            Async.main {
                if let topics = topics {
                    self.headerViewController.topics = topics
                }
            }
        }
    }

}