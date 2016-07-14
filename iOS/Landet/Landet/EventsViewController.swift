//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

private let formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEEE HH:mm"
    return formatter
}()

class EventsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var tableViewController: EventsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        reloadData()

        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(dataShouldBeReloaded(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(dataShouldBeReloaded(_:)), name: kSessionEstablishedNotification, object: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            tableViewController = segue.destinationViewController as! EventsTableViewController
        }
    }

    @IBAction func unwindToEventsViewController(segue: UIStoryboardSegue) {
        reloadData()
    }
}

extension EventsViewController {

    func dataShouldBeReloaded(notification: NSNotification) {
        reloadData()
    }

    func reloadData() {
        EventAPI.shared.loadAll { (events, error) in
            Async.main {
                if let events = events {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.tableViewController.events = events
                    ReminderRepository.shared.registerEvents(events)
                }
            }
        }
    }
}

private let EventReminderTypeKey = "EventReminderTypeKey"
private let EventReminderVersion = "EventReminderVersion2"
private let EventReminderIdKey = "EventReminderIdKey"

class ReminderRepository {

    static let shared = ReminderRepository()

    func purgeLegacyNotifications() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications ?? []
        for n in notifications {
            let version = n.userInfo?[EventReminderTypeKey] as? String
            if version != EventReminderVersion {
                UIApplication.sharedApplication().cancelLocalNotification(n)
            }
        }
    }

    func registerEvents(events: [Event]) {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications ?? []
        let schedueledIds = notifications.flatMap({ (n) -> Int? in
            return n.userInfo?[EventReminderIdKey] as? Int
        })

        let limit = NSDate().fifteenMinutesLater
        let future = events.filter({ (e) -> Bool in
            return e.time.compare(limit) == NSComparisonResult.OrderedDescending
        })

        let toSchedule = future.filter { (e) -> Bool in
            return !schedueledIds.contains(e.id)
        }

        for event in toSchedule {
            let newNotification = UILocalNotification()
            newNotification.alertTitle = event.title
            newNotification.alertBody = formatter.stringFromDate(event.time)
            newNotification.fireDate = event.time.fifteenMinutesEarlier
            newNotification.userInfo = [ EventReminderIdKey : event.id, EventReminderTypeKey : EventReminderVersion ]
            newNotification.timeZone = nil
            UIApplication.sharedApplication().scheduleLocalNotification(newNotification)
        }
    }

}

private extension NSDate {

    var fifteenMinutesEarlier: NSDate {
        return self.dateByAddingTimeInterval(-15 * 60)
    }

    var fifteenMinutesLater: NSDate {
        return self.dateByAddingTimeInterval(15 * 60)
    }
}