//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 24.07.2024.
//

import UIKit

class SingleImageViewController: UIViewController {

    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            guard let image = image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImageView.image = image
        if let size = image?.size {
            singleImageView.frame.size = size
        }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        guard let image = image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }

    @IBAction private func didTapShareButton() {
        guard let image else { return }
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(ac, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        let visibleRectSize = scrollView.bounds.size
        let hScale = visibleRectSize.width / image.size.width
        let vScale = visibleRectSize.height / image.size.height
        let theoreticalScale = min(hScale, vScale)
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}
