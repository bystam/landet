//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    static func create(event event: Event) -> EventDetailsViewController {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!
        return viewController as! EventDetailsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
