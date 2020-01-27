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
    func didCancelEmbededController()
}

class EmbededController : UIViewController,CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc var onDone: RCTDirectEventBlock?
    private var image : UIImage?
    private var imagePicker : UIImagePickerController!
    private var cropController : CropViewController!
    private var imageUri : String?
    private var compressionQuality : CGFloat = 0.6
    
    private let randomInt = Int.random(in: 0..<100000)
    var imageType : String!
    
    weak var delegate : EmbededControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0
        self.imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.modalPresentationStyle = .fullScreen
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
            cropController.customAspectRatio = CGSize(width: 1, height: 1)
        }
        
        self.image = image
      
        imagePicker.dismiss(animated: true) {
            self.present(self.cropController, animated: true)
        }
    }
    
    private func saveImage(image: UIImage) {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
        let targetURL = tempDirectoryURL.appendingPathComponent("\(randomInt).jpg")
        
        if let data = image.jpegData(compressionQuality: compressionQuality) {
            do {
                try data.write(to: targetURL)
                self.imageUri = targetURL.absoluteString
            } catch let error {
                self.imageUri = error.localizedDescription
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // image variable is the newly cropped version of the original image
        cropViewController.dismiss(animated: true) {[weak self] in
            
            self?.saveImage(image: image)
            
            let height : Any = image.size.height * image.scale
            let width : Any = image.size.width * image.scale
            let fileName : Any = "\(self?.randomInt ?? 0).jpg"
            let fileSize : Any = image.jpegData(compressionQuality: self?.compressionQuality ?? 1)?.count ?? 0
            let uri : Any = self?.imageUri ?? "nil"
            let type : String = "image/jpeg"
            
            self?.delegate?.ImageMeta(data: ["height" : height,"width" : width,"fileName" :  fileName,"fileSize" : fileSize,"uri" : uri,"type" : type])
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        self.delegate?.didCancelEmbededController()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.didCancelEmbededController()
    }
    
}
