//
//  PhotoCell.swift
//  PhotoGallery
//
//  Created by Tùng on 27/10/2023.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet private var image: UIImageView!

    var photo: PhotoModel? {
        didSet {
            if let photo = photo {
                image.image = photo.image
            }
        }
    }

}
