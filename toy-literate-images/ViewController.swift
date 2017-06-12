//
//  ViewController.swift
//  toy-literate-images
//
//  Created by Hui Qi on 6/9/17.
//  Copyright © 2017 Hui Qi. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var images = [UIImage]()
    var photo: UIImage? = nil
    
    @IBOutlet weak var imageShow: UIImageView!
    
    private func getPhotos() {
        let fetchOptions = PHFetchOptions()
        
        let photoAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHCachingImageManager()
        print(photoAssets.count)
        
        photoAssets.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                print("Inside  If object is PHAsset, This is number 1")
                
                let imageSize = CGSize(width: asset.pixelWidth,
                                       height: asset.pixelHeight)
                
                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset,
                                          targetSize: imageSize,
                                          contentMode: .aspectFill,
                                          options: options,
                                          resultHandler: {
                                            (image, info) -> Void in
                                            self.photo = image!
                                            /* The image is now available to us */
                                            self.addImgToArray(uploadImage: self.photo!)
                                            print("enum for image, This is number 2")
                                            
                })
                
            }
        })
        
        self.imageShow.image = self.images.last
        
        print(self.images.count)
    }
    
    func addImgToArray(uploadImage:UIImage)
    {
        self.images.append(uploadImage)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // self.FetchCustomAlbumPhotos()
        self.getPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

