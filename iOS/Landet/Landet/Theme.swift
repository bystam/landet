//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class Theme {

    static func apply() {
        applyNavbarAppearence()
        applyTabbarAppearence()
        applyTableViewAppearence()
    }

    private static func applyNavbarAppearence() {
        UINavigationBar.appearance().barTintColor = Colors.black
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = Colors.yellow
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName : Colors.yellow ]
    }

    private static func applyTabbarAppearence() {
        UITabBar.appearance().barTintColor = Colors.black
        UITabBar.appearance().translucent = false
        UITabBar.appearance().tintColor = Colors.yellow
        UITabBar.appearance().barStyle = .Black

        UITabBarItem.appearance().setTitleTextAttributes([ NSForegroundColorAttributeName : Colors.yellow ], forState: .Normal)
    }

    private static func applyTableViewAppearence() {
        UITableView.appearance().separatorColor = UIColor(white: 0.3, alpha: 0.6)
    }

}