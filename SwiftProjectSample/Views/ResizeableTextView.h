//
//  ResizeableTextView.h
//  SwiftSampleCode
//
//  Created by Maciej Gad on 28.12.2015.
//  Copyright © 2015 All in Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIMTextView.h"

/**
 TextView that resizes itself during typing.
 */
@interface ResizeableTextView : AIMTextView

/**
 Current height of TextView.
 */
@property (readonly, nonatomic) CGFloat heightOfTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end
