//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private typealias TabItemSpecification = (storyboard: String, title: String, iconDeselected: String, iconSelected: String)

private let kTabs: [TabItemSpecification] = [
    (storyboard: "Events", title: "Events", iconDeselected: "TabIcon.Sun", iconSelected: "TabIcon.Sun+Selected"),
    (storyboard: "Topics", title: "Topics", iconDeselected: "TabIcon.Cocktail", iconSelected: "TabIcon.Cocktail+Selected"),
    (storyboard: "Map", title: "Map", iconDeselected: "TabIcon.Pin", iconSelected: "TabIcon.Pin+Selected"),
]

class AppNavigationController {

    private let tabbarController: UITabBarController = {
        let tabbarController = UIStoryboard(name: "AppNavigation", bundle: nil).instantiateInitialViewController() as! UITabBarController

        var viewControllers = [UIViewController]()
        for tab in kTabs {
            let vc = UIStoryboard(name: tab.storyboard, bundle: nil).instantiateInitialViewController()!
            let item = UITabBarItem(title: tab.title, image: UIImage(named: tab.iconDeselected), selectedImage: UIImage(named: tab.iconSelected))
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
