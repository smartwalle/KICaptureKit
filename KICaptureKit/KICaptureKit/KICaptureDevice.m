//
//  KICaptureDevice.m
//  Kitalker
//
//  Created by apple on 15/6/24.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KICaptureDevice.h"
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
@interface KIBaseCaptureDevice ()
@property (nonatomic, strong) AVCaptureDevice               *device;
@property (nonatomic, strong) AVCaptureDeviceInput          *deviceInput;
@property (nonatomic, strong) AVCaptureOutput               *dataOutput;
@end

@implementation KIBaseCaptureDevice

- (AVCaptureDevice *)device {
    return _device;
}

- (AVCaptureDeviceInput *)deviceInput {
    return _deviceInput;
}

- (AVCaptureOutput *)dataOutput {
    return _dataOutput;
}

+ (void)requestAccessForMediaType:(NSString *)mediaType completionHandler:(void(^)(BOOL granted))block {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            block(granted);
        }];
    } else {
        block(YES);
    }
}

+ (AVAuthorizationStatus)authorizationStatusForMediaType:(NSString *)mediaType {
    return [AVCaptureDevice authorizationStatusForMediaType:mediaType];
}

@end

////////////////////////////////////////////////////////////////////////////////
@interface KICamera () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, assign) KICameraPosition                  cameraPosition;
@property (nonatomic, copy) KICaptureDidOutputSampleBufferBlock didOutputSampleBufferBlock;
@end

@implementation KICamera

- (instancetype)init {
    if (self = [super init]) {
        self.cameraPosition = KICameraPositionBack;
        [self setupWithPosition:self.cameraPosition];
    }
    return self;
}

- (instancetype)initWithPosition:(KICameraPosition)position {
    if (self = [super init]) {
        self.cameraPosition = position;
        [self setupWithPosition:self.cameraPosition];
    }
    return self;
}

- (void)setupWithPosition:(KICameraPosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    self.device = self.cameraPosition == KICameraPositionBack ? devices.firstObject : devices.lastObject;
    
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];
    [videoSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [self setVideoSetting:videoSettings];
    
    [self updateVideoOrientation];
}

- (void)setVideoSetting:(NSDictionary *)setting {
    AVCaptureVideoDataOutput *output = (AVCaptureVideoDataOutput *)self.dataOutput;
    [output setVideoSettings:setting];
}

- (KICameraPosition)cameraPosition {
    return _cameraPosition;
}

- (void)updateVideoOrientation {
    AVCaptureVideoOrientation videoOrientation = self.videoOrientation;
    
    AVCaptureConnection *outputConnection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureConnection *previewConnection = [self.previewLayer connection];
    
    [outputConnection setVideoOrientation:videoOrientation];
    [previewConnection setVideoOrientation:videoOrientation];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    [self updateVideoOrientation];
}

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    _previewLayer = previewLayer;
    [self updateVideoOrientation];
}

