//
//  RootViewController.h
//  NewProject
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "CaptureSessionManager.h"


@interface RootViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
//AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
//@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureVideoDataOutput * output_raw;

@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, retain) UIImageView * line;

#if 0
@property (nonatomic, strong) CaptureSessionManager *captureManager;
#endif

@end
