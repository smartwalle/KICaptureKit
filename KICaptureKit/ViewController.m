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
    
    self.codeScanView = [[KICodeScanView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.codeScanView];
    
    KIScanMaskView *maskView = [[KIScanMaskView alloc] init];
    [maskView setMaskColor:[UIColor redColor]];
    [maskView setBorderImage:[UIImage imageNamed:@"scan_box.png"]];
    [maskView setScanLineImage:[UIImage imageNamed:@"scan_line.png"]];
    [maskView setScanLineHeight:15];
    [maskView setBorderColor:[UIColor clearColor]];
    [maskView setScanRect:rect];
    [self.codeScanView setScanMaskView:maskView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect rect = CGRectMake(10, 10, 200, 100);
    __weak ViewController *weakSelf = self;
    
    [self.codeScanView.codeScanner setMetadataObjectTypesBlock:^NSArray *(KICodeScanner *codeScanner) {
        return [codeScanner availableMetadataObjectTypes];
    }];
    
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
