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
class Presenter : NSObject,EmbededControllerDelegate {
    
    var data : [String:Any]?
    var controller: EmbededController!
    var resolver: RCTPromiseResolveBlock!
    
    @objc func presentImagePicker(_ mediaType: String, proportion: String, resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock){
        
        DispatchQueue.main.async {
            self.controller = EmbededController()
            let curentViewController = RCTPresentedViewController()
            
            self.controller.delegate = self
            self.controller.imageType = proportion
            
            print(proportion,mediaType)
            curentViewController!.present(self.controller, animated: true, completion: nil)
            self.resolver = resolve
            guard #available(iOS 12, *) else{
                return
            }
            RCTKeyWindow()?.backgroundColor = .white
        }
    }
    
    func didCancelEmbededController() {
        RCTPresentedViewController()?.dismiss(animated: true, completion: {
        RCTPresentedViewController()?.dismiss(animated: true, completion: nil)
        })
    
    }
    
    func ImageMeta(data: [String : Any]) {
        self.data = data
        self.resolver(data)
        RCTPresentedViewController()?.dismiss(animated: true, completion: nil)
    }
    
}
