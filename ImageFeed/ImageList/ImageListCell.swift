//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Nikolay on 14.07.2024.
//

import UIKit

final class ImageListCell: UITableViewCell {
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImageListCell"
}
