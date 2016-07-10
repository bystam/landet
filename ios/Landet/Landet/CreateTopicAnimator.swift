//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class CreateTopicAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let presenting: Bool
    private let didCreate: Bool

    init(presenting: Bool, didCreate: Bool = false) {
        self.presenting = presenting
        self.didCreate = didCreate
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

            if didCreate {

                let headerVC = findHeaderVC(inVC: toVC)

                let newTopicIndex = NSIndexPath(forItem: 0, inSection: 1)
                headerVC.collectionView.scrollToItemAtIndexPath(newTopicIndex, atScrollPosition: .CenteredHorizontally, animated: false)
                headerVC.collectionView.layoutIfNeeded()

                let topicCell = headerVC.collectionView.cellForItemAtIndexPath(newTopicIndex) as! TopicsHeaderCollectionViewCell
                topicCell.circleView.transform = CGAffineTransformMakeScale(0.00001, 0.00001)

                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: [], animations: {
                    createTopicVC.circleView.transform = CGAffineTransformMakeScale(0.00001, 0.00001)
                    createTopicVC.titleLabel.alpha = 0.0
                }, completion: nil)


                UIView.animateWithDuration(0.3, delay: 0.2, options: [], animations: {
                    createTopicVC.blurView.effect = nil
                }, completion: nil)

                UIView.animateWithDuration(0.6, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                    topicCell.circleView.transform = CGAffineTransformIdentity
                }, completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                    toVC.endAppearanceTransition()
                    fromVC.endAppearanceTransition()
                })

            } else {
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
    }

    private func findHeaderVC(inVC vc: UIViewController) -> TopicsHeaderViewController! {
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
}
