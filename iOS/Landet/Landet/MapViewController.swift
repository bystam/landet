//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    private weak var imageView: UIImageView?
    private weak var scrollViewContent: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        activityIndicator.startAnimating()
        let url = NSURL(string: "http://www.theodora.com/maps/new9/time_zones_4.jpg")!
        ImageLoader.loadImage(url) { (image) in
            self.setMapImage(image)
            self.placePins()
        }
    }

    private func setMapImage(image: UIImage?) {
        guard let image = image else { return }
        let imageView = UIImageView(image: image)

        let content = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        content.addSubview(imageView)
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

    private func placePins() {
        let pin = UIImage(named: "pin")
        for _ in 0..<3 {
            let p = CGPoint(x: random() % Int(scrollView.contentSize.width),
                            y: random() % Int(scrollView.contentSize.height))

            let pinView = UIImageView(image: pin)
            pinView.center = p
            scrollViewContent?.addSubview(pinView)
        }
    }
}

extension MapViewController: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollViewContent
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?,
                                 atScale scale: CGFloat) {
        print(scale)
    }
}
