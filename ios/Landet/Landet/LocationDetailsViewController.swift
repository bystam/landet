//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var imageContainer: RoundRectView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: RoundRectButton!

    var location: Location!

    static func fromStoryboard(location location: Location) -> LocationDetailsViewController {
        let storyboard = UIStoryboard(name: "LocationDetails", bundle: nil)
        let locationDetailsVC = storyboard.instantiateInitialViewController() as! LocationDetailsViewController
        locationDetailsVC.location = location
        return locationDetailsVC
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.alpha = 0.0
        ImageLoader.loadImage(location.imageUrl) { [weak self] (image) in
            self?.presentImage(image)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    private func presentImage(image: UIImage?) {
        imageView.image = image

        UIView.animateWithDuration(0.3) {
            self.imageView.alpha = 1.0
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension LocationDetailsViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LocationDetailsAnimator(presenting: true)
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LocationDetailsAnimator(presenting: false)
    }
}
