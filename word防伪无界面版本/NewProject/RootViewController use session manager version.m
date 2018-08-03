
//
//  RootViewController.m
//  NewProject
//
//  Created by LU jianfeng
//  Copyright (c) 2015. All rights reserved.
//

#import "RootViewController.h"
#import "UIUtils.h"
#import "FftOpencvFun.h"
#import <AudioToolbox/AudioToolbox.h>

#define DETECT_WM_IMAGE_256

@interface RootViewController ()

{
    char outBuf[50];  //watermark detection buffer
    
    
}

@property (strong,nonatomic) UILabel* labResult;
@end


@implementation RootViewController
@synthesize labResult;
@synthesize captureManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

#if 0
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别出水印。";

    [self.view addSubview:labIntroudction];
    
    labResult= [[UILabel alloc] initWithFrame:CGRectMake(15, 380, 290, 40)];
    labResult.backgroundColor = [UIColor clearColor];
    labResult.numberOfLines=2;
    labResult.textColor=[UIColor whiteColor];
    labResult.text=@"识别结果：";
    //[self.view addSubview:labResult];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 105, 265, 265)];
    imageView.image = [UIImage imageNamed:@"pick_bg.png"];
    [self.view addSubview:imageView];
    
//    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [scanButton setTitle:@"返回" forState:UIControlStateNormal];
//    scanButton.frame = CGRectMake(100, 480, 120, 40);
//    scanButton.backgroundColor = [UIColor lightGrayColor];
//    [scanButton setBackgroundImage:[UIImage imageNamed:@"scanbutton.png"]
//                          forState:UIControlStateNormal];
  
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(130, 470, 60, 30)];
    [overlayButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];
    
//    
//    [scanButton addTarget:self action:@selector(backButtonPressed)
//         forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:scanButton];

    upOrdown = NO;
    num =0;
#endif
    
    
#if 0
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
#endif

    [self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    
    [[self captureManager] addVideoInput];
    
    [[self captureManager] addVideoPreviewLayer];
    CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
    [[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    [overlayImageView setFrame:CGRectMake(30, 100, 260, 200)];
    [[self view] addSubview:overlayImageView];

    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
    [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];
    

    
    [[captureManager captureSession] startRunning];
    
}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (2*num == 280) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }

}

-(void)scanButtonPressed
{
#if 0
    if(self.preview) {
        [self.preview removeFromSuperlayer];
        self.preview = nil;
    }
    
    if(self.session) {
        [self.session stopRunning];
        self.session = nil;
    }
#endif
    
    [self dismissViewControllerAnimated:YES completion:^{
#if 0
        [timer invalidate];
#endif
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    //_output = [[AVCaptureMetadataOutput alloc]init];
    //[_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _output_raw = [[AVCaptureVideoDataOutput alloc]init];
    [_output_raw setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output_raw])
    {
        [_session addOutput:self.output_raw];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    //_output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];

    //new
    // We're only interested in faces
    //[_output setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
   
    _output_raw.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithInt: 320], (id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithInt: 240], (id)kCVPixelBufferHeightKey,
                            nil];
  
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(30,110,256,256);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //_output_raw.minFrameDuration = CMTimeMake(1, 15);
    //dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
    //[output setSampleBufferDelegate:self queue:queue];
    //dispatch_release(queue);
    
    // Start
    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
/*
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
   
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
   [self dismissViewControllerAnimated:YES completion:^
    {
        [timer invalidate];
        NSLog(@"%@",stringValue);
    }];
}
*/

/*
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeFace])
        {
            // Take an image of the face and pass to CoreImage for detection
            AVCaptureConnection *stillConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
            [_stillImageOutput captureStillImageSaynchronouslyFromConnection:stillConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                if (error) {
                    NSLog(@"There was a problem");
                    return;
                }
                
                NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                UIImage *smileImage = [UIImage imageWithData:jpegData];
                _previewLayer.hidden = YES;
                [_session stopRunning];
                self.imageView.hidden = NO;
                self.imageView.image = smileyImage;
                self.activityView.hidden = NO;
                self.statusLabel.text = @"Processing";
                self.statusLabel.hidden = NO;
                
                CIImage *image = [CIImage imageWithData:jpegData];
                [self imageContainsSmiles:image callback:^(BOOL happyFace) {
                    if (happyFace) {
                        self.statusLabel.text = @"Happy Face Found!";
                    }else {
                        self.statusLabel.text = @"Not a good photo...";
                    }
                    self.activityView.hidden = YES;
                    self.retakeButton.hidden = NO;
                }];
            }];
        }
    }
}
*/

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
	UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image_temp = [self imageFromSampleBuffer:sampleBuffer];
    UIImage *image = [UIUtils rotateImage:image_temp];
    
    //mData = UIImageJPEGRepresentation(image, 0.5);//这里的mData是NSData对象，后面的0.5代表生成的图片质量
    
    IplImage* img = [UIUtils CreateIplImageFromUIImage:image];
    IplImage* img512 = cvCreateImage(cvSize(G_IMAGE_WIDTH, G_IMAGE_WIDTH), IPL_DEPTH_8U, 3);

    int top   = (img->height - G_IMAGE_WIDTH) / 2;
    int left  = (img->width  - G_IMAGE_WIDTH) / 2;
    
    cvSetImageROI(img, cvRect(left,top, G_IMAGE_WIDTH, G_IMAGE_WIDTH));
    
    cvCopy(img, img512);
    
#if 0
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale,
                                result.height * [UIScreen mainScreen].scale);
            return (result.height == 960 ? UIDevice_iPhoneHiRes : UIDevice_iPhoneTallerHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
#endif
    
    memset(outBuf, '0', 50);
    bool ret = FftOpencvFun(img512, outBuf);
    //outBuf[42] = 0;
    int len_ = strlen(outBuf);
    NSString* all  = [NSString stringWithFormat:@"%s",outBuf];
    
    NSLog(@"length:%d\n", len_);

    NSRange rg = {0, 8};
    NSLog(@"%@", [all substringWithRange: rg]);
    
#ifdef DETECT_WM_IMAGE_512
    rg.location = 8;
    NSLog(@"%@", [all substringWithRange: rg]);
    rg.location = 16;
    NSLog(@"%@", [all substringWithRange: rg]);
    rg.location = 24;
    NSLog(@"%@", [all substringWithRange: rg]);
#endif
    
    if (ret)
    {
        rg.location = 0;
        rg.length   = 8;
        
        NSLog(@"\nBingo!\n%@", [all substringWithRange: rg]);
        //rg.location = 40;
        //NSLog(@"%@", [all substringWithRange: rg]);
    }

    if (ret)
    {
        if ([all length] > 8)
        {
            //NSRange mRange = {0,4};
        
            
            [self playSound];
            //labResult.text =  [all substringWithRange: mRange];
        }
        else
        {
            //labResult.text = @"error";
        }
    }
    else
    {
        //labResult.text =  @"";
        
    }
    
    //UIImage* dstImg = [UIUtils UIImageFromIplImage:img512];
    //UIImageWriteToSavedPhotosAlbum(dstImg, nil, nil, nil);

    //dstImg = nil;
    image_temp = nil;
    image = nil;
    
    cvReleaseImage(&img);
    cvReleaseImage(&img512);
    img    = NULL;
    img512 = NULL;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view setNeedsDisplay];
//    });
    
    
    [[self.preview connection] setEnabled:NO];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self.preview connection] setEnabled:YES];
        
    });
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playSound
{
    static SystemSoundID shake_sound_male_id = 0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"connected" ofType:@"mp3"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}

@end
