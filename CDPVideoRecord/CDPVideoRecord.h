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

@interface CDPVideoRecord : NSObject


/**
 *  显示当前的镜头画面view(不会用的话不要乱改参数)
 */
@property (nonatomic,strong) GPUImageView *filterView;

/**
 *  是否打开美颜
 */
@property (nonatomic,assign) BOOL openBeautify;

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
 *  结束录制(返回值为最终合成视频URL)
 *  isSave  是否存入本地照片库
 */
-(NSURL *)finishRecordingAndSaveToLibrary:(BOOL)isSave;

/**
 *  获取当前摄像头位置(前置或后置)
 */
-(AVCaptureDevicePosition)getCurrentCameraPosition;

/**
 *  改变当前启用的摄像头位置(前置和后置摄像头切换)
 */
-(void)changeCameraPosition;






@end
