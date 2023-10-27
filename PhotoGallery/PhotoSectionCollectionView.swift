//
//  PhotoSectionCollectionView.swift
//  PhotoGallery
//
//  Created by Tùng on 27/10/2023.
//

import UIKit

final class PhotoSectionCollectionView: UICollectionReusableView {
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ title: String) {
        cellTitleLbl.text = title == "" ? "N/A" : title
    }
}

