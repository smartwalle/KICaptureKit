//
//  ViewController.m
//  KICaptureKit
//
//  Created by apple on 15/12/10.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "ViewController.h"
#import "KICapture.h"

@interface ViewController ()
@property (nonatomic, strong) KICapture *capture;
@property (nonatomic, strong) KIQRCode  *qrCode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak ViewController *weakSelf = self;
    [KIQRCode requestAccessForCamera:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.capture addDevice:weakSelf.qrCode];
            [weakSelf.qrCode setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeEAN13Code]];
            [weakSelf.view.layer addSublayer:weakSelf.qrCode.previewLayer];
            [weakSelf.qrCode.previewLayer setFrame:weakSelf.view.bounds];
            [weakSelf.capture startRunning];
            
            [weakSelf.qrCode setCaptureDidOutputMetadataObjectsBlock:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection) {
                
                if ([metadataObjects count] > 0) {
                    AVMetadataObject *obj = [metadataObjects firstObject];
                    if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                        AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)obj;
                        NSLog(@"%@", codeObject.stringValue);
                    }
                }
                
                
            }];
        });
        
    }];
}

- (KICapture *)capture {
    if (_capture == nil) {
        _capture = [[KICapture alloc] init];
    }
    return _capture;
}

- (KIQRCode *)qrCode {
    if (_qrCode == nil) {
        _qrCode = [[KIQRCode alloc] initWithPosition:KICameraPositionBack];
        [_qrCode setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    return _qrCode;
}

@end
