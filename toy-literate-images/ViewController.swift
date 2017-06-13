//
//  ViewController.swift
//  toy-literate-images
//
//  Created by Hui Qi on 6/9/17.
//  Copyright © 2017 Hui Qi. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class ViewController: UIViewController {

    private var notification: NSObjectProtocol?
    
    var images = [UIImage]()
    var photo: UIImage? = nil

    
    @IBOutlet weak var imageShow: UIImageView!
    
    
    private func postFaceRepresentation(url: String, faceVector: String){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let postString = "id=13&name=Jack"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    
    private func detectFaces(personPic: UIImageView){
        
        guard let personciImage = CIImage(image: personPic.image!) else{
            return
        }
        for view in personPic.subviews{
            view.removeFromSuperview()
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.0] as [String : Any]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)
        print("detect faces")
        print(faces?.count)
        // Convert Core Image Coordinate to UIView Coordinate
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        var faceCropUI: UIImage? = nil
        for face in faces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            
            // self.imageShow.image = faceCropUI
            

            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // get the cropped image
            var faceImage = (personPic.image?.cgImage)!.cropping(to: faceViewBounds)
            faceCropUI = UIImage.init(cgImage: faceImage!)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = personPic.bounds.size
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            
            
            let faceBox = UIView(frame: faceViewBounds)
            
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            personPic.addSubview(faceBox)
            
            if face.hasLeftEyePosition {
                //print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                //print("Right eye bounds are \(face.rightEyePosition)")
            }
        }
        // self.imageShow.image = faceCropUI
    }

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
        
        self.detectFaces(personPic: self.imageShow)
        
        print(self.images.count)
    }
    
    func addImgToArray(uploadImage:UIImage)
    {
        self.images.append(uploadImage)
        
        
    }

    func willEnterForeground(_ notification: NSNotification!) {
        // do whatever you want when the app is brought back to the foreground
        self.getPhotos()
    }
    
    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // self.FetchCustomAlbumPhotos()
        self.getPhotos()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

