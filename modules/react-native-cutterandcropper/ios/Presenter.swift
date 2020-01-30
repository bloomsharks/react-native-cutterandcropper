//
//  Presenter.swift
//  Cutterandcropper
//
//  Created by Nika Samadashvili on Jan/15/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import UIKit
//import CropViewController



@objc(Presenter)
class Presenter : NSObject, EmbededControllerDelegate{
    
    var resolver: RCTPromiseResolveBlock!
    
    @objc func presentImagePicker(_ mediaType: String, proportion: String, skip:Bool, resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock){
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            
            let embededController = EmbededController()
            embededController.delegate = self
            embededController.imageType = proportion
            embededController.mediaType = mediaType
            embededController.skipEditing = skip
            
            let navigationController = UINavigationController(rootViewController: embededController)
            navigationController.modalPresentationStyle = .fullScreen
            
            let curentViewController = RCTPresentedViewController()
            curentViewController!.present(navigationController, animated: true, completion: nil)
            self.resolver = resolve
            
            guard #available(iOS 12, *) else{
                return
            }
            RCTKeyWindow()?.backgroundColor = .white
        }
    }
    
    
    func Meta(data: [String : Any]) {
        self.resolver(data)
        RCTPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
    
}
