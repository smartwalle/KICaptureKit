//
//  KICapture.h
//  Kitalker
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KICaptureDevice.h"

typedef void(^KICaptureDidStartRunningBlock)    ();
typedef void(^KICaptureDidStopRunningBlock)     ();

@interface KICapture : NSObject

@property (nonatomic, strong) NSMutableArray *availableDevice;

- (instancetype)init;


- (void)setCaptureDidStartRunningBlock:(KICaptureDidStartRunningBlock)block;

- (void)setCaptureDidStopRunningBlock:(KICaptureDidStopRunningBlock)block;


- (void)addDevice:(id<KICaptreDevice>)device;

- (void)removeDevice:(id<KICaptreDevice>)device;


- (void)startRunning;

- (void)stopRunning;

- (BOOL)isRunning;

@end
