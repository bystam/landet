//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var tableViewController: EventsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! EventsTableViewController
        }
    }

    @IBAction func unwindToEventsViewController(segue: UIStoryboardSegue) {
    }
}

extension EventsViewController {

    func reloadData() {
        EventAPI.shared.loadAll { (events, error) in
            Async.main {
                if let events = events {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.tableViewController.events = events
                }
            }
        }
    }
}
