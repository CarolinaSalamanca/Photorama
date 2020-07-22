//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/16/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource{
    var photos = [Photo]()
    
    //MARK: Required methods for the datasource protocol
    //these methods are similar to those of the tableView
   
    // asks how many cells to display
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // asks the UICollectionViewCell to display for a given index path
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier = "PhotoCollectionViewCell" // id of the cell view in the canvas
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath) as! PhotoCollectionViewCell // to use our custom cell
        // to use our custom cell
        cell.update(displaying: nil)
        return cell
    }
}
