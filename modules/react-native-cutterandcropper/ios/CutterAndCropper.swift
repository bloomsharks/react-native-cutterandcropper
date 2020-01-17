////
////  CropperView.swift
////  bloomTest23
////
////  Created by Nika Samadashvili on Dec/26/19.
////  Copyright © 2019 Facebook. All rights reserved.
////
//
//
//import UIKit
//import CropViewController
//
//class CutterAndCropper: UIView {
//
//  var controller: EmbededController!
//
//  @objc var onDone: RCTDirectEventBlock?
//  @objc var proportion: NSString?
//  @objc var meiaTypeEnum: NSString?
//
//
//  @objc func didPressStart(_ gesture: UITapGestureRecognizer) {
//     embedController()
//
//  }
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    self.addSubview(button)
//  }
//
//  override func didMoveToSuperview() {
//    super.didMoveToSuperview()
//
//  }
//
//  func embedController(){
//    self.controller = EmbededController()
//    controller.imageType = proportion as String?
//    self.reactViewController()?.addChild(controller)
//
//    // Add the child's View as a subview
//    self.addSubview(controller.view)
//    self.reactViewController().view.frame = self.bounds
//    //make embedController as self
//    controller.delegate = self
//
//    // tell the childviewcontroller it's contained in it's parent
//    controller.didMove(toParent: reactViewController())
//  }
//
//
//
//  lazy var button: UIButton = {[weak self] in
//    let button = UIButton.init(type: UIButton.ButtonType.system)
//
//    button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
//    button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    button.setTitle("Start", for: .normal)
//    button.addTarget(
//      self,
//      action: #selector(didPressStart(_:)),
//      for: .touchUpInside
//    )
//    return button
//    }()
//
//
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//}
//
//extension CutterAndCropper : EmbededControllerDelegate{
//  func ImageMeta(Data: [String : Any]) {
//   if onDone != nil {
//            onDone!(Data)
//         }
//  }
//
//
//}
