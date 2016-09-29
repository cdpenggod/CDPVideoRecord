//
//  CDPVideoRecord.m
//  videoRecording
//
//  Created by 柴东鹏 on 16/8/2.
//  Copyright © 2016年 CDP. All rights reserved.
//

#import "CDPVideoRecord.h"
#import "CDPVideoEditor.h"
#import "GPUImageBeautifyFilter.h"

//最终合成视频地址
#define OutputPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CDPVideoRecordMovie.mp4"]

#define CDPSWIDTH   [UIScreen mainScreen].bounds.size.width
#define CDPSHEIGHT  [UIScreen mainScreen].bounds.size.height

#ifdef DEBUG
#    define CDPLog(fmt,...) NSLog(fmt,##__VA_ARGS__)
#else
#    define CDPLog(fmt,...) /* */
#endif

@implementation CDPVideoRecord{
    GPUImageVideoCamera *_videoCamera;//录制camera
    
    GPUImageBeautifyFilter *_beautifyFilter;//美颜滤镜
    GPUImageCropFilter *_cropFilter;//剪切滤镜
    
    GPUImageFilterGroup *_filterGroup;//滤镜组合
    
    GPUImageMovieWriter *_movieWriter;//最终视频合成导出对象
    
    BOOL _isFullScreen;//最终录制完的视频是否竖直全屏
        
    UIView *_superView;
    
    AVCaptureDevicePosition _initCameraPosition;//初始化传入的摄像头位置
}



