

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#include <opencv2/opencv.hpp>

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

using namespace cv;
using namespace std;

Mat transMainFunc(Mat img,int lFlag);
#define PI 3.14159

#define TRUE  1
#define FALSE 0

#define G_IMAGE_WIDTH   1024
#define G_IMAGE_HEIGHT  1280
