//
//  ViewController.m
//  KICaptureKit
//
//  Created by apple on 15/12/10.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "ViewController.h"
#import "KICodeScanView.h"

@interface ViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) KICodeScanView *codeScanView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(10, 10, 200, 100);
    
    self.codeScanView = [[KICodeScanView alloc] initWithFrame:self.view.bounds scanRect:rect];
    [self.codeScanView.scanMaskView setBorderWidth:2];
    [self.codeScanView.scanMaskView setBorderColor:[UIColor redColor]];
    [self.view addSubview:self.codeScanView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect rect = CGRectMake(10, 10, 200, 100);
    __weak ViewController *weakSelf = self;
    
//    [self.codeScanView.codeScanner setMetadataObjectTypesBlock:^NSArray *(KICodeScanner *codeScanner) {
//        return [NSArray arrayWithObject:AVMetadataObjectTypeEAN13Code];
//    }];
    
    [self.codeScanView.codeScanner setRectOfInterestBlock:^CGRect(KICodeScanner *codeScanner) {
        return rect;
    }];
    
    [self.codeScanView.codeScanner setCaptureDidOutputMetadataObjectsBlock:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([metadataObjects count] > 0) {
                [weakSelf.codeScanView stopRunning];
                
                AVMetadataObject *obj = [metadataObjects firstObject];
                if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                    AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)obj;
                    NSLog(@"%@", codeObject.stringValue);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:codeObject.stringValue delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }];
    
    [self.codeScanView prepareToScan];
    
    [self.codeScanView startRunning];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.codeScanView startRunning];
}

@end
