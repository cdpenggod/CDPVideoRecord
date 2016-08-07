//
//  ViewController.m
//  videoRecording
//
//  Created by 柴东鹏 on 16/8/7.
//  Copyright © 2016年 CDP. All rights reserved.
//

#import "ViewController.h"

#import "CDPVideoRecord.h"//引入.h文件

#define SWIDTH   [UIScreen mainScreen].bounds.size.width
#define SHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ViewController () {
    
    CDPVideoRecord *_videoRecord;
    
    UIButton *_recordBt;//录制开关
    UIButton *_beautifyBt;//美颜开关
    UIButton *_cameraSwitchBt;//摄像头切换
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //初始化
    //frame最好为[UIScreen mainScreen].bounds屏幕宽高或等比宽高,否则isFullScreen=YES情况下filterView显示左右两边可能会有黑边,但最终录制的视频仍正常,即全屏无黑边
    _videoRecord=[[CDPVideoRecord alloc] initWithFrame:[UIScreen mainScreen].bounds
                                        cameraPosition:AVCaptureDevicePositionFront
                                          openBeautify:YES
                                          isFullScreen:YES
                                        addToSuperview:self.view];
    
    
    //摄像头切换
    _cameraSwitchBt=[[UIButton alloc] initWithFrame:CGRectMake(0,SHEIGHT-110,120,30)];
    _cameraSwitchBt.backgroundColor=[UIColor redColor];
    [_cameraSwitchBt setTitle:@"当前前置" forState:UIControlStateNormal];
    [_cameraSwitchBt setTitle:@"当前后置" forState:UIControlStateSelected];
    [_cameraSwitchBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cameraSwitchBt setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_cameraSwitchBt addTarget:self action:@selector(cameraSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraSwitchBt];
    
    //美颜开关
    _beautifyBt = [[UIButton alloc] initWithFrame:CGRectMake(0,SHEIGHT-70,120,30)];
    _beautifyBt.backgroundColor = [UIColor redColor];
    [_beautifyBt setTitle:@"开启美颜" forState:UIControlStateNormal];
    [_beautifyBt setTitle:@"关闭美颜" forState:UIControlStateSelected];
    [_beautifyBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_beautifyBt setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _beautifyBt.selected=YES;
    [_beautifyBt addTarget:self action:@selector(beautifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_beautifyBt];
    
    //录制开关
    _recordBt=[[UIButton alloc] initWithFrame:CGRectMake(SWIDTH/2-30,SHEIGHT-30,60,30)];
    [_recordBt setTitle:@"录制" forState:UIControlStateNormal];
    [_recordBt setTitle:@"停止" forState:UIControlStateSelected];
    _recordBt.backgroundColor=[UIColor redColor];
    [_recordBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_recordBt setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_recordBt addTarget:self action:@selector(recordClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBt];
    
}
#pragma mark - 点击事件
//转换摄像头
-(void)cameraSwitch:(UIButton *)sender{
    //切换摄像头位置
    [_videoRecord changeCameraPosition];
    
    //判断当前摄像头位置
    sender.selected=([_videoRecord getCurrentCameraPosition]==AVCaptureDevicePositionFront)?NO:YES;
}
//开关美颜
-(void)beautifyClick:(UIButton *)sender{
    sender.selected=!sender.selected;
    
    //开关美颜功能
    _videoRecord.openBeautify=sender.selected;
}
//开关录制
-(void)recordClick:(UIButton *)sender{
    if (sender.selected==YES) {
        //结束录制
        [_videoRecord finishRecordingAndSaveToLibrary:YES];
    }
    else{
        //开启录制
        [_videoRecord startRecording];
    }
    sender.selected=!sender.selected;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
