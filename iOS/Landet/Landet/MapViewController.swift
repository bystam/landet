//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    private weak var imageView: UIImageView?
    private weak var scrollViewContent: UIView?

    private var iconToLocation = [UIView : MapLocation]()

    private var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self  
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if loading || imageView?.image != nil { return }

        loading = true
        activityIndicator.startAnimating()

        LocationAPI.shared.loadAll { (imageUrl, locations, error) in
            guard let imageUrl = imageUrl else { return }
            guard let url = NSURL(string: imageUrl) else { return }

            ImageLoader.loadImage(url) { (image) in

                self.setMapImage(image)
                self.placeLocations(locations ?? [])

                self.loading = false
            }
        }
    }

    private func setMapImage(image: UIImage?) {
        guard let image = image else { return }
        let imageView = UIImageView(image: image)

        let content = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        content.addSubview(imageView)
        content.tintColor = Colors.yellow
        scrollViewContent = content

        scrollView.addSubview(content)
        scrollView.contentSize = image.size

        scrollView.minimumZoomScale = view.bounds.size.height / image.size.height
        scrollView.maximumZoomScale = 2.0

        scrollView.contentOffset = CGPoint(x: imageView.center.x - scrollView.bounds.width/2,
                                           y: imageView.center.y - scrollView.bounds.height/2)

        self.imageView = imageView

        imageView.alpha = 0.0
        UIView.animateWithDuration(0.2) {
            imageView.alpha = 1.0
            self.activityIndicator.alpha = 0.0
        }
    }

    private func placeLocations(locations: [MapLocation]) {
        for location in locations {
            let p = CGPoint(x: location.x, y: location.y)

            let pinView = UIImageView(image: UIImage(named: location.icon))
            pinView.center = p
            scrollViewContent?.addSubview(pinView)

            pinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pinWasTapped(_:))))
            pinView.userInteractionEnabled = true
            iconToLocation[pinView] = location
        }
    }

    @objc private func pinWasTapped(sender: UITapGestureRecognizer) {
        let mapLocation = iconToLocation[sender.view!]!
        showDetailsForLocation(LocationsService.fromID(mapLocation.locationId)!)
    }

    private func showDetailsForLocation(location: Location) {
        let detailsVC = LocationDetailsViewController.fromStoryboard(location: location)
        presentViewController(detailsVC, animated: true, completion: nil)
    }
}

extension MapViewController: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollViewContent
    }
}
