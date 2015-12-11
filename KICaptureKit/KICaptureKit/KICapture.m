//
//  KICapture.m
//  Kitalker
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KICapture.h"

@interface KICapture() {
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, copy) dispatch_queue_t captureQueue;

@property (nonatomic, copy) KICaptureDidStartRunningBlock       didStartRunningBlock;
@property (nonatomic, copy) KICaptureDidStopRunningBlock        didStopRunningBlock;

@property (nonatomic, assign) BOOL statusBeforeHibernate;
@end

@implementation KICapture

- (void)dealloc {
    _captureQueue = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        _session = [[AVCaptureSession alloc] init];
        _captureQueue = dispatch_queue_create("smartwalle.capture", DISPATCH_QUEUE_SERIAL);
        _availableDevice = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.statusBeforeHibernate = [self isRunning];
    [self stopRunning];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.statusBeforeHibernate) {
        [self startRunning];
    }
}

- (void)setCaptureDidStartRunningBlock:(KICaptureDidStartRunningBlock)block {
    [self setDidStartRunningBlock:block];
}

- (void)setCaptureDidStopRunningBlock:(KICaptureDidStopRunningBlock)block {
    [self setDidStopRunningBlock:block];
}

- (void)addDevice:(id<KICaptreDevice>)device {
    if (device == nil) {
        return ;
    }
    
    if ([self.availableDevice containsObject:device]) {
        return ;
    }
    
    [self.availableDevice addObject:device];
    
    [self.session beginConfiguration];
    [device setSession:self.session queue:self.captureQueue];
    [self.session commitConfiguration];
}

- (void)removeDevice:(id<KICaptreDevice>)device {
    if (device == nil) {
        return ;
    }
    
    if (![self.availableDevice containsObject:device]) {
        return ;
    }
    [self.availableDevice removeObject:device];
    
    AVCaptureDeviceInput *deviceInput = [device deviceInput];
    AVCaptureOutput *dataOutput = [device dataOutput];
    
    if (deviceInput != nil) {
        [self.session removeInput:deviceInput];
    }
    
    if (dataOutput != nil) {
        [self.session removeOutput:dataOutput];
    }
}

- (void)startRunning {
    [self.session startRunning];
    if (self.didStartRunningBlock) {
        self.didStartRunningBlock();
    }
}

- (void)stopRunning {
    [self.session stopRunning];
    if (self.didStopRunningBlock) {
        self.didStopRunningBlock();
    }
}

- (BOOL)isRunning {
    return self.session.isRunning;
}

@end
