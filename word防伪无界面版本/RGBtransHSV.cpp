#include "RGBtransHSV.h"

void sharpen(const Mat& img, Mat& result)
{
    result.create(img.size(), img.type());
    //处理边界内部的像素点, 图像最外围的像素点应该额外处理
    for (int row = 1; row < img.rows - 1; row++)
    {
        //前一行像素点
        const uchar* previous = img.ptr<const uchar>(row - 1);
        //待处理的当前行
        const uchar* current = img.ptr<const uchar>(row);
        //下一行
        const uchar* next = img.ptr<const uchar>(row + 1);
        uchar *output = result.ptr<uchar>(row);
        int ch = img.channels();
        int starts = ch;
        int ends = (img.cols - 1) * ch;
        for (int col = starts; col < ends; col++)
        {
            //输出图像的遍历指针与当前行的指针同步递增, 以每行的每一个像素点的每一个通道值为一个递增量, 因为要考虑到图像的通道数
            *output++ = saturate_cast<uchar>(5 * current[col] - current[col - ch] - current[col + ch] - previous[col] - next[col]);
        }
    } //end loop
    //处理边界, 外围像素点设为 0
    result.row(0).setTo(Scalar::all(0));
    result.row(result.rows - 1).setTo(Scalar::all(0));
    result.col(0).setTo(Scalar::all(0));
    result.col(result.cols - 1).setTo(Scalar::all(0));
}

Mat transMainFunc(Mat img, int lFlag)
{
    NSDateFormatter *form=[[NSDateFormatter alloc]init];
    [form setDateFormat:@"yyyyMMdd"];
    NSString *datetime=[form stringFromDate:[NSDate date]];
    int datetimeint=[datetime intValue];
    int dateend=20170730;//限定使用时间
    if(datetimeint<dateend)
    {
    Mat result;
    //gammaCorrection(img,img,200);
    double alpha; /**< 控制对比度 [1.0-3.0]*/
    int beta;  /**< 控制亮度 [0-100]*/
    alpha = 1;
    if(lFlag == 1)
        beta = -10;
    else
        beta = 10;
    img.convertTo(img, -1, alpha, beta);
//
    cvtColor(img, img, CV_BGR2HSV);
    vector<Mat> channe(3);
    split(img, channe);
    Mat c1,c2;
    c1 =channe[1].clone();
    c2 = channe[2].clone();
    
    channe[0] = channe[0] * 1.7;
    channe[1] =  channe[1] * 0;
    //channe[2] = c2 - 10;
    
    if(mean(channe[2])[0] > 120)
    {
        if(lFlag == 1){
            channe[1] = c1 * 3.6;
            channe[2] = c2 - 20;
        }
        else
            channe[2] = c2 + 25;
        //channe[0] = channe[0] * 2;
    }else
        if(mean(channe[2])[0] > 160)
        {
            if(lFlag == 1){
                channe[1] = c1 * 3.6;
                channe[2] = c2 - 40;
            }
            else
                channe[2] = c2 + 15;
            //channe[0] = channe[0] * 2;
        }
    else
        if(mean(channe[2])[0] > 190)
        {
            //channe[0] = channe[0] *3;
            if(lFlag == 1){
                channe[1] = c1 * 3.7;
                channe[2] = c2 - 60;
            }
            //else
            //    channe[2] = c2 + 5;
        }
        else
        {
            channe[1] =  channe[1] * 0;
        }
    
    if(mean(channe[2])[0] < 70)
    {
        //channe[0] = channe[0] * 1.6;
        //channe[1] =  channe[1] * 0.6;
        if(lFlag == 1)
            channe[2] = c2 + 20;
        else
            channe[2] = c2 + 50;
    }
    else if(mean(channe[2])[0] < 85)
    {
        //channe[0] = channe[0] * 1.6;
        //channe[1] =  channe[1] * 0.5;
        if(lFlag == 1)
            channe[2] = c2 + 15;
        else
            channe[2] = c2 + 40;
    }
    else if(mean(channe[2])[0] <= 100)
    {
        //channe[0] = channe[0] * 1.6;
        //channe[1] =  channe[1] * 0.4;
        if(lFlag == 1)
            channe[2] = c2 + 10;
        else
            channe[2] = c2 + 30;
    }
    
    merge(channe, img);
    cvtColor(img, result, CV_HSV2BGR);
    
    
    
    vector<Mat> chann(3);
    Mat a1,a2;
    split(result, chann);
    switch (lFlag) {
        case 0:
            
            chann[0] = -255*2.5;
            chann[1] = (255 - chann[1])*2.5;
            chann[2] = -255*2.5;
            NSLog(@"检测日光");
            merge(chann, result);
            //result = chann[1];
            cvtColor(result, result, CV_BGR2GRAY);
            result = 255 -result;
            //equalizeHist(result, result);
            
            alpha = 1.5;
            beta = -130;
            result.convertTo(result, -1, alpha, beta);
            break;
        case 1:
            a1 = abs(chann[2]-chann[0]);
            a1.convertTo(a1, -1, 3, -210);
            //equalizeHist(a1, a1);
            NSLog(@"检测灯光");
            a2 = abs(chann[1]-chann[0]);
            a2.convertTo(a2, -1, 3, -210);
            //equalizeHist(a2, a2);
            
            chann[0] = a1 + a2;
            chann[0].convertTo(chann[0], -1, 3, -210);
            //equalizeHist(chann[2], chann[2]);
            
            merge(chann, result);
            //result = chann[1];
            cvtColor(result, result, CV_BGR2GRAY);
            //result = 255 -result;
            
            alpha = 2.5;
            beta = -150;
            result.convertTo(result, -1, alpha, beta);
            
            break;
    }
    
    for(int ii=0;ii<3;ii++)
    {
        chann[ii].release();
        channe[ii].release();
    }
    img.release();
    //medianBlur(re,re,1);
    //threshold(re, re, 140, 255, CV_THRESH_BINARY);
    
    return result;
}
    return img;
}
