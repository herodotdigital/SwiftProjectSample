//
//  AIMTextView.h
//  SwiftSampleCode
//
//  Created by Maciej Gad on 20.10.2015.
//  Copyright © 2015 All in Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `UITextView` with underline and placeholder
 */
@interface AIMTextView : UITextView

/**
 underline color
 */
@property (strong, nonatomic) IBInspectable UIColor *underlineColor;
/**
 placeholder
 */
@property (strong, nonatomic) IBInspectable NSString *placeholder;
/**
 string transform
 */
@property (strong, nonatomic) NSString *stringTrasform;

/**
 size of placeholder text (default: 14)
 */
@property (strong, nonatomic) IBInspectable NSNumber *placeholderFontSize;

/**
 calculated height
 */

- (CGFloat)calculatedHeight;

/**
 validate
 */
- (BOOL)validate;
@end
