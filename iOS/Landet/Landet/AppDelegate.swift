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
        performLaunchCalls()
        setupUI()
        ReminderRepository.shared.purgeLegacyNotifications()
        
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
        window.tintColor = Colors.red
        appNavigationController.installInWindow(window)
        window.makeKeyAndVisible()
        self.window = window

        authOverlayController = AuthOverlayController(window: window)
        authOverlayController.showIfSessionMissing()
    }

}

