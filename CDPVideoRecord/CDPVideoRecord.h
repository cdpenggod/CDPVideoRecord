//
//  CDPVideoRecord.h
//  videoRecording
//
//  Created by 柴东鹏 on 16/8/2.
//  Copyright © 2016年 CDP. All rights reserved.
//
//https://github.com/cdpenggod/CDPVideoRecord.git

#import <Foundation/Foundation.h>

#import "GPUImage.h"


@protocol CDPVideoRecordDelegate <NSObject>

@optional

/**
 *  闪光灯关闭(仅当当前摄像头检测不到闪光灯时调用)
 */
-(void)turnOffFlash;

@end





@interface CDPVideoRecord : NSObject


@property (nonatomic,weak) id <CDPVideoRecordDelegate> delegate;

/**
 *  显示当前的镜头画面view(不会用的话不要乱改参数)
 */
@property (nonatomic,strong) GPUImageView *filterView;

/**
 *  是否打开美颜
 */
@property (nonatomic,assign) BOOL openBeautify;

/**
 *  是否打开闪光灯(默认为NO)
 *  (因为前置摄像头无闪光灯,所以如果检测不到闪光灯,则turnOnFlash自动置为NO,且会调用-(void)turnOffFlash代理方法)
 */
@property (nonatomic,assign) BOOL turnOnFlash;

/**
 *  判断是否正在进行录制
 */
@property (nonatomic,assign,readonly) BOOL isRecording;

/**
 *  初始化并捕捉摄像头开始在filterView上显示图像
 *  frame filterView在superView上的frame
 *  cameraPosition 启用的摄像头位置(AVCaptureDevicePositionFront前置和AVCaptureDevicePositionBack后置)
 *  openBeautify 是否打开美颜功能
 *  isFullScreen 最终录制完的视频是否竖直全屏
 *  superView  filterView的父view
 *  warning:frame最好为[UIScreen mainScreen].bounds屏幕宽高或等比宽高,否则isFullScreen=YES情况下filterView显示左右两边可能会有黑边,但最终录制的视频仍正常,即全屏无黑边
 */
-(instancetype)initWithFrame:(CGRect)frame cameraPosition:(AVCaptureDevicePosition)cameraPosition openBeautify:(BOOL)openBeautify isFullScreen:(BOOL)isFullScreen addToSuperview:(UIView *)superView;

/**
 *  开始录制
 */
-(void)startRecording;

/**
 *  结束录制(返回值为最终合成视频URL,但并不会停止捕捉摄像头,如需停止调用摄像头使用stopCameraCapture)
 *  isSave  是否存入本地照片库
 */
-(NSURL *)finishRecordingAndSaveToLibrary:(BOOL)isSave;

/**
 *  获取当前摄像头位置(前置或后置)
 */
-(AVCaptureDevicePosition)getCurrentCameraPosition;

/**
 *  改变当前启用的摄像头位置(前置和后置摄像头切换)
 *  如果改变时闪光灯开启中，则改变后会自动检测并改变闪光灯状态
 */
-(void)changeCameraPosition;

/**
 *  开始捕捉摄像头(需要摄像头并显示图像时调用,即对摄像头添加引用)
 */
-(void)startCameraCapture;

/**
 *  停止捕捉摄像头(可在不用摄像头时调用,去掉对摄像头的引用)
 */
-(void)stopCameraCapture;




@end
