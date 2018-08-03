
/* ********************************************************* *\
 |   CMHelpViewController.m                                    |
 |   On Call Anywhere Diabetes Manager                         |
 |                                                             |
 |   utils                                                     |
 |                                                             |
 |   Created by Lu Jianfeng on 8/28/13.                        |
 |   Copyright (c) 2013 ACONLAB. All rights reserved.          |
 \* ********************************************************* */
#import <UIKit/UIcolor.h>
#import <Foundation/Foundation.h>



typedef enum {
    UIDevice_iPhoneStandardRes      = 1,    // iPhone 1,3,3GS Standard Resolution   (320x960px)
    UIDevice_iPhoneHiRes            = 2,    // iPhone 4,4S High Resolution          (640x960px)
    UIDevice_iPhoneTallerHiRes      = 3,    // iPhone 5 High Resolution             (640x1136px)
    UIDevice_iPadStandardRes        = 4,    // iPad 1,2 Standard Resolution         (1024x768px)
    UIDevice_iPadHiRes              = 5     // iPad 3 High Resolution               (2048x1536px)
} UIDeviceResolution;

@interface UIUtils : NSObject

//获取documents下的文件路径
+ (NSString *)getDocumentsPath:(NSString *)fileName;
//判断文件是否存在
+ (BOOL)isFileExists:(NSString *)fileName;
//图像缩放
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
//创建唯一文件名
+ (NSString*)createTempFileNameInDirectory:(NSString*)dir;
//创建椭圆图像
+ (UIImage*)circleImage:(UIImage*)image withParam:(CGFloat)inset;


// date 格式化为 string
+ (NSString*) stringFromFomate:(NSDate*)date formate:(NSString*)formate;
// string 格式化为 date
+ (NSDate *) dateFromFomate:(NSString *)datestring formate:(NSString*)formate;

+ (NSString *)fomateString:(NSString *)datestring;

+ (void)popMessage:(NSString*)message;

+ (void)setSegmentedControlApperance;
+ (void)restoreSegmentedControlApperance;
+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size;


+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos;
+ (unsigned long)XTickCount;

+ (NSString*)getPreferredLanguage;

//#if 0
//+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
//+ (UIImage *)UIImageFromIplImage:(cv::Mat)aMat;
//#endif


+ (UIImage *)UIImageFromIplImage:(IplImage *)image;
+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;



+ (UIImage* )rotateImage:(UIImage *)image;

@end
