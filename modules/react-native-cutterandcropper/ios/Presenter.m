//
//  Presenter.m
//  Cutterandcropper
//
//  Created by Nika Samadashvili on Jan/15/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>


@interface RCT_EXTERN_MODULE(Presenter, NSObject)

RCT_EXTERN_METHOD(presentImagePicker:(NSString *)mediaType proportion:(NSString *)proportion  resolver:(RCTPromiseResolveBlock)resolve
   rejecter:(RCTPromiseRejectBlock)reject)
@end
