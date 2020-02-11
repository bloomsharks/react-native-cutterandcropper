
//
//  Created by Nika Samadashvili on Dec/27/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import AVFoundation

protocol EmbededControllerDelegate : class {
    func emitMeta(data: [String:Any])
    func emitMeta(error:[String:Error])
}

final class EmbededController : UIViewController{
    var imagePicker : UIImagePickerController!
    
    private var image : UIImage?
    //it can be picked Image from UIImagePicker as well as videoThumbnail
    private var imageUri : String?
    private var compressionQuality : CGFloat = 0.6
    
    private let randomInt = Int.random(in: 0..<100000)
    var property : String!
    var mediaType : String!
    var skipEditing : Bool!
    
    weak var delegate : EmbededControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        presentImagePicker()
    }
    
    
    
    private func setupCropController(with image: UIImage) -> CropViewController{
        let cropController = CropViewController(croppingStyle: .default, image: image)
        cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        cropController.toolbarPosition = .top
        cropController.cancelButtonTitle = ""
        
        
        if property == "profile"{ cropController.customAspectRatio = CGSize(width: 1, height: 1) }
        if property == "cover" {cropController.customAspectRatio = CGSize(width: 343, height: 136)}
        if property == "post"{
            if image.size.height >= image.size.width{
                cropController.customAspectRatio = CGSize(width: 3, height: 4)
            }else{
                cropController.customAspectRatio = CGSize(width: 4, height: 3)
            }
        }
        if  property.contains("X"){
            let dimentions = property.components(separatedBy: "X")
            if let width = Int(dimentions[0]),let height = Int(dimentions[1]){
                 cropController.customAspectRatio = CGSize(width: width, height: height)
            }else{
                 cropController.customAspectRatio = CGSize(width: 1, height: 1)
            }
        }
        else{cropController.customAspectRatio = CGSize(width: 1, height: 1)}
        
        return cropController
    }
    
    private func setupVideoCutterController(with videoURL: String) -> VideoCutterController{
        let videoMaxDuration = Double(property) ?? 90
        let videoCutterController = VideoCutterController()
        videoCutterController.delegate = self
        videoCutterController.assetURL = videoURL
        videoCutterController.videoMaxDuration = videoMaxDuration
        return videoCutterController
    }
    
    private func presentImagePicker(){
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        if #available(iOS 11.0, *) {
            imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
        }
        if mediaType == "photo"{
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
    
    
    private func saveImage(image: UIImage,withName fileName:String) {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
        let targetURL = tempDirectoryURL.appendingPathComponent("\(fileName).jpg")
        
        if let data = image.jpegData(compressionQuality: compressionQuality) {
            do {
                try data.write(to: targetURL)
                self.imageUri = targetURL.absoluteString
            } catch let error {
                self.imageUri = error.localizedDescription
            }
        }
    }
    
    
    private func emitMetaData(of url:URL, withName fileName:String){
        let cuttedAsset = AVAsset(url:url)
        let thumbGenerator = AVAssetImageGenerator(asset: cuttedAsset)
        thumbGenerator.appliesPreferredTrackTransform = true
        let cgImage : CGImage?
        do{
            cgImage = try thumbGenerator.copyCGImage(at: CMTimeMake(value: 5, timescale: 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage!)
            self.saveImage(image: image,withName:fileName)
            
            let thumbnailURL : String = imageUri ?? ""
            let thumbnailImg : UIImage = UIImage(cgImage: cgImage!)
            let height : Any = abs(thumbnailImg.size.height * image.scale)
            let width : Any = abs(thumbnailImg.size.width * image.scale)
            let mimeType : String = "video/mp4"
            let fileName : String = "\(fileName).mp4"
            
            self.delegate?.emitMeta(data: ["width":width,"height":height,"uri": url.absoluteString,"thumbnail": thumbnailURL, "type":mimeType,"isTemporary":true,"fileName":fileName])
        }catch{
            self.delegate?.emitMeta(error: ["error":error])
        }
    }
    
    
    private func emitMetaData(of image:UIImage){
        let height : Any = image.size.height * image.scale
        let width : Any = image.size.width * image.scale
        let fileName : Any = "\(self.randomInt).jpg"
        let fileSize : Any = image.jpegData(compressionQuality: self.compressionQuality )?.count ?? 0
        let uri : Any = self.imageUri ?? "nil"
        let type : String = "image/jpeg"
        
        self.delegate?.emitMeta(data: ["height" : height,"width" : width,"fileName" :  fileName,"fileSize" : fileSize,"uri" : uri,"type" : type])
    }
    
    deinit{
        imagePicker.removeFromParent()
    }
}

extension EmbededController : VideoCutterDelegate {
    
    func didfinishWith(error: [String : Error]) {
        self.navigationController?.dismiss(animated: false, completion: {[weak self] in
            self?.delegate?.emitMeta(error: error)
        })
    }
    
    func didfinishWith(data: [String : Any]) {
        self.navigationController?.dismiss(animated: false, completion: {[weak self] in
            if let url = data["uri"] as? URL, let randomInt = data["randomInt"] as? Int{
                let stringifiedRandomInt = String(randomInt)
                print(url,randomInt)
                self?.emitMetaData(of: url,withName: stringifiedRandomInt)
            }
        })
    }
    
    func didCancelController() {
        self.navigationController?.popToRootViewController(animated: true)
        presentImagePicker()
    }
}


extension EmbededController : CropViewControllerDelegate{
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let stringifiedRandomInt = String(randomInt)
        self.saveImage(image: image, withName: stringifiedRandomInt)
        self.emitMetaData(of:image)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension EmbededController :  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if mediaType == "photo"{
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            guard skipEditing != true else{
                let stringifiedRandomInt = String(randomInt)
                saveImage(image: image, withName: stringifiedRandomInt)
                emitMetaData(of: image)
                return
            }
            let cropController = setupCropController(with: image)
            self.navigationController?.pushViewController(cropController, animated: true)
            
        }else if mediaType == "video"{
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                guard skipEditing != true else{
                    let stringifiedRandomInt = String(self.randomInt)
                    self.emitMetaData(of: videoURL,withName: stringifiedRandomInt)
                    return
                }
                let videoCutterController = setupVideoCutterController(with: videoURL.absoluteString)
                self.navigationController?.pushViewController(videoCutterController, animated: true)
            }
        }else{
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                let stringifiedRandomInt = String(randomInt)
                saveImage(image: image, withName: stringifiedRandomInt)
                emitMetaData(of: image)
            }else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                self.delegate?.emitMeta(data: ["uri":videoURL.absoluteString])
            }
        }
    }
}
