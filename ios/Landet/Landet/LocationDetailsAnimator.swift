//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LocationDetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return presenting ? 1.0 : 0.6
    }

    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!

        if presenting {

            let detailsVC = toVC as! LocationDetailsViewController

            fromVC.beginAppearanceTransition(false, animated: true)
            toVC.beginAppearanceTransition(true, animated: true)

            toVC.view.frame = UIScreen.mainScreen().bounds
            container.addSubview(toVC.view)

            let effect = detailsVC.blurView.effect
            detailsVC.blurView.effect = nil

            detailsVC.nameLabel.alpha = 0.0
            detailsVC.nameLabel.transform = CGAffineTransformMakeTranslation(0, 40)
            detailsVC.imageContainer.alpha = 0.0
            detailsVC.imageContainer.transform = CGAffineTransformMakeTranslation(0, 40)
            detailsVC.closeButton.alpha = 0.0
            detailsVC.closeButton.transform = CGAffineTransformMakeTranslation(0, 40)

            UIView.animateWithDuration(0.4, animations: { 
                detailsVC.blurView.effect = effect
            })

            UIView.animateWithDuration(0.6, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                detailsVC.nameLabel.alpha = 1.0
                detailsVC.nameLabel.transform = CGAffineTransformIdentity
            }, completion: nil)

            UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                detailsVC.imageContainer.alpha = 1.0
                detailsVC.imageContainer.transform = CGAffineTransformIdentity
            }, completion: nil)

            UIView.animateWithDuration(0.6, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 2.0, options: [], animations: {
                detailsVC.closeButton.alpha = 1.0
                detailsVC.closeButton.transform = CGAffineTransformIdentity
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })
        }
        else {

            let detailsVC = fromVC as! LocationDetailsViewController

            fromVC.beginAppearanceTransition(false, animated: true)
            toVC.beginAppearanceTransition(true, animated: true)

            UIView.animateWithDuration(0.3, delay: 0.0, options: [], animations: {
                detailsVC.closeButton.alpha = 0.0
                detailsVC.closeButton.transform = CGAffineTransformMakeTranslation(0, 40)
            }, completion: nil)

            UIView.animateWithDuration(0.3, delay: 0.1, options: [], animations: {
                detailsVC.imageContainer.alpha = 0.0
                detailsVC.imageContainer.transform = CGAffineTransformMakeTranslation(0, 40)
            }, completion: nil)

            UIView.animateWithDuration(0.3, delay: 0.2, options: [], animations: {
                detailsVC.nameLabel.alpha = 0.0
                detailsVC.nameLabel.transform = CGAffineTransformMakeTranslation(0, 40)
            }, completion: nil)



            UIView.animateWithDuration(0.3, delay: 0.3, options: [], animations: {
                detailsVC.blurView.effect = nil
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.endAppearanceTransition()
                fromVC.endAppearanceTransition()
            })
        }
    }

}
