//
//  KIVideoEncoder.h
//  Kitalker
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^KIVideoEncoderDidStartWritingBlock) (BOOL success);
typedef void (^KIVideoEncoderDidFinishWritingBlock) (BOOL success);

@interface KIVideoEncoder : NSObject

@property (nonatomic, copy) NSString *path;

- (void)setVideoEncoderDidStartWritingBlock:(KIVideoEncoderDidStartWritingBlock)block;

- (void)setVideoEncoderDidFinishWritingBlock:(KIVideoEncoderDidFinishWritingBlock)block;

- (void)setVideoWidth:(int)width height:(int)height;

- (BOOL)prepareToWriting;

- (BOOL)startWriting;

- (BOOL)isWriting;

- (void)cancelWriting;

- (void)finishWriting;

- (void)encodeWithOutput:(AVCaptureOutput *)captureOutput
   didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
          fromConnection:(AVCaptureConnection *)connection;

@end
