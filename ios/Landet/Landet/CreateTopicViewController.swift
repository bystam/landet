//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circleView: RoundRectView!
    @IBOutlet weak var textView: UITextView!

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

        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:)))
        backgroundView.addGestureRecognizer(tapToDismiss)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    @objc private func backgroundViewTapped(tap: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CreateTopicViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicAnimator(presenting: true)
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CreateTopicAnimator(presenting: false)
    }
}


private class CreateTopicAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    @objc private func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return presenting ? 1.0 : 0.6
    }

    @objc private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!

        if presenting {
            let createTopicVC = toVC as! CreateTopicViewController
            fromVC.view.userInteractionEnabled = false

            fromVC.beginAppearanceTransition(false, animated: true)
            createTopicVC.beginAppearanceTransition(true, animated: true)

            toVC.view.frame = fromVC.view.frame
            container.addSubview(toVC.view)

            createTopicVC.backgroundView.alpha = 0.0
            createTopicVC.titleLabel.alpha = 0.0
            createTopicVC.titleLabel.transform = CGAffineTransformMakeTranslation(0, 30)
            createTopicVC.circleView.alpha = 0.0
            createTopicVC.circleView.transform = CGAffineTransformMakeTranslation(0, 30)

            UIView.animateWithDuration(0.3, animations: {
                createTopicVC.backgroundView.alpha = 1.0
            })

            UIView.animateWithDuration(0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: { 
                createTopicVC.titleLabel.alpha = 1.0
                createTopicVC.titleLabel.transform = CGAffineTransformIdentity
            }, completion: nil)

            UIView.animateWithDuration(0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: {
                createTopicVC.circleView.alpha = 1.0
                createTopicVC.circleView.transform = CGAffineTransformIdentity
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })

        } else {

            fromVC.beginAppearanceTransition(false, animated: false)
            toVC.beginAppearanceTransition(true, animated: false)

            toVC.view.userInteractionEnabled = true
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())

            toVC.endAppearanceTransition()
            fromVC.endAppearanceTransition()

        }
    }
}
