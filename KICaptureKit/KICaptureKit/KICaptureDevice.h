//
//  KICaptureDevice.h
//  Kitalker
//
//  Created by apple on 15/6/24.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^KICaptureDidOutputSampleBufferBlock)      (AVCaptureOutput *captureOutput, CMSampleBufferRef sampleBuffer, AVCaptureConnection *connection);
typedef void(^KICaptureDidOutputMetadataObjectsBlock)   (AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection);

////////////////////////////////////////////////////////////////////////////////
@protocol KICaptreDevice <NSObject>

@required
- (void)setSession:(AVCaptureSession *)session queue:(dispatch_queue_t)queue;
- (AVCaptureDeviceInput *)deviceInput;
- (AVCaptureOutput *)dataOutput;

@optional
- (AVCaptureDevice *)device;

@end

////////////////////////////////////////////////////////////////////////////////
@interface KIBaseCaptureDevice : NSObject {
    
}
- (AVCaptureDevice *)device;
- (AVCaptureDeviceInput *)deviceInput;
- (AVCaptureOutput *)dataOutput;

+ (void)requestAccessForMediaType:(NSString *)mediaType
                completionHandler:(void(^)(BOOL granted))block;

+ (AVAuthorizationStatus)authorizationStatusForMediaType:(NSString *)mediaType;

@end

////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, KICameraPosition) {
    KICameraPositionBack    = 1,
    KICameraPositionFront   = 2,
};

@interface KICamera : KIBaseCaptureDevice <KICaptreDevice>

@property (nonatomic) AVCaptureVideoOrientation     videoOrientation;
@property (nonatomic) AVCaptureVideoPreviewLayer    *previewLayer;

- (instancetype)initWithPosition:(KICameraPosition)position;

- (void)setCaptureDidOutputSampleBufferBlock:(KICaptureDidOutputSampleBufferBlock)block;

- (void)setVideoSetting:(NSDictionary *)setting;

- (KICameraPosition)cameraPosition;


+ (void)requestAccessForCamera:(void(^)(BOOL granted))block;

+ (AVAuthorizationStatus)authorizationStatusForCamera;

@end

////////////////////////////////////////////////////////////////////////////////
@interface KIQRCode : KICamera <KICaptreDevice>

// 添加到 KICapture 之后才设置相应的 type
@property(nonatomic, copy) NSArray *metadataObjectTypes;

@property(nonatomic, readonly) NSArray *availableMetadataObjectTypes;

- (void)setCaptureDidOutputMetadataObjectsBlock:(KICaptureDidOutputMetadataObjectsBlock)block;

- (void)setRectOfInterest:(CGRect)rect;

@end

////////////////////////////////////////////////////////////////////////////////
@interface KIMicrophone : KIBaseCaptureDevice <KICaptreDevice>

- (void)setCaptureDidOutputSampleBufferBlock:(KICaptureDidOutputSampleBufferBlock)block;


+ (void)requestAccessForMicrophone:(void(^)(BOOL granted))block;

+ (AVAuthorizationStatus)authorizationStatusForMicrophone;

@end
