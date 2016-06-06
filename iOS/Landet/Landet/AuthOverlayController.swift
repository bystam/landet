//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class AuthOverlayController {

    private let window: UIWindow
    private var overlayWindow: UIWindow?

    private var mainWindowRoot: UIViewController?

    init(window: UIWindow) {
        self.window = window
        window.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionWasEstablished(_:)), name: kSessionEstablishedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionWasLost(_:)), name: kSessionLostNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc func sessionWasEstablished(notification: NSNotification) {
        if overlayWindow != nil {
            Async.main {
                self.dismissOverlayWindow(true)
            }
        }
    }

    @objc func sessionWasLost(notification: NSNotification) {
        Async.main {
            self.displayOverlayWithViewController(LoginViewController.create(), animated: true)
        }
    }

    private func displayOverlayWithViewController(viewController: UIViewController, animated: Bool = false) {
        let bounds = UIScreen.mainScreen().bounds
        let overlay = UIWindow(frame: bounds)
        overlay.windowLevel = UIWindowLevelStatusBar
        overlay.hidden = false
        overlay.userInteractionEnabled = true
        overlay.rootViewController = viewController
        overlay.tintColor = window.tintColor
        self.overlayWindow = overlay

        overlayWindow?.makeKeyAndVisible()

        if animated {
            animateOverlayAppearance({ (_) -> Void in
                self.mainWindowRoot = self.window.rootViewController
                self.window.rootViewController = nil
            })
        } else {
            self.mainWindowRoot = self.window.rootViewController
            self.window.rootViewController = nil
        }
    }

    private func dismissOverlayWindow(animated: Bool) {
        if (mainWindowRoot != nil) {
            window.rootViewController = self.mainWindowRoot
        }
        mainWindowRoot = nil

        if animated {
            animateOverlayDisappearance({ [weak self] (_) -> Void in
                self?.overlayWindow?.hidden = true
                self?.overlayWindow?.rootViewController = nil
                self?.overlayWindow = nil
                })
        } else {
            overlayWindow?.hidden = true
            overlayWindow?.rootViewController = nil
            overlayWindow = nil
        }

        window.makeKeyAndVisible()
    }

    private func animateOverlayAppearance(completion: ((Bool) -> Void)?) {
        guard let overlay = overlayWindow else { return }

        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [],
                                   animations: { [weak self] () -> Void in
                                    self?.window.alpha = 0.5
            }, completion: completion)


        overlay.transform = CGAffineTransformMakeTranslation(0, overlay.bounds.height)
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [],
                                   animations: { () -> Void in
                                    overlay.transform = CGAffineTransformIdentity
            }, completion: nil)
    }

    private func animateOverlayDisappearance(completion: ((Bool) -> Void)?) {
        guard let overlay = overlayWindow else { return }

        window.alpha = 0.5
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [],
                                   animations: { [weak self] () -> Void in
                                    self?.window.alpha = 1.0
            }, completion: completion)

        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [],
                                   animations: { () -> Void in
                                    overlay.transform = CGAffineTransformMakeTranslation(0, overlay.bounds.height)
            }, completion: nil)
    }

}