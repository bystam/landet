//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    private(set) var event: Event!

    private(set) var tableViewController: EventDetailsTableViewController!

    private(set) var headerViewController: ImageHeaderViewController!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!

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
            tableViewController.delegate = self
        } else if segue.identifier == "embedHeader" {
            headerViewController = segue.destinationViewController as! ImageHeaderViewController
            headerViewController.imageUrl = event.location.imageUrl
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = event.title

        tableViewController.tableView.tableHeaderView = UIView(frame: headerViewController.view.bounds)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let navbar = navigationController?.navigationBar
        transitionCoordinator()?.animateAlongsideTransition({ (context) in
            navbar?.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navbar?.shadowImage = UIImage()
            navbar?.translucent = true
        }, completion: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        let navbar = navigationController?.navigationBar
        transitionCoordinator()?.animateAlongsideTransition({ (context) in
            navbar?.setBackgroundImage(nil, forBarMetrics: .Default)
            navbar?.shadowImage = nil
            navbar?.translucent = false
        }, completion: { (context) in
            if context.isCancelled() {
                navbar?.setBackgroundImage(UIImage(), forBarMetrics: .Default)
                navbar?.shadowImage = UIImage()
                navbar?.translucent = true
            }
        })
    }

}

extension EventDetailsViewController: EventDetailsTableViewControllerDelegate {

    func tableViewController(tableViewController: EventDetailsTableViewController, didScrollToOffset offset: CGPoint) {
        let height = max(headerViewController.minHeight,
                         headerViewController.defaultHeight - offset.y)

        headerViewHeight.constant = height
        headerViewController.respondToHeight(height)
    }
}
