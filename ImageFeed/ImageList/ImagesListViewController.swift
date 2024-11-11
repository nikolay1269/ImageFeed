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
        
        let photo = photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)
        let placeholderImage = UIImage(named: "Stub")
        cell.delegate = self
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { [weak self] result in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        cell.photoImageView.kf.indicatorType = .activity
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        cell.dateLabel.setTextSpacingBy(value: -0.08)
        setIsLike(photo.isLiked, cell: cell)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
            
            let photo = self.photos[indexPath.row]
            viewcontroller.fullImageURL = photo.largeImageURL
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

        guard let cell = tableView.cellForRow(at: indexPath) as? ImageListCell, let image = cell.photoImageView.image else { return tableView.estimatedRowHeight }

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

extension ImagesListViewController: ImageListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        ImageListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            
            guard let self = self else { return }
            
            switch(result) {
            case .success():
                self.photos = ImageListService.shared.photos
                self.setIsLike(!photo.isLiked, cell: cell)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("[imageListCellDidTapLike]: Error: \(error)")
                UIBlockingProgressHUD.dismiss()
                self.showErorrAlert()
            }
        }
    }
    
    private func setIsLike(_ isLike: Bool, cell: ImageListCell) {
        if(isLike) {
            cell.likeButton?.setImage(UIImage(named: "Favorite_active"), for: .normal)
        } else {
            cell.likeButton?.setImage(UIImage(named: "Favorite_inactive"), for: .normal)
        }
    }
    
    private func showErorrAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось изменить состояние favorite",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
