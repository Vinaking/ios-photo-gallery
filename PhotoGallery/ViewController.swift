//
//  ViewController.swift
//  PhotoGallery
//
//  Created by Tùng on 27/10/2023.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    
    private var photoSections = [PhotoSectionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        requestPhotoPermission()
    }
    
}

// MARK: UI
extension ViewController {
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        
        let width = (view.frame.size.width - 8) / 3
        let size = CGSize(width: width, height: width)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = size
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.headerReferenceSize = CGSize(width: width, height: 50)
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
    }
}

// MARK: CollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoSections[section].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.photo = photoSections[indexPath.section].photos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotoSectionCollectionView", for: indexPath) as! PhotoSectionCollectionView
            header.setup(photoSections[indexPath.section].time)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: Permission
extension ViewController {
    private func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .limited:
                self.updatePhotoSection()
                break
            case .authorized:
                self.updatePhotoSection()
                break
            case .denied:
                break
            case .restricted:
                break
            case .notDetermined:
                break
            default:
                break
            }
        }
        
    }
}

// MARK: Data
extension ViewController {
    private func updatePhotoSection() {
        photoSections = Dictionary(grouping: getPhotoData(), by: {$0.time})
            .map {
                let section = PhotoSectionModel()
                section.time = $0.key
                section.photos = $0.value
                return section
            }
            .sorted {$0.time > $1.time}
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func getPhotoData() -> [PhotoModel] {
        var photos = [PhotoModel]()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.isSynchronous = true
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isNetworkAccessAllowed = true
        
        for index in 0...fetchResult.count-1 {
            let phAsset = fetchResult.object(at: index)
            let photo = PhotoModel()
            if let createDate = phAsset.creationDate {
                photo.time = getStringDateYMD(date: createDate)
            }
            
            PHCachingImageManager().requestImage(for: phAsset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: imageOptions) { (image, info) -> Void in
                photo.image = image
            }
            
            photos.append(photo)
            
        }
        
        return photos
    }
    
    private func getStringDateYMD(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        return formatter.string(from: date)
    }
}

class PhotoModel {
    var time = ""
    var image: UIImage?
}

class PhotoSectionModel {
    var time = ""
    var photos = [PhotoModel]()
}

