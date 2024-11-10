//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Nikolay on 14.07.2024.
//

import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImageListCellDelegate?
    
    static let reuseIdentifier = "ImageListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.kf.cancelDownloadTask()
    }
    
    
    @IBAction private func likeButtonTap() {
        delegate?.imageListCellDidTapLike(self)
    }
}