-(instancetype)initWithFrame:(CGRect)frame cameraPosition:(AVCaptureDevicePosition)cameraPosition openBeautify:(BOOL)openBeautify isFullScreen:(BOOL)isFullScreen addToSuperview:(UIView *)superView{
    if (self=[super init]) {
        _openBeautify=openBeautify;
        _initCameraPosition=cameraPosition;
        _isFullScreen=isFullScreen;
        _superView=superView;
        
        _turnOnFlash=NO;
        
        [self createVideoRecordWithFrame:frame];
        
    }
    return self;
}
#pragma mark - 创建相关对象
-(void)createVideoRecordWithFrame:(CGRect)frame{
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:_initCameraPosition];
    _videoCamera.outputImageOrientation=UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    [_videoCamera addAudioInputsAndOutputs];
    
    _filterView = [[GPUImageView alloc] initWithFrame:frame];
    [_superView addSubview:_filterView];
    
    //filter相关
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    
    CGFloat value=(640-480)/2/640.0;
    CGRect cropRegion=(_isFullScreen==YES)?CGRectMake(value,0,1-value*2,1):CGRectMake(0,value,1,480/640.0);
    _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:cropRegion];
    
    if (_openBeautify==YES) {
        [self addBeautifyFilter];
    }
    else{
        [self removeBeautifyFilter];
    }
    
    //开始捕捉camera
    [self startCameraCapture];
}
#pragma mark - 开始/结束录制
//开始录制
-(void)startRecording{
    //如果文件已存在则删除
    _isRecording=YES;
    
    unlink([OutputPath UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:OutputPath];
    
    CGFloat originScale=960.0/540.0;
    CGFloat currentScale=CDPSHEIGHT/CDPSWIDTH;
    
    CGFloat fullHeight=(currentScale>originScale)?960.0:CDPSHEIGHT;
    CGFloat fullWidth=(currentScale>originScale)?540.0:CDPSWIDTH;
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:(_isFullScreen==YES)?CGSizeMake(fullWidth,fullHeight):CGSizeMake(640,640)];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    _movieWriter.hasAudioTrack=YES;
    
    if (_openBeautify==YES) {
        [_filterGroup addTarget:_movieWriter];
    }
    else{
        [_cropFilter addTarget:_movieWriter];
    }
    
    _videoCamera.audioEncodingTarget = _movieWriter;
    
    [_movieWriter startRecording];
}
//结束录制
-(NSURL *)finishRecordingAndSaveToLibrary:(BOOL)isSave{
    _isRecording=NO;
    
    _videoCamera.audioEncodingTarget = nil;
    [_beautifyFilter removeTarget:_movieWriter];
    [_cropFilter removeTarget:_movieWriter];
    [_filterGroup removeTarget:_movieWriter];
    [_movieWriter finishRecording];

    if (isSave==YES) {
        [CDPVideoEditor exportWithVideoUrl:[NSURL fileURLWithPath:OutputPath] saveToLibrary:YES exportQuality:CDPVideoEditorExportQuality640x480];
    }

    return [NSURL fileURLWithPath:OutputPath];
}
#pragma mark - 添加/去除美颜
-(void)setOpenBeautify:(BOOL)openBeautify{
    _openBeautify=openBeautify;
    
    if (_openBeautify==YES) {
        [self addBeautifyFilter];
    }
    else{
        [self removeBeautifyFilter];
    }
}
//添加美颜
-(void)addBeautifyFilter{
    [_videoCamera removeAllTargets];
    [_cropFilter removeAllTargets];
    [_beautifyFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    
    
    [_cropFilter addTarget:_beautifyFilter];
        
    [_filterGroup setInitialFilters:[NSArray arrayWithObject:_cropFilter]];
    
    [_filterGroup setTerminalFilter:_beautifyFilter];
    
    [_filterGroup forceProcessingAtSize:_filterView.frame.size];
    
    [_filterGroup useNextFrameForImageCapture];
    
    [_videoCamera addTarget:_filterGroup];
    
    [_filterGroup addTarget:_filterView];
    
    if (_isRecording&&_movieWriter) {
        _videoCamera.audioEncodingTarget = _movieWriter;

        [_filterGroup addTarget:_movieWriter];
    }
}
//去除美颜
-(void)removeBeautifyFilter{
    [_videoCamera removeAllTargets];
    [_cropFilter removeAllTargets];
    [_beautifyFilter removeAllTargets];
    [_filterGroup removeAllTargets];
    
    [_videoCamera addTarget:_cropFilter];
    [_cropFilter addTarget:_filterView];
    
    if (_isRecording&&_movieWriter) {
        _videoCamera.audioEncodingTarget = _movieWriter;

        [_cropFilter addTarget:_movieWriter];
    }
}
#pragma mark - 开启/关闭闪光灯
-(void)setTurnOnFlash:(BOOL)turnOnFlash{
    
    AVCaptureDevice *device = _videoCamera.inputCamera;

    if ([device hasTorch] && [device hasFlash]){
        
        _turnOnFlash=turnOnFlash;
        
        [device lockForConfiguration:nil];
        if (_turnOnFlash) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
    else{
        _turnOnFlash=NO;
        CDPLog(@"CDPVideoRecord:当前摄像头检测不到闪光灯");
        
        if ([_delegate respondsToSelector:@selector(turnOffFlash)]) {
            [_delegate turnOffFlash];
        }
    }
}
#pragma mark - 其他方法
//当前摄像头位置(前置或后置)
-(AVCaptureDevicePosition)getCurrentCameraPosition{
    return [_videoCamera cameraPosition];
}
//改变当前启用的摄像头位置(前置和后置摄像头切换)
-(void)changeCameraPosition{
    [_videoCamera rotateCamera];
    
    if (_turnOnFlash==YES) {
        [self setTurnOnFlash:_turnOnFlash];
    }
}
//开始捕捉摄像头(需要摄像头并显示图像时调用,即对摄像头添加引用)
-(void)startCameraCapture{
    if (_videoCamera) {
        [_videoCamera startCameraCapture];
    }
    else{
        CDPLog(@"CDPVideoRecord:当前videoCamera为空");
    }
}
//停止捕捉摄像头(可在不用摄像头时调用,去掉对摄像头的引用)
-(void)stopCameraCapture{
    if (_videoCamera) {
        [_videoCamera stopCameraCapture];
    }
    else{
        CDPLog(@"CDPVideoRecord:当前videoCamera为空");
    }
}







@end
