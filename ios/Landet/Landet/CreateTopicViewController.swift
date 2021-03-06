//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicViewController: UIViewController {

    var topicsRepository: TopicsRepository!

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circleView: RoundRectView!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    private var didCreate = false

    static func create() -> CreateTopicViewController {
        let storyboard = UIStoryboard(name: "CreateTopic", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CreateTopicViewController
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self

        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:)))
        blurView.addGestureRecognizer(tapToDismiss)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    @objc private func backgroundViewTapped(tap: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CreateTopicViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        let width = textView.bounds.width
        let size = textView.sizeThatFits(CGSize(width: width, height: CGFloat.max))

        guard size.height != textViewHeight.constant else { return }

        UIView.animateWithDuration(0.1, animations: {
            self.textViewHeight.constant = size.height
        })
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        if text == "" { return true }

        if text != "\n" { return textView.text.characters.count < 80 }

        guard let text = textView.text where !text.isEmpty else { return false }

        textView.resignFirstResponder()
        topicsRepository.create(topicText: text) { (error) in
            if let _ = error {
                textView.becomeFirstResponder()
            } else {
                self.didCreate = true
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        return false
    }
}

extension CreateTopicViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicAnimator(presenting: true)
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicAnimator(presenting: false, didCreate: didCreate)
    }
}
