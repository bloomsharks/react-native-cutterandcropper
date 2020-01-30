//
//  weirdController.swift
//  bloomTest23
//
//  Created by Nika Samadashvili on Dec/27/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import AVFoundation

protocol EmbededControllerDelegate : class {
    func Meta(data: [String:Any])
}

class EmbededController : UIViewController,CropViewControllerDelegate,VideoCutterDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @objc var onDone: RCTDirectEventBlock?
    private var image : UIImage?
    private var imageUri : String?
    private var compressionQuality : CGFloat = 0.6
     var imagePicker = UIImagePickerController()
    
    
    private let randomInt = Int.random(in: 0..<100000)
    var imageType : String!
    var mediaType : String!
    var skipEditing : Bool!
    
    weak var delegate : EmbededControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      view.isHidden = true
      presentImagePicker()
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if mediaType == "photo"{
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            guard skipEditing != true else{
                saveImage(image: image)
                emitMetaData(of: image)
                return
            }
            let cropController = setupCropController(with: image)
            self.navigationController?.pushViewController(cropController, animated: true)
            
        }else if mediaType == "video"{
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                guard skipEditing != true else{
                    self.delegate?.Meta(data: ["uri":videoURL.absoluteString])
                    return
                }
                let videoCutterController = VideoCutterController()
                videoCutterController.delegate = self
                videoCutterController.modalPresentationStyle = .fullScreen
                videoCutterController.url = videoURL.absoluteURL
                self.navigationController?.pushViewController(videoCutterController, animated: true)
            }
        }else{
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                saveImage(image: image)
                emitMetaData(of: image)
            }else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                self.delegate?.Meta(data: ["uri":videoURL.absoluteString])
            }
        }
        
        //    self.image = image
        
        //   self.navigationController?.pushViewController(cropController, animated: true)
        
    }
    
    
    func setupCropController(with image:UIImage) -> CropViewController{
        
        let cropController = CropViewController(croppingStyle: .default, image: image)
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
        return cropController
    }
    
    func presentImagePicker(){
                     let imagePicker = UIImagePickerController()
                     imagePicker.allowsEditing = false
                     imagePicker.delegate = self
                     if #available(iOS 11.0, *) {
                         imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
                     }
                    
                     if mediaType == "image"{
                         imagePicker.mediaTypes = ["public.image"]
                     }else if mediaType == "video"{
                         imagePicker.mediaTypes = ["public.movie"]
                     }else{
                         imagePicker.mediaTypes = ["public.movie","public.image"]
                     }
                     
                     
                     self.navigationController?.setNavigationBarHidden(true, animated: false)
                     
                     imagePicker.willMove(toParent: self.navigationController)
                     self.navigationController!.addChild(imagePicker)
                     imagePicker.view.frame = self.view.frame
                     self.navigationController!.view.addSubview(imagePicker.view)
                     imagePicker.didMove(toParent: self.navigationController!)
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
    
    
   private func emitMetaData(of image:UIImage){
        let height : Any = image.size.height * image.scale
        let width : Any = image.size.width * image.scale
        let fileName : Any = "\(self.randomInt).jpg"
        let fileSize : Any = image.jpegData(compressionQuality: self.compressionQuality )?.count ?? 0
        let uri : Any = self.imageUri ?? "nil"
        let type : String = "image/jpeg"
        
        self.delegate?.Meta(data: ["height" : height,"width" : width,"fileName" :  fileName,"fileSize" : fileSize,"uri" : uri,"type" : type])
    }
    
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.saveImage(image: image)
        self.emitMetaData(of:image)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        //    self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didCancelController() {
    self.navigationController?.popToRootViewController(animated: true)
      presentImagePicker()
             
    }
    
}