- (void)setSession:(AVCaptureSession *)session queue:(dispatch_queue_t)queue {
    AVCaptureDeviceInput *deviceInput = [self deviceInput];
    AVCaptureVideoDataOutput *dataOutput = (AVCaptureVideoDataOutput *)[self dataOutput];
    if (deviceInput == nil || dataOutput == nil) {
        return ;
    }
    if (![session canAddInput:deviceInput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add device input", self);
#endif
        return ;
    }
    
    if (![session canAddOutput:dataOutput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add data output", self);
#endif
        return ;
    }
    
    [session addInput:deviceInput];
    [session addOutput:dataOutput];
    
    [dataOutput setSampleBufferDelegate:self queue:queue];
    
    AVCaptureVideoPreviewLayer *cameraPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [cameraPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self setPreviewLayer:cameraPreviewLayer];
}

- (void)setCaptureDidOutputSampleBufferBlock:(KICaptureDidOutputSampleBufferBlock)block {
    [self setDidOutputSampleBufferBlock:block];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.didOutputSampleBufferBlock != nil) {
        self.didOutputSampleBufferBlock(captureOutput, sampleBuffer, connection);
    }
}

+ (void)requestAccessForCamera:(void(^)(BOOL granted))block {
    [KICamera requestAccessForMediaType:AVMediaTypeVideo completionHandler:block];
}

+ (AVAuthorizationStatus)authorizationStatusForCamera {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

@end

////////////////////////////////////////////////////////////////////////////////
@interface KIQRCode () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, copy) KICaptureDidOutputMetadataObjectsBlock didOutputMetadataObjectsBlock;
@end

@implementation KIQRCode

- (instancetype)init {
    if (self = [super initWithPosition:KICameraPositionBack]) {
    }
    return self;
}

- (instancetype)initWithPosition:(KICameraPosition)position {
    if (self = [super initWithPosition:KICameraPositionBack]) {
    }
    return self;
}

- (void)setupWithPosition:(KICameraPosition)position {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    self.dataOutput = metadataOutput;
    [self setMetadataObjectTypes:[metadataOutput availableMetadataObjectTypes]];
    
    [self updateVideoOrientation];
}

- (void)setSession:(AVCaptureSession *)session queue:(dispatch_queue_t)queue {
    AVCaptureDeviceInput *deviceInput = [self deviceInput];
    AVCaptureMetadataOutput *dataOutput = (AVCaptureMetadataOutput *)[self dataOutput];
    if (deviceInput == nil || dataOutput == nil) {
        return ;
    }
    if (![session canAddInput:deviceInput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add device input", self);
#endif
        return ;
    }
    
    if (![session canAddOutput:dataOutput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add data output", self);
#endif
        return ;
    }
    [session addInput:deviceInput];
    [session addOutput:dataOutput];

    [dataOutput setMetadataObjectsDelegate:self queue:queue];
    
    AVCaptureVideoPreviewLayer *cameraPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [cameraPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self setPreviewLayer:cameraPreviewLayer];
}

- (void)setRectOfInterest:(CGRect)rect {
    AVCaptureMetadataOutput *dataOutput = (AVCaptureMetadataOutput *)[self dataOutput];
    [dataOutput setRectOfInterest:rect];
}

- (void)setCaptureDidOutputMetadataObjectsBlock:(KICaptureDidOutputMetadataObjectsBlock)block {
    [self setDidOutputMetadataObjectsBlock:block];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (self.didOutputMetadataObjectsBlock != nil) {
        self.didOutputMetadataObjectsBlock(captureOutput, metadataObjects, connection);
    }
}

- (NSArray *)metadataObjectTypes {
    AVCaptureMetadataOutput *dataOutput = (AVCaptureMetadataOutput *)[self dataOutput];
    return dataOutput.metadataObjectTypes;
}

- (void)setMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    AVCaptureMetadataOutput *dataOutput = (AVCaptureMetadataOutput *)[self dataOutput];
    [dataOutput setMetadataObjectTypes:metadataObjectTypes];
}

- (NSArray *)availableMetadataObjectTypes {
    AVCaptureMetadataOutput *dataOutput = (AVCaptureMetadataOutput *)[self dataOutput];
    return [dataOutput availableMetadataObjectTypes];
}

@end


////////////////////////////////////////////////////////////////////////////////
@interface KIMicrophone () <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, copy) KICaptureDidOutputSampleBufferBlock didOutputSampleBufferBlock;
@end

@implementation KIMicrophone
- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.dataOutput = [[AVCaptureAudioDataOutput alloc] init];
}

- (void)setSession:(AVCaptureSession *)session queue:(dispatch_queue_t)queue {
    AVCaptureDeviceInput *deviceInput = [self deviceInput];
    AVCaptureAudioDataOutput *dataOutput = (AVCaptureAudioDataOutput *)[self dataOutput];
    if (deviceInput == nil || dataOutput == nil) {
        return ;
    }
    if (![session canAddInput:deviceInput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add device input", self);
#endif
        return ;
    }
    
    if (![session canAddOutput:dataOutput]) {
#ifdef DEBUG
        NSLog(@"%@: can't add data output", self);
#endif
        return ;
    }
    
    [session addInput:deviceInput];
    [session addOutput:dataOutput];
    
    [dataOutput setSampleBufferDelegate:self queue:queue];
}

- (void)setCaptureDidOutputSampleBufferBlock:(KICaptureDidOutputSampleBufferBlock)block {
    [self setDidOutputSampleBufferBlock:block];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.didOutputSampleBufferBlock != nil) {
        self.didOutputSampleBufferBlock(captureOutput, sampleBuffer, connection);
    }
}

+ (void)requestAccessForMicrophone:(void (^)(BOOL))block {
    [KIMicrophone requestAccessForMediaType:AVMediaTypeAudio completionHandler:block];
}

+ (AVAuthorizationStatus)authorizationStatusForMicrophone {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
}

@end
