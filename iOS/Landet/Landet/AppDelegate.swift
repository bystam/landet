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

        HttpClient.debugHost = "http://10.0.6.103:3000"

        installSession()
        performLaunchCalls()
        setupUI()
        
        return true
    }

    private func installSession() {
        Session.installDefault()
    }

    private func performLaunchCalls() {
        LocationsService.reload()
    }

    private func setupUI() {
        Theme.apply()

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appNavigationController.installInWindow(window)
        window.makeKeyAndVisible()
        self.window = window

        authOverlayController = AuthOverlayController(window: window)
        authOverlayController.showIfSessionMissing()
    }

}

