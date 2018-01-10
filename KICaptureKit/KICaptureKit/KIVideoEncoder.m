//
//  KIVideoEncoder.m
//  Kitalker
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KIVideoEncoder.h"

@interface KIVideoEncoder()
@property (nonatomic, assign) int videoWidth;
@property (nonatomic, assign) int videoHeight;

@property (nonatomic, assign) BOOL isPrepareWriter;

@property (nonatomic, strong) AVAssetWriter         *assetWriter;

@property (nonatomic, strong) AVAssetWriterInput    *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInput    *audioWriterInput;
@property (nonatomic, assign) CMTime                lastSampleTime;

@property (nonatomic, copy) KIVideoEncoderDidFinishWritingBlock didFinishWritingBlock;
@property (nonatomic, copy) KIVideoEncoderDidStartWritingBlock didStartWritingBlock;
@end

@implementation KIVideoEncoder

- (instancetype)init {
    if (self = [super init]) {
        [self setVideoWidth:480];
        [self setVideoHeight:320];
    }
    return self;
}

- (void)setVideoEncoderDidStartWritingBlock:(KIVideoEncoderDidStartWritingBlock)block {
    [self setDidStartWritingBlock:block];
}

- (void)setVideoEncoderDidFinishWritingBlock:(KIVideoEncoderDidFinishWritingBlock)block {
    [self setDidFinishWritingBlock:block];
}

- (void)setVideoWidth:(int)width height:(int)height {
    [self setVideoWidth:width];
    [self setVideoHeight:height];
}

- (BOOL)prepareToWriting {
    return [self prepareWriter];
}

- (BOOL)startWriting {
    BOOL success = NO;
    if (self.assetWriter.status != AVAssetWriterStatusWriting && self.assetWriter.status != AVAssetWriterStatusFailed) {
//        if (CMTIME_IS_VALID(self.lastSampleTime)) {
            success = [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
//        }
    }
    }
    
    if (self.didStartWritingBlock != nil) {
        self.didStartWritingBlock(success);
    }
    
    return success;
}

- (BOOL)isWriting {
    return (self.assetWriter.status == AVAssetWriterStatusWriting);
}

- (void)cancelWriting {
    self.isPrepareWriter = NO;
    [self.assetWriter cancelWriting];
}

- (void)finishWriting {
    if (self.isPrepareWriter) {
        self.isPrepareWriter = NO;
        if (self.assetWriter.status == AVAssetWriterStatusWriting) {
            if (self.assetWriter.inputs.count > 0) {
                [self.videoWriterInput markAsFinished];
                [self.audioWriterInput markAsFinished];
                if (CMTIME_IS_VALID(self.lastSampleTime)) {
                    [self.assetWriter endSessionAtSourceTime:self.lastSampleTime];
                    NSLog(@"end ss");
                }
                __weak KIVideoEncoder *weakSelf = self;
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    if (weakSelf.didFinishWritingBlock != nil) {
                        weakSelf.didFinishWritingBlock(YES);
                    }
                }];
                return ;
            }
        }
    }
    
    if (self.didFinishWritingBlock != nil) {
        self.didFinishWritingBlock(NO);
    }
}

- (void)encodeWithOutput:(AVCaptureOutput *)captureOutput
   didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
          fromConnection:(AVCaptureConnection *)connection {
    
    self.lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if (self.assetWriter == nil || self.assetWriter.status != AVAssetWriterStatusWriting) {
        return ;
    }
    
    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        if (self.assetWriter.status > AVAssetWriterStatusWriting) {
            if (self.assetWriter.status == AVAssetWriterStatusFailed){
            }
            return;
        }
        
        if ([self.videoWriterInput isReadyForMoreMediaData]) {
            
            if(![self.videoWriterInput appendSampleBuffer:sampleBuffer]) {
#ifdef DEBUG
                NSLog(@"Unable to write to video input");
#endif
            } else {
#ifdef DEBUG
                NSLog(@"already write vidio");
#endif
            }
        }
        
    } else if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        if(self.assetWriter.status > AVAssetWriterStatusWriting) {
#ifdef DEBUG
            NSLog(@"Warning: writer status is %ld", self.assetWriter.status);
#endif
            if (self.assetWriter.status == AVAssetWriterStatusFailed) {
#ifdef DEBUG
                NSLog(@"Error: %@", self.assetWriter.error);
#endif
            }
            return;
        }
        
        if ([self.audioWriterInput isReadyForMoreMediaData]) {
            if( ![self.audioWriterInput appendSampleBuffer:sampleBuffer]) {
#ifdef DEBUG
                NSLog(@"Unable to write to audio input");
#endif
            } else {
#ifdef DEBUG
                NSLog(@"already write audio");
#endif
            }
        }
    }

}

- (BOOL)prepareWriter {
    if (self.path == nil) {
        return NO;
    }
    
    if (self.isPrepareWriter) {
        return YES;
    }
    
    unlink([self.path UTF8String]);
    
    NSError *error = nil;

    self.assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.path]
                                                 fileType:AVFileTypeMPEG4
                                                    error:&error];
    if(error) {
        return NO;
    }
    
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(1024.0*1024.0),AVVideoAverageBitRateKey,
                                           nil];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   @(self.videoWidth), AVVideoWidthKey,
                                   @(self.videoHeight),AVVideoHeightKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   AVVideoScalingModeResizeAspectFill, AVVideoScalingModeKey,
                                   nil];
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
    if (![self.assetWriter canAddInput:self.videoWriterInput]) {
        return NO;
    }
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    NSDictionary* audioSettings = nil;
    audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                      @(1), AVNumberOfChannelsKey,
                      @(64000), AVEncoderBitRateKey,
                      @(44100.0f), AVSampleRateKey,
                      [NSData dataWithBytes:&acl length: sizeof(acl)], AVChannelLayoutKey,
                      nil];
    
    self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    self.audioWriterInput.expectsMediaDataInRealTime = YES;
    
    if (![self.assetWriter canAddInput:self.audioWriterInput]) {
        return NO;
    }
    
    [self.assetWriter addInput:self.videoWriterInput];
    [self.assetWriter addInput:self.audioWriterInput];
    
    [self setIsPrepareWriter:YES];
    
    return YES;
}

@end
