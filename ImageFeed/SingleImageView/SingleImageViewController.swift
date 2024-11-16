//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 24.07.2024.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {

    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            guard let image = image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var fullImageURL: URL?
    
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = self.fullImageURL, let placeholderImage = UIImage(named: "Stub") else { return }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        singleImageView.image = placeholderImage
        singleImageView.frame.size = placeholderImage.size
        rescaleAndCenterImageInScrollView(image: placeholderImage)
        
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { [weak self] result in
        
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch(result) {
            case .success:
                self.scrollView.setZoomScale(1.0, animated: false)
                self.scrollView.contentOffset = CGPoint.zero
                guard let image = self.singleImageView.image else { return }
                self.singleImageView.frame.size = image.size
                self.rescaleAndCenterImageInScrollView(image: image)
            case .failure(let error):
                self.showErorrAlert(error: error)
            }
        })
    }
    
    private func showErorrAlert(error: Error) {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось загрузить полноразмерную картинку: \(error)",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
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
