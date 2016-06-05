//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let appNavigationController = AppNavigationController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupUI()
        
        return true
    }

    private func setupUI() {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appNavigationController.installInWindow(window)
        window.makeKeyAndVisible()
        self.window = window
    }
}

