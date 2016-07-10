//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class ImageHeaderViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navbarFadeView: UIImageView!

    lazy var defaultHeight: CGFloat = { return self.view.bounds.height }()
    let minHeight: CGFloat = 64.0

    var imageUrl: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        imageView.alpha = 0.0

        ImageLoader.loadImage(imageUrl) { [weak self] (image) in
            self?.presentImage(image)
        }
    }

    private func presentImage(image: UIImage?) {
        imageView.image = image

        UIView.animateWithDuration(0.3) {
            self.imageView.alpha = 1.0
            self.activityIndicator.alpha = 0.0
        }
    }

    func respondToHeight(height: CGFloat) {
        imageViewHeight.constant = max(defaultHeight, height)
        let alpha = 1.0 - (defaultHeight - height) / (defaultHeight - minHeight)
        imageView.alpha = alpha
        navbarFadeView.alpha = alpha
    }
}
