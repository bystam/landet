//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

extension UIViewController {

    func smartlyDeselectRows(tableView tableView: UITableView?) {

        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []

        if let coordinator = transitionCoordinator() {

            coordinator.animateAlongsideTransitionInView(parentViewController?.view, animation: { context in

                selectedIndexPaths.forEach {
                    tableView?.deselectRowAtIndexPath($0, animated: context.isAnimated())
                }
                }, completion: { context in
                    if context.isCancelled() {
                        selectedIndexPaths.forEach {
                            tableView?.selectRowAtIndexPath($0, animated: false, scrollPosition: .None)
                        }
                    }
            })
        }
        else {
            selectedIndexPaths.forEach {
                tableView?.deselectRowAtIndexPath($0, animated: false)
            }
        }
    }
}