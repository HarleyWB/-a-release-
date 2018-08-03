
/* ********************************************************* *\
 |   CMHelpViewController.m                                    |
 |   On Call Anywhere Diabetes Manager                         |
 |                                                             |
 |   utils                                                     |
 |                                                             |
 |   Created by Lu Jianfeng on 8/28/13.                        |
 |   Copyright (c) 2013 ACONLAB. All rights reserved.          |
 \* ********************************************************* */
#import "sys/time.h"
#import "UIUtils.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

#define MAX_SUGAR_VALUE_I_OCP  600    //OCP，OCXP：20-600，其他都是9-601，
#define MIN_SUGAR_VALUE_I_OCP   20
#define MAX_SUGAR_VALUE_F_OCP 33.3
#define MIN_SUGAR_VALUE_F_OCP  1.1
#define MAX_SUGAR_VALUE_I_OTH  601    //OCP，OCXP：20-600，其他都是9-601，
#define MIN_SUGAR_VALUE_I_OTH    9
#define MAX_SUGAR_VALUE_F_OTH 33.4
#define MIN_SUGAR_VALUE_F_OTH  0.5

#define CONVERT_TO_10_TIMES(x)  ((int)(x * 10.0f + 0.5f))

@implementation UIUtils

+ (NSString *)getDocumentsPath:(NSString *)fileName
{
    
    //两种获取document路径的方式
//    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documents = [paths objectAtIndex:0];
    NSString *path = [documents stringByAppendingPathComponent:fileName];
    
    return path;
}

+ (BOOL)isFileExists:(NSString *)fileName
{
    if ((fileName == nil) ||
        ([fileName length] == 0))
        return NO;
    
    NSFileManager *fm = [NSFileManager defaultManager];
	NSString *fullPath = [self getDocumentsPath:fileName];
    
    return [fm fileExistsAtPath:fullPath];

}


+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos
{
    UIGraphicsBeginImageContext(oneImg.size);
    
    [oneImg drawInRect:CGRectMake(0, 0, oneImg.size.width, oneImg.size.height)];
    [twoImg drawInRect:CGRectMake(tlPos.x, tlPos.y, twoImg.size.width, twoImg.size.height)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
#ifdef DEBUG_MODE_TEST
    [UIImagePNGRepresentation(resultImg) writeToFile:[UIUtils getAttachedFilenameString:fsTrendFile]
                                          atomically:YES];
    
#endif
    return resultImg;
}

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}

+ (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formate];
	NSString *str = [formatter stringFromDate:date];
	//[formatter release];
	return str;
}

+ (NSDate *) dateFromFomate:(NSString *)datestring formate:(NSString*)formate
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
//    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:formate];
    NSDate *date = [formatter dateFromString:datestring];
    return date;
}

//Sat Jan 12 11:50:16 +0800 2013
+ (NSString *)fomateString:(NSString *)datestring
{
    NSString *formate = @"E MMM d HH:mm:ss Z yyyy";
    NSDate *createDate = [UIUtils dateFromFomate:datestring formate:formate];
    NSString *text = [UIUtils stringFromFomate:createDate formate:@"MM-dd HH:mm"];
    return text;
}

//图像缩放
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage*)circleImage:(UIImage*)image withParam:(CGFloat)inset
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (NSString*)createTempFileNameInDirectory:(NSString*)dir
{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSString* curDate = [format stringFromDate:[NSDate date]];
    
    NSString* templateStr = [NSString stringWithFormat:@"%@/user-%@-XXXXXX", dir, curDate];
    char _template[templateStr.length + 1];
    strcpy(_template, [templateStr cStringUsingEncoding:NSASCIIStringEncoding]);
    
    char* filename = mktemp(_template);
    if (filename == NULL)
    {
        NSLog(@"Could not create file in directory %@", dir);
        return nil;
    }
    
    return [[NSString stringWithCString:filename encoding:NSASCIIStringEncoding] lastPathComponent];
}

+ (void)popMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:[NSString stringWithFormat:NSLocalizedString(message, @"")]
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", "")
                          otherButtonTitles:nil];
    [alert show];
    return;

}

