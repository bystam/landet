//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    private(set) var event: Event!
    var comments: [EventComment]?

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

        observeKeyboard()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        EventAPI.shared.comments(forEvent: event) { (comments, error) in
            Async.main {
                self.comments = comments
            }
        }
    }


    private let keyboardObserver = KeyboardObserver()
    @IBOutlet weak var inputViewSpaceToBottom: NSLayoutConstraint!

    private func observeKeyboard() {
        keyboardObserver.keyboardWillShow = { size in
            let space = size.height - self.tabBarController!.tabBar.bounds.height
            self.inputViewSpaceToBottom.constant = space
            self.view.layoutIfNeeded()
        }
        keyboardObserver.keyboardWillHide = {
            self.inputViewSpaceToBottom.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
}
