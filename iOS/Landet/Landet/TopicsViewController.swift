//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let kHeaderHeight: CGFloat = 250
private let kCommentViewHeight: CGFloat = 50

class TopicsViewController: UIViewController {

    let topicsRepository = TopicsRepository()

    private var tableViewController: TopicsTableViewController!

    private var headerViewController: TopicsHeaderViewController!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var addCommentTextField: LandetTextField!

    let keyboardObserver = KeyboardObserver()
    var showingKeyboard = false

    private lazy var tableBlockingView: UIView? = {
        let blockingView = UIView(frame: self.view.bounds)
        blockingView.alpha = 0.0
        blockingView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]

        blockingView.addGestureRecognizer(UITapGestureRecognizer(target: self.addCommentTextField, action: #selector(resignFirstResponder)))

        self.view.insertSubview(blockingView, aboveSubview: self.tableViewController.view.superview!)
        return blockingView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: kHeaderHeight + kCommentViewHeight))
        addCommentTextField.delegate = self

        observeKeyboard()

        setTextFieldEnabled(false)
        topicsRepository.load()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        keyboardObserver.enabled = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.enabled = false
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        addCommentTextField.resignFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! TopicsTableViewController
            tableViewController.scrollDelegate = self
            tableViewController.topicsRepository = topicsRepository
        } else if segue.identifier == "embedHeader" {
            headerViewController = segue.destinationViewController as! TopicsHeaderViewController
            headerViewController.headerDelegate = self
            headerViewController.topicsRepository = topicsRepository
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func setTextFieldEnabled(enabled: Bool) {
        addCommentTextField.userInteractionEnabled = enabled

        UIView.animateWithDuration(0.2) { 
            self.addCommentTextField.alpha = enabled ? 1.0 : 0.3
        }
    }


    // observe keyboard

    private func observeKeyboard() {

        var headerHeightBeforeShrink: CGFloat?

        keyboardObserver.keyboardWillShow = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showingKeyboard = true

            strongSelf.tableBlockingView?.alpha = 1.0

            headerHeightBeforeShrink = strongSelf.headerViewController.view.bounds.height
            let shrink = headerHeightBeforeShrink! - strongSelf.headerViewController.minHeight

            if shrink > 0.0 {
                strongSelf.headerHeightConstraint.constant = strongSelf.headerViewController.minHeight
                strongSelf.headerViewController.respondToHeight(strongSelf.headerViewController.minHeight)
                strongSelf.tableViewController.view.transform = CGAffineTransformMakeTranslation(0, -shrink)
                strongSelf.view.layoutIfNeeded()
            }
        }

        keyboardObserver.keyboardWillHide = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showingKeyboard = false

            strongSelf.tableViewController.view.transform = CGAffineTransformIdentity
            strongSelf.tableBlockingView?.alpha = 0.0

            if let heightBefore = headerHeightBeforeShrink where heightBefore > 0 {
                headerHeightBeforeShrink = nil
                strongSelf.headerHeightConstraint.constant = heightBefore
                strongSelf.headerViewController.respondToHeight(heightBefore)
                strongSelf.view.layoutIfNeeded()
            }
        }

        keyboardObserver.enabled = false
    }
}

extension TopicsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text where !text.isEmpty else { return false }
        guard let topic = topicsRepository.currentTopic else { return false }
        textField.text = nil

        topicsRepository.commentsRepository.post(comment: text, toTopic: topic)
        return true
    }
}

extension TopicsViewController: TopicsTableViewControllerScrollDelegate {

    func topicsTableViewController(tableViewController: TopicsTableViewController,
                                   didScrollToOffset offset: CGPoint) {
        guard !showingKeyboard else { return }

        let headerHeight = max(headerViewController.defaultHeight - offset.y,
                               headerViewController.minHeight)

        headerHeightConstraint.constant = headerHeight
        headerViewController.respondToHeight(headerHeight)
    }
}

extension TopicsViewController: TopicsHeaderViewControllerDelegate {

    func header(header: TopicsHeaderViewController, startedDisplayingTopic topic: Topic?) {
        setTextFieldEnabled(topic != nil)
    }
}
