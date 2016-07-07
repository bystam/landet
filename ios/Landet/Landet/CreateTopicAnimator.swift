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
            fromVC.view.userInteractionEnabled = false

            fromVC.beginAppearanceTransition(false, animated: true)
            toVC.beginAppearanceTransition(true, animated: true)

            toVC.view.frame = fromVC.view.frame
            container.addSubview(toVC.view)

            let header = headerVC(inVC: fromVC)
            let circle = createCircle(inVC: header, container: container)

            let width = fromVC.view.bounds.width

            circle.transform = CGAffineTransformMakeTranslation(width, 0)

            createTopicVC.backgroundView.alpha = 0.0
            createTopicVC.titleLabel.alpha = 0.0
            createTopicVC.titleLabel.transform = CGAffineTransformMakeTranslation(0, 30)
            createTopicVC.circleView.alpha = 0.0

            UIView.animateKeyframesWithDuration(0.8, delay: 0.0, options: [], animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: {
                    circle.transform = CGAffineTransformIdentity
                    header.collectionView.transform = CGAffineTransformMakeTranslation(-width, 0)
                })
                UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.4, animations: {
                    circle.transform = transform(fromRect: circle.frame, toRect: createTopicVC.circleView.frame)
                    createTopicVC.backgroundView.alpha = 1.0
                })
                UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: {
                    createTopicVC.circleView.alpha = 1.0
                })
            }, completion: { _ in
                circle.removeFromSuperview()
            })

            UIView.animateWithDuration(0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: {
                createTopicVC.titleLabel.alpha = 1.0
                createTopicVC.titleLabel.transform = CGAffineTransformIdentity
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })

        } else {

            let createTopicVC = fromVC as! CreateTopicViewController
            let header = headerVC(inVC: toVC)

            UIView.animateWithDuration(0.5, animations: {
                createTopicVC.backgroundView.alpha = 0.0
                createTopicVC.titleLabel.alpha = 0.0
                createTopicVC.circleView.alpha = 0.0
                header.collectionView.transform = CGAffineTransformIdentity

            }, completion: { (_) in
                toVC.view.userInteractionEnabled = true
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())

                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })

            fromVC.beginAppearanceTransition(false, animated: false)
            toVC.beginAppearanceTransition(true, animated: false)
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
