//
//  ViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 05.07.2024.
//

import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set}
    func initTableView()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    
    private let showSingleImageIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    var presenter: ImageListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func initTableView() {

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func configCell(for cell: ImageListCell, indexPath: IndexPath) {
        
        let url = presenter?.photoThumbnailURLForIndex(indexPath.row)
        let placeholderImage = UIImage(named: "Stub")
        cell.delegate = self
        cell.imageState = .loading
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { [weak self, weak cell] result in
            guard let self = self, let cell = cell else { return }
            switch(result) {
            case .success(let imageResult):
                cell.imageState = .loaded(imageResult.image)
            case .failure(let error):
                print(error)
                cell.imageState = .error
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        cell.photoImageView.kf.indicatorType = .activity
        cell.dateLabel.text = presenter?.photoCreatedAtDateTextForIndex(indexPath.row)
        cell.dateLabel.setTextSpacingBy(value: -0.08)
        if let isLiked = presenter?.photoIsLikedForIndex(indexPath.row) {
            setIsLike(isLiked, cell: cell)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount() ?? 0
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
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.fullImageURL = presenter?.photoLargeURLForIndex(indexPath.row)
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
        
        let testMode =  ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode {
            if indexPath.row + 1 == presenter?.photosCount() {
                presenter?.loadNextPhotosPage()
            }
        }
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.changeLike(for: indexPath.row, completion: { [weak self, weak cell] result, isLike  in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
             
            switch(result) {
            case .success():
                guard let cell = cell else { return }
                self.setIsLike(isLike, cell: cell)
            case .failure(let error):
                print("[imageListCellDidTapLike]: Error: \(error)")
                self.showErorrAlert()
            }
        })
    }
    
    private func setIsLike(_ isLike: Bool, cell: ImageListCell) {
        if isLike {
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
