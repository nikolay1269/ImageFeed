//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Nikolay on 14.07.2024.
//

import UIKit

enum ImageCellState {
    case loading
    case loaded(UIImage)
    case error
}

protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImageListCellDelegate?
    var animationLayers = Set<CALayer>()
    
    static let reuseIdentifier = "ImageListCell"
    
    var imageState: ImageCellState = .loading
    {
        didSet {
            processAnimationState()
        }
    }
    
    private func processAnimationState() {
        switch(imageState) {
        case .loading:
            addGradient(for: photoImageView)
        case .loaded(let image):
            photoImageView.image  = image
            removeAnimations()
        case .error:
            photoImageView.image = UIImage(named: "Stub")
            removeAnimations()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        dateLabel.text = nil
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        for animationLayer in animationLayers {
            animationLayer.frame = contentView.frame
        }
    }
    
    @IBAction private func likeButtonTap() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    private func addGradient(for view: UIView?) {
        
        guard let view = view, view.bounds.size != CGSize.zero else { return }
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.size.width, height: view.bounds.size.height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.533, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        view.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1.0]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange\(view.tag)")
    }
    
    private func removeAnimations() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
