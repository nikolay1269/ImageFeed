//
//  ViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 05.07.2024.
//

import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    
    private let showSingleImageIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    private let photosNames: [String] = Array(0..<20).map{ "\($0)" }
    
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageListService.shared.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(forName: ImageListService.didChangedNotification, object: nil, queue: .main) { [weak self] _ in
            
            self?.updateTableViewAnimated()
        }
        initTableView()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImageListService.shared.photos.count
        photos = ImageListService.shared.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func initTableView() {

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func configCell(for cell: ImageListCell, indexPath: IndexPath) {
        
        let url = URL(string: photos[indexPath.row].thumbImageURL)
        let placeholderImage = UIImage(named: "Stub")
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { [weak self] result in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        cell.photoImageView.kf.indicatorType = .activity
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.dateLabel.setTextSpacingBy(value: -0.08)
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "Favorite_active"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "Favorite_inactive"), for: .normal)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, indexPath: indexPath)
        return imageListCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showSingleImageIdentifier {
            guard
                let viewcontroller = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosNames[indexPath.row])
            viewcontroller.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let image = UIImage(named: photosNames[indexPath.row]) else {
            return 0
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / image.size.width
        let cellHeight = image.size.height * scale + imageInsets.bottom + imageInsets.top
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row + 1 == photos.count) {
            ImageListService.shared.fetchPhotosNextPage()
        }
    }
}
