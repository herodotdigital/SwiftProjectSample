//
//  UIView+draw.m
//  SwiftSampleCode
//
//  Created by Maciej Gad on 11.06.2015.
//  Copyright (c) 2015 All in Mobile. All rights reserved.
//

#import "UIView+draw.h"

@implementation UIView (draw)

- (void)drawBackgroundInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Fill the background color, if needed
    if (self.opaque) {
        UIGraphicsPushContext(context);
        if (self.backgroundColor) {
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        } else {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        }
        
        CGContextFillRect(context, rect);
        UIGraphicsPopContext();
    }
}

+ (void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to width:(CGFloat)width color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context,  width);
    
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
}

+ (void)drawTriangleInRect:(CGRect)rect color:(UIColor *)color {
    /*
     
     A-------B
     |\     /|
     | \   / |
     |  \ /  |
     |___C___|
     
     A = (x, y)
     B = (x + w, y)
     C = (x + w/2, y + h)
     */
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    CGPoint A = rect.origin;
    CGPoint B = (CGPoint){A.x + w, A.y};
    CGPoint C = (CGPoint){A.x + w * 0.5f, A.y + h};
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:A];
    [path addLineToPoint:B];
    [path addLineToPoint:C];
    [path addLineToPoint:A];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    [path fill];
    [path stroke];
}

@end
