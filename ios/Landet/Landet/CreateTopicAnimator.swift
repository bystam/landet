//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return presenting ? 1.0 : 0.5
    }

    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!

        if presenting {
            let createTopicVC = toVC as! CreateTopicViewController

            fromVC.beginAppearanceTransition(false, animated: true)
            toVC.beginAppearanceTransition(true, animated: true)

            toVC.view.frame = fromVC.view.frame
            container.addSubview(toVC.view)

            let effect = createTopicVC.blurView.effect
            createTopicVC.blurView.effect = nil

            createTopicVC.circleView.alpha = 0.0
            createTopicVC.circleView.transform = CGAffineTransformMakeTranslation(0, 40)
            createTopicVC.titleLabel.alpha = 0.0
            createTopicVC.titleLabel.transform = CGAffineTransformMakeTranslation(0, 40)

            UIView.animateWithDuration(0.4, animations: {
                createTopicVC.blurView.effect = effect
            })

            UIView.animateWithDuration(0.6, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                createTopicVC.titleLabel.alpha = 1.0
                createTopicVC.titleLabel.transform = CGAffineTransformIdentity
            }, completion: nil)

            UIView.animateWithDuration(0.6, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                createTopicVC.circleView.alpha = 1.0
                createTopicVC.circleView.transform = CGAffineTransformIdentity
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })

        } else {

            let createTopicVC = fromVC as! CreateTopicViewController

            fromVC.beginAppearanceTransition(false, animated: true)
            toVC.beginAppearanceTransition(true, animated: true)

            UIView.animateWithDuration(0.3, animations: {
                createTopicVC.circleView.alpha = 0.0
                createTopicVC.circleView.transform = CGAffineTransformMakeTranslation(0, 40)
            })

            UIView.animateWithDuration(0.3, delay: 0.1, options: [], animations: {
                createTopicVC.titleLabel.alpha = 0.0
                createTopicVC.titleLabel.transform = CGAffineTransformMakeTranslation(0, 40)
                }, completion: nil)

            UIView.animateWithDuration(0.3, delay: 0.2, options: [], animations: {
                createTopicVC.blurView.effect = nil
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })
        }
    }

    private func headerVC(inVC vc: UIViewController) -> TopicsHeaderViewController! {
        var parent = vc
        if let tab = parent as? UITabBarController {
            parent = tab.selectedViewController!
        }
        if let nav = parent as? UINavigationController {
            parent = nav.topViewController!
        }

        for child in parent.childViewControllers {
            if let child = child as? TopicsHeaderViewController {
                return child
            }
        }
        return nil
    }

    private func createCircle(inVC vc: TopicsHeaderViewController, container: UIView) -> RoundRectView {
        let size = CGFloat(200)
        let circle = RoundRectView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        circle.backgroundColor = Colors.black
        circle.borderColor = Colors.red
        circle.borderWidth = 1.0
        circle.cornerRadius = size/2

        circle.center = vc.view.convertPoint(vc.view.bounds.center, toView: container)
        container.addSubview(circle)

        return circle
    }
}
