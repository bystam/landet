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
    @IBOutlet weak var addCommentTextField: LandetTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController.tableView.contentInset.top = kHeaderHeight + kCommentViewHeight
        addCommentTextField.delegate = self

        loadAllTopics()
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
}

extension TopicsViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        let tableView = tableViewController.tableView

        var offsetY = (headerViewController.defaultHeight - headerViewController.minHeight)
        offsetY -= tableView.contentInset.top
        tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text where !text.isEmpty else { return false }
        return true
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
