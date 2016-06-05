//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        HttpClient.debugHost = "http://192.168.1.174:3000"
        
        UserAPI.shared.login(username: "u1", password: "pw1") { (error) in
            print(error)
        }
    }
}
