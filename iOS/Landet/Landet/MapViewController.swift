//
//  Copyright © 2016 Landet. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    private weak var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        let url = NSURL(string: "http://www.theodora.com/maps/new9/time_zones_4.jpg")!
        ImageLoader.loadImage(url) { (image) in
            self.setMapImage(image)
        }
    }

    private func setMapImage(image: UIImage?) {
        guard let image = image else { return }
        let imageView = UIImageView(image: image)

        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size

        scrollView.minimumZoomScale = view.bounds.size.height / image.size.height
        scrollView.maximumZoomScale = 2.0

        self.imageView = imageView
    }
}

extension MapViewController: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?,
                                 atScale scale: CGFloat) {
        print(scale)
    }
}
