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
final class Presenter : NSObject{
    
    var resolver: RCTPromiseResolveBlock!
    var rejecter: RCTPromiseRejectBlock!
    
    @objc func presentImagePicker(_ mediaType: String, property: String, skip:Bool, resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock){
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            
            let embededController = EmbededController()
            embededController.delegate = self
            embededController.property = property
            embededController.mediaType = mediaType
            embededController.skipEditing = skip
            
            let navigationController = UINavigationController(rootViewController: embededController)
            navigationController.modalPresentationStyle = .fullScreen
            
            let curentViewController = RCTPresentedViewController()
            curentViewController!.present(navigationController, animated: true, completion: nil)
            self.resolver = resolve
            self.rejecter = reject
            
            guard #available(iOS 12, *) else{
                return
            }
            RCTKeyWindow()?.backgroundColor = .white
        }
    }
    
}

extension Presenter : EmbededControllerDelegate{
    func emitMeta(error: [String : Error]) {
        self.rejecter("error", error["error"]?.localizedDescription ,error["error"])
    }
    
    func emitMeta(data: [String : Any]) {
        self.resolver(data)
        RCTPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
}
