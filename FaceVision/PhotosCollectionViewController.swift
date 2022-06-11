//
//  PhotosCollectionViewController.swift
//  PhotoLibrary-Display-Photos
//
//  Created by Mohammad Azam on 2/17/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//
import Foundation
import UIKit
import Photos

class PhotosCollectionViewController: UICollectionViewController {
    
    private var images = [PHAsset]()
    private var photo = PHAsset()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populatePhotos()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("PhotoCollectionViewCell is not found")
        }
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, _ in
            
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
            
        }
        
        return cell
        
    }
    
    /*private func populatePhotos() {
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            
            if status == .authorized {
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                
                let albumName = "Your Face"
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true

                let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                
                for k in 0 ..< collection.count {
                    let obj:AnyObject! = collection.object(at: k)
                    if obj.title == albumName {
                        // Perform the image request
                        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: CGSize(width: 1000, height: 1000), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) in

                            if let image = image {
                                // Add the returned image to your array
                                self.images += [image]
                            }
                            // If you haven't already reached the first
                            // index of the fetch result and if you haven't
                            // already stored all of the images you need,
                            // perform the fetch request again with an
                            // incremented index
                            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
                            } else {
                                // Else you have completed creating your array
                                print("Completed array: \(self.images[0])")
                                print("Image URL \(String(describing: info!["PHImageFileURLKey"]))")
                                self.imageUrl = "\(info!["PHImageFileURLKey"]!)"
                            }
                        })

                    }
                }
                
                fetchResult.enumerateObjects { (object,_, _) in
                    self?.images.append(object)
                }
                
                self?.images.reverse()
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
                
                
            }
            
        }
        
    }*/
    
    private func populatePhotos()
    {
        let albumName = "Your Face"
        var assetCollection = PHAssetCollection()
        var albumFound = Bool()
        var photoAssets = PHFetchResult<AnyObject>()
        let fetchOptions = PHFetchOptions()

        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let firstObject = collection.firstObject{
            //found the album
            assetCollection = firstObject
            albumFound = true
        }
        else { albumFound = false }
        _ = collection.count
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
        //let imageManager = PHCachingImageManager()
        photoAssets.enumerateObjects{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in

            if object is PHAsset{
                let asset = object as! PHAsset
                // print("Inside  If object is PHAsset, This is number 1")
                self.images.append(asset)
            }
        }
        
        self.images.reverse()
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
}
