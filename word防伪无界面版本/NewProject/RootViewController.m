                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
//
//  RootViewController.m
//  NewProject
//
//  Created by LU jianfeng
//  Copyright (c) 2015. All rights reserved.
//

#import "RootViewController.h"
#import "UIUtils.h"

#import"RGBtransHSV.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define DETECT_WM_IMAGE_256

#define SUCCESS_URL_1   @"http://www.imagelab.cc/"
#define SUCCESS_URL_2   @"http://www.hdu.edu.cn/"
#define VIDEO_WIDTH     1920
#define VIDEO_HEIGHT    1080

int text=1;
int set=1;
@interface RootViewController ()

{
    char outBuf[50];  //watermark detection buffer
    
    int G_prev_width;
    int G_prev_height;
    
    float G_scale;
}

@property (strong,nonatomic) UILabel* labResult;
@property (nonatomic)UIView *focusView;
@property (strong,nonatomic) UISwitch *switchButton;
@end


@implementation RootViewController
@synthesize labResult;

#if 0
@synthesize captureManager;
#endif

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
    
    [self setupCamera];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=4;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将图像水平置于矩形方框内，离手机摄像头8CM-10CM左右，自动识别出结果。";
    
    //[self.view addSubview:labIntroudction];
    
    labResult= [[UILabel alloc] initWithFrame:CGRectMake(0, 505, 360, 70)];
    labResult.backgroundColor = [UIColor grayColor];
    
    　[self.view addSubview:labResult];
    [self addswich];
    [self addbutton];
    float xs = Main_Screen_Width  / VIDEO_HEIGHT;
    float ys = Main_Screen_Height / VIDEO_WIDTH;
    
    if (xs < ys)
        G_scale = ys;
    else
        G_scale = xs;
    
    G_prev_width  = G_IMAGE_WIDTH  * G_scale;
    G_prev_height = G_IMAGE_HEIGHT * G_scale;
    
    int left = (Main_Screen_Width  - G_prev_width) / 2;
    int top  = (Main_Screen_Height - G_prev_height) / 2;
    
    
    
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left-5, top-5, G_prev_width+10, G_prev_height+10)];
    imageView.image = [UIImage imageNamed:@"pick_bg.png"];
    //[self.view addSubview:imageView];
    
    //    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [scanButton setTitle:@"返回" forState:UIControlStateNormal];
    //    scanButton.frame = CGRectMake(100, 480, 120, 40);
    //    scanButton.backgroundColor = [UIColor lightGrayColor];
    //    [scanButton setBackgroundImage:[UIImage imageNamed:@"scanbutton.png"]
    //                          forState:UIControlStateNormal];
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setTitle:@"返回" forState:UIControlStateNormal];
    //[overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(0, Main_Screen_Height - 50, Main_Screen_Width, 50)];
    [overlayButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[[self view] addSubview:overlayButton];
    
    //
    //    [scanButton addTarget:self action:@selector(backButtonPressed)
    //         forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:scanButton];
    
    upOrdown = NO;
    num =0;
    
#if 0
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
#endif
    
    
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

-(void)backButtonPressed
{
    
    if(self.preview) {
        [self.preview removeFromSuperlayer];
        self.preview = nil;
    }
    
    if(self.session) {
        [self.session stopRunning];
        self.session = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
#if 0
        [timer invalidate];
#endif
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    
   // [NSThread sleepForTimeInterval:0.5f];
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
    //[_session setSessionPreset:AVCaptureSessionPresetHigh];
    //视频分辨率
    [_session setSessionPreset:AVCaptureSessionPreset1280x720];
    //[_session setSessionPreset:AVCaptureSessionPreset1920x1080];
    //[_session setSessionPreset:AVCaptureSessionPreset640x480];
        //[_session setSessionPreset:AVCaptureSessionPreset3840x2160];
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
                                 [NSNumber numberWithInt: 1080], (id)kCVPixelBufferWidthKey,
                                 [NSNumber numberWithInt: 1920], (id)kCVPixelBufferHeightKey,
                                 nil];
    
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    //_preview.frame =CGRectMake(left, top, G_IMAGE_WIDTH, G_IMAGE_HEIGHT);
    _preview.frame =CGRectMake(0,0,Main_Screen_Width,Main_Screen_Height);
    [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
    [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    //[self.view.layer addSublayer:self.preview];
    
    //_output_raw.minFrameDuration = CMTimeMake(1, 15);
    dispatch_queue_t queue = dispatch_queue_create("ScanQueue", NULL);
    [_output_raw setSampleBufferDelegate:self queue:queue];
    //dispatch_release(queue);
    
    // Start
    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

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
    //cameraImg_Buffer = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    //cameraImg_Buffer = [UIUtils rotateImage:image];
    //image = nil;
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    //quartzImage = nil;
    //image = nil;
    
    //CGImageRefRelease();
    return (image);
    //return NULL;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    
    IplImage *_image = NULL;
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // get information of the image in the buffer
    uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bufferWidth  = CVPixelBufferGetWidth(imageBuffer);
    size_t bufferHeight = CVPixelBufferGetHeight(imageBuffer);
    
    // create IplImage
    if (bufferBaseAddress)
    {
        _image = cvCreateImage(cvSize(bufferWidth, bufferHeight), IPL_DEPTH_8U, 4);
        _image->imageData = (char*)bufferBaseAddress;
    
        
    }
    // release memory
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    
    
    IplImage* img    = cvCreateImage(cvSize(bufferWidth, bufferHeight), IPL_DEPTH_8U, 3);
    
//   IplImage* img512 = cvCreateImage(cvSize(G_IMAGE_HEIGHT, G_IMAGE_WIDTH), IPL_DEPTH_8U, 3);
    IplImage* img512 = cvCreateImage(cvSize(bufferWidth, bufferHeight), IPL_DEPTH_8U, 3);
    cvCvtColor(_image, img, CV_RGBA2BGR);
    cvReleaseImage(&_image);
    
#if 0
    UIImage* dstImg = [UIUtils UIImageFromIplImage:img];
    UIImageWriteToSavedPhotosAlbum(dstImg, nil, nil, nil);
#endif
    
#if 0
    int top   = (img->height - G_IMAGE_WIDTH/2) / 2;
    int left  = (img->width  - G_IMAGE_WIDTH/2) / 2;
#endif
    //由于采集过来的图是侧的，所以调整了height和width，如下
    //jflu,2015-4-25
    
    int top  =  0;   //Video Width : 1280
    int left =  0;   //Video height : 720
    NSLog(@"图片宽,高 : %d %d",bufferWidth,bufferHeight);
    
    
    cvSetImageROI(img, cvRect(0,0, bufferWidth, bufferHeight));
    
  cvCopy(img, img512);
        
        cvReleaseImage(&img);
    img=NULL;
     IplImage* img51 = cvCreateImage(cvSize(bufferHeight, bufferWidth), IPL_DEPTH_8U, 3);
    cvTranspose(img512, img51);
    
    cvFlip(img51, img51, 1);
    
    cvReleaseImage(&img512);
    img512=NULL;
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
    

    Mat inimg(img51,1);
    cvReleaseImage(&img51);
    img51=NULL;
    BOOL isButtonOn = [_switchButton isOn];
    
    int te=1;
    if(isButtonOn){
        te=1;
    }else{
        te=0;
    }
    
    Mat ret1=transMainFunc(inimg,te);
    //[NSThread sleepForTimeInterval:1.0];
        if (1)
        {//cvReleaseImage(&pEquaImage);
            //pEquaImage=NULL;
       
        UIImage *imageresult2=[self MatToUIImage:ret1];
            ret1.release();
                           dispatch_queue_t main_que = dispatch_get_main_queue();
                dispatch_async(main_que, ^{
                    // Do some work
                    dispatch_async(main_que, ^{
                        int with=[[UIScreen mainScreen]bounds].size.width;
                        with=with/2;
                        int w=[[UIScreen mainScreen] bounds].size.width;
                        
                        int h=[[UIScreen mainScreen] bounds].size.height;
                        int hh=w*1920/1080;
                        
                        UIImageView *imageviewtest2=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, w, hh-40)];
                        imageviewtest2.image=imageresult2;
                        [self.view addSubview:imageviewtest2];
                        
                        /////动画效果
                        [UIView animateWithDuration:1 animations:^{
                            imageviewtest2.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            // 动画完毕从父视图移除
                            [imageviewtest2 removeFromSuperview];
                        }];

                        
                        
                    });
                });
        
            
        }
        
           }
   
#if 0
    UIImage* dstImg = [UIUtils UIImageFromIplImage:img512];
    UIImageWriteToSavedPhotosAlbum(dstImg, nil, nil, nil);
    dstImg = nil;
#endif

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
-(void) appString:(NSString *) s
{
    //如果不存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dPath = [documentPath stringByAppendingPathComponent:@"test.txt"];
    // 先创建文件
    if(![fileManager fileExistsAtPath:dPath]){
        [fileManager createFileAtPath:dPath contents:nil attributes:nil];
        
    }
    
    //打开fileHandle用于更新操作
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:dPath];
    
    //找到并定位到fileHandle的末尾位置(在此后追加写入文件)
    [fileHandle seekToEndOfFile];
    
     NSString * data=[s stringByAppendingString:@"\n"];

    //将data写到fileHandle中
[fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    assert(fileHandle);
    [fileHandle closeFile]; //关闭 fileHandle
    
}
- (void)loadImageFinished:(UIImage *)image
{
    __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        NSLog(@"assetURL = %@, error = %@", assetURL, error);
        lib = nil;
        
    }];
}
-(UIImage*)convertTograyUIImage:(IplImage*)image
{
    //cvCvtColor(image, image, CV_BGR2RGB);
  //  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    NSData *data = [NSData dataWithBytes : image->imageData length : image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height, image->depth, image->depth * image->nChannels, image->widthStep, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage : imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}
-(UIImage*)convertTorgbUIImage:(IplImage*)image
{
    //cvCvtColor(image, image, CV_BGR2RGB);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    NSData *data = [NSData dataWithBytes : image->imageData length : image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height, image->depth, image->depth * image->nChannels, image->widthStep, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage : imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}
//Mat -> UIImage
-(UIImage *)MatToUIImage:(Mat)mat
{
    
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    CGColorSpaceRef colorspace;
    
    if (mat.elemSize() == 1) {
        colorspace = CGColorSpaceCreateDeviceGray();
     
    }
    else
    {cvtColor(mat, mat, CV_BGR2RGB);

        colorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(mat.cols, mat.rows, 8, 8 *mat.elemSize(), mat.step[0], colorspace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorspace);
    
    return image;
}
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}
-(void)addswich{
    int w=[[UIScreen mainScreen] bounds].size.width/2-30;
    _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(w, 535, 200, 35)];
    
    [_switchButton setOn:YES];
    
    
    [self.view addSubview:_switchButton];
}
- (void)addbutton{
    int w=[[UIScreen mainScreen] bounds].size.width/2+50;
   UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(w, 532, 80, 35)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    //button.backgroundColor=[UIColor whiteColor];
    
    [button addTarget:self action:@selector(butclik1) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:button];
}


-(void) butclik1{
    
    //startViewController *s=[[startViewController alloc]init];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
