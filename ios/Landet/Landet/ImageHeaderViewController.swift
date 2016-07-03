//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class ImageHeaderViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!

    lazy var defaultHeight: CGFloat = { return self.view.bounds.height }()
    let minHeight: CGFloat = 64.0

    var imageUrl: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        imageView.alpha = 0.0

        loadImage()
    }

    func respondToHeight(height: CGFloat) {
        imageViewHeight.constant = max(defaultHeight, height)
        imageView.alpha = 1.0 - (defaultHeight - height) / (defaultHeight - minHeight)
    }
}

extension ImageHeaderViewController { // Image

    private func loadImage() {
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageUrl) { [weak self] (data, res, error) in

            if let data = data where data.length > 0 {
                let image = UIImage(data: data)
                self?.presentImage(image)
            }
        }

        task.resume()
    }

    private func presentImage(image: UIImage?) {
        imageView.image = image

        UIView.animateWithDuration(0.3) {
            self.imageView.alpha = 1.0
            self.activityIndicator.alpha = 0.0
        }
    }
}
