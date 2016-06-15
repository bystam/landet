//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    private(set) var event: Event!

    private(set) var tableViewController: EventDetailsTableViewController!

    static func create(event event: Event) -> EventDetailsViewController {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! EventDetailsViewController
        viewController.event = event
        return viewController
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! EventDetailsTableViewController
            tableViewController.event = event
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = event.title
    }

}
