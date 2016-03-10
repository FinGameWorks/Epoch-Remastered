//
//  JZ_ImageHelper.h
//  EpochRemastered
//
//  Created by Fincher Justin on 16/3/9.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "opencv2/opencv.hpp"

@interface JZ_ImageHelper : NSObject

#pragma mark - OpenCV Mat 2 UIImage
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

#pragma mark - Panorama 2 Cubemap
- (void)createCubeMapFace:(cv::Mat &)cvMatIn
                    Faces:(cv::Mat &)face
                   FaceID:(int)faceId
                    Width:(int)width
                   Height:(int)height;

- (NSMutableArray *)createCubeMapArray:(cv::Mat &)cvMatIn
                                 Width:(int)width
                                Height:(int)height;


#pragma mark - Rotate UIImage

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;

#pragma mark - Draw Debug Text On UIImage
+(UIImage*) drawText:(NSString*) text
            fontSize:(float)fontSize
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

#pragma mark - Get Pixel from UIImage
- (UIColor*)colorFromImage:(UIImage*)image sampledAtPoint:(CGPoint)p;

#pragma mark - Get Grey Scale from Pixel UIColor
- (CGFloat)greyScaleFromUIColor:(UIColor *)color;

#pragma mark - Share Instance
+ (id)sharedManager;

@end
