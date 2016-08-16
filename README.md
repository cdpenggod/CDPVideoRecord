# CDPVideoRecord
## 美颜录制，并可以在录制时随时切换摄像头,开关美颜和开关闪光灯等功能。
An video camera,you can have realtime of a beautify,and change camera position.Details see demo.

## init初始化
-(instancetype)initWithFrame:(CGRect)frame cameraPosition:(AVCaptureDevicePosition)cameraPosition openBeautify:(BOOL)openBeautify isFullScreen:(BOOL)isFullScreen addToSuperview:(UIView *)superView;

## start record开始录制
-(void)startRecording;

## end record结束录制
-(NSURL *)finishRecordingAndSaveToLibrary:(BOOL)isSave;

