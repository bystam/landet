//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private typealias TabItemSpecification = (storyboard: String, title: String)

private let kTabs: [TabItemSpecification] = [
    (storyboard: "Topics", title: "Topics"),
    (storyboard: "Map", title: "Map")
]

class AppNavigationController {

    private let tabbarController: UITabBarController = {
        let tabbarController = UIStoryboard(name: "AppNavigation", bundle: nil).instantiateInitialViewController() as! UITabBarController

        var viewControllers = [UIViewController]()
        for tab in kTabs {
            let vc = UIStoryboard(name: tab.storyboard, bundle: nil).instantiateInitialViewController()!
            let item = UITabBarItem(title: tab.title, image: nil, selectedImage: nil)
            vc.tabBarItem = item

            viewControllers.append(vc)
        }
        tabbarController.viewControllers = viewControllers

        return tabbarController
    }()

    func installInWindow(window: UIWindow) {
        window.rootViewController = tabbarController
    }
}
