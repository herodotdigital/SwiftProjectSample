//
//  UIView+draw.h
//  SwiftSampleCode
//
//  Created by Maciej Gad on 11.06.2015.
//  Copyright (c) 2015 All in Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ONE_PIXEL (1.0f/[UIScreen mainScreen].scale)

/**
 helper for drawing on `UIView`
 */
@interface UIView (draw)

/**
 draw line from point
 @param from from
 @param to to
 @param width width
 @param color color
 */
+ (void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to width:(CGFloat)width color:(UIColor *)color;
/**
 draw triangle in rect
 @param rect rect
 @param color color
 */
+ (void)drawTriangleInRect:(CGRect)rect color:(UIColor *)color;

/**
 Draw background in rect
 */
- (void)drawBackgroundInRect:(CGRect)rect;

@end
