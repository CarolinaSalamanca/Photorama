//
//  ViewController.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/15/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    var store: PhotoStore!
    @IBOutlet var collectionView: UICollectionView!
    var photoDataSource = PhotoDataSource()
    
    // MARK: Do request
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        updateDataSource()
        store.fetchInterestingPhotos{
            (photosResult) in
            self.updateDataSource()
        }
    }
    
    // MARK: Show images in cells
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        let photo = photoDataSource.photos[indexPath.row]

        store.fetchImage(for: photo) {
            (result) -> Void in

            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)

            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(displaying: image)
            }
        }
    }
    
    //MARK: Send image from cell to detail img
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto": // its the identifier of the segue
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {

                let photo = photoDataSource.photos[selectedIndexPath.row]

                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (photosResult) in

            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