+ (void)setSegmentedControlApperance
{
    UIImage *normalBackgroundImage = [UIImage imageNamed:@"seg_norm.png"];
    [[UISegmentedControl appearance] setBackgroundImage:normalBackgroundImage
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    UIImage *selectedBackgroundImage = [UIImage imageNamed:@"seg_back.png"];
    [[UISegmentedControl appearance] setBackgroundImage:selectedBackgroundImage
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
}

+ (void)restoreSegmentedControlApperance
{
    [[UISegmentedControl appearance] setBackgroundImage:nil
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:nil
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
}

+ (UIDeviceResolution) currentResolution
{
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
}

+ (unsigned long)XTickCount;
{
    unsigned long currentTime;
    
    struct timeval current;
    gettimeofday(&current, NULL);
    currentTime = current.tv_sec * 1000 + current.tv_usec/1000;
    
    return currentTime;
}

/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

#if 0
//+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image
//{
//    // Getting CGImage from UIImage
//    CGImageRef imageRef = image.CGImage;
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    // Creating temporal IplImage for drawing
//    IplImage *iplimage = cvCreateImage(
//                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
//                                       );
//    // Creating CGContext for temporal IplImage
//    CGContextRef contextRef = CGBitmapContextCreate(
//                                                    iplimage->imageData, iplimage->width, iplimage->height,
//                                                    iplimage->depth, iplimage->widthStep,
//                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
//                                                    );
//    // Drawing CGImage to CGContext
//    CGContextDrawImage(
//                       contextRef,
//                       CGRectMake(0, 0, image.size.width, image.size.height),
//                       imageRef
//                       );
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
//    
//    
//    NSLog(@"image->width = %d" , iplimage->width);
//    NSLog(@"image->height = %d" , iplimage->height);
//    
//    // Creating result IplImage
//    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
//    cvReleaseImage(&iplimage);
//    
//    
//    
//    return ret;
//}
#endif

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
+ (UIImage *)UIImageFromIplImage:(IplImage *)image
{
    //NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s",
    //      image->width, image->height, image->depth,
    //      image->nChannels, image->widthStep, image->channelSeq);
    //cvCvtColor(image, image, CV_BGR2RGB);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

#if 0
//+(UIImage *)UIImageFromIplImage__:(cv::Mat)aMat
//{
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    
//    unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
//    for (int y = 0; y < aMat.rows; ++y)
//    {
//        cv::Vec3b *ptr = aMat.ptr<cv::Vec3b>(y);
//        unsigned char *pdata = data + 4*y*aMat.cols;
//        
//        for (int x = 0; x < aMat.cols; ++x, ++ptr)
//        {
//            *pdata++ = (*ptr)[2];
//            *pdata++ = (*ptr)[1];
//            *pdata++ = (*ptr)[0];
//            *pdata++ = 0;
//        }
//    }
//    
//    // Bitmap context
//    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaNoneSkipLast);
//    
//    
//    
//    CGImageRef cgimage = CGBitmapContextCreateImage(context);
//    
//    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0
//                                 orientation:UIImageOrientationUp];
//    
//    CGImageRelease(cgimage);
//    
//    CGContextRelease(context);  
//    
//    // CGDataProviderRelease(provider);
//    
//    CGColorSpaceRelease(colorSpace);
//    
//    
//    return ret;
//}
#endif

+ (UIImage* )rotateImage:(UIImage *)image
{
    int kMaxResolution = 960;
    // Or whatever
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width  /  height;
        if (ratio > 1 ) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
        case UIImageOrientationUp:
            //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0 );
            break;
        case UIImageOrientationDown:
            //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width );
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0 );
            break;
        case UIImageOrientationLeft:
            //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate( transform, 3.0 * M_PI / 2.0   );
            break;
        case UIImageOrientationRightMirrored:
            //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate( transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0 );
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform );
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //CGContextRelease(context);
    //CGImageRelease(imgRef);
    
    return imageCopy;
}

@end
