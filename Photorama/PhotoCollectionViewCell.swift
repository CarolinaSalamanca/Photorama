//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/16/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell{
    // MARK: This is a custom cell 
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    func update(displaying image: UIImage?){
        if let imageToDisplay = image{
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        }else{
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
