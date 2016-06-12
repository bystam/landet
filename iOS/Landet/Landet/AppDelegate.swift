//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let appNavigationController = AppNavigationController()
    private var authOverlayController: AuthOverlayController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        installSession()
        setupUI()
        
        return true
    }

    private func installSession() {
        HttpClient.debugHost = "http://192.168.1.174:3000"
        Session.installDefault()
    }

    private func setupUI() {
        Theme.apply()

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appNavigationController.installInWindow(window)
        window.makeKeyAndVisible()
        self.window = window

        authOverlayController = AuthOverlayController(window: window)
    }

}

