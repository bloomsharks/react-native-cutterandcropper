//
//  weirdController.swift
//  bloomTest23
//
//  Created by Nika Samadashvili on Dec/27/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
//import CropViewController

protocol EmbededControllerDelegate : class {
  func ImageMeta(data: [String:Any])
}

class EmbededController : UIViewController,CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
 @objc var onDone: RCTDirectEventBlock?
  private var image : UIImage?
  private var imagePicker : UIImagePickerController!
  private var cropController : CropViewController!
  var imageType : String!
  
  weak var delegate : EmbededControllerDelegate?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    layoutImageView()
    self.imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = false
    imagePicker.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
    
    self.cropController = CropViewController(croppingStyle: .default, image: image)
    cropController.modalPresentationStyle = .fullScreen
    cropController.delegate = self
    cropController.toolbarPosition = .top
    cropController.cancelButtonTitle = ""

   
    
    switch imageType{
    case "profile":
      cropController.customAspectRatio = CGSize(width: 1, height: 1)
    case "cover":
      cropController.customAspectRatio = CGSize(width: 343, height: 136)
    case "post":
      if image.size.height >= image.size.width{
        cropController.customAspectRatio = CGSize(width: 3, height: 4)
      }else{
        cropController.customAspectRatio = CGSize(width: 4, height: 3)
      }
    default:
        cropController.customAspectRatio = CGSize(width: 343, height: 136)
    //  fatalError("invalid proportion")
    }
    
    self.image = image
    
    imagePicker.dismiss(animated: true) {
      self.present(self.cropController, animated: true)
    }
  }
  
  private func saveImage(image: UIImage, withName name: String) {
    
    let data : Data = image.jpegData(compressionQuality: 1.0)!
    let fileManager: FileManager = FileManager.default
    let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
    guard  fullPath != nil else {
      return
    }
    if fileManager.fileExists(atPath: fullPath!.absoluteString) {
      // deletion of file
      try? fileManager.removeItem(atPath: fullPath!.absoluteString)
    }
    fileManager.createFile(atPath: fullPath!.absoluteString, contents: data, attributes: nil)
  }
  
  private func layoutImageView() {
//    self.view.addSubview(imageView)
//    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
//    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
//    imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
//    imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
  }
  
  func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
    // image variable is the newly cropped version of the original image
    cropViewController.dismiss(animated: true) {
     // self.imageView.image = image
      self.saveImage(image: image, withName: self.imageType)
     
      let height : Any = image.size.height * image.scale
      let width : Any = image.size.width * image.scale
      let fileName : Any = self.imageType ?? "nil"
      let fileSize : Any = image.jpegData(compressionQuality: 1)?.count ?? 0
      let uri : Any = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent((self.imageType ?? "nil"))?.absoluteString ?? "nil"
      let type : String = "image/jpeg"
     
      self.delegate?.ImageMeta(data: ["height" : height,"width" : width,"fileName" :  fileName,"fileSize" : fileSize,"uri" : uri,"type" : type])
    }
  }
}
