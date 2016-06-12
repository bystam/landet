//
//  Copyright © 2016 PostNord AB. All rights reserved.
//

import UIKit

class CommentsHeaderView: UITableViewHeaderFooterView {

    static let preferredHeight: CGFloat = 56.0
    static let reuseIdentifier = "CommentsHeaderView"

    static func install(tableView tableView: UITableView) {
        let nib = UINib(nibName: "CommentsHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: CommentsHeaderView.reuseIdentifier)
    }
    
}
