//
//  ResizeableTextView.m
//  SwiftSampleCode
//
//  Created by Maciej Gad on 28.12.2015.
//  Copyright © 2015 All in Mobile. All rights reserved.
//

#import "ResizeableTextView.h"
#import "AIMNotificationObserver.h"

static CGFloat minimalHightDifference = 5.0f;

@interface ResizeableTextView ()
@property (strong, nonatomic) AIMNotificationObserver *changeTextObserver;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;
@property (assign, nonatomic) CGFloat textHeight;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) CGFloat margin;
@end

@implementation ResizeableTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    __weak __typeof(self) weakSelf = self;
    self.textHeight = -1.0f; //text height at begining is invalid because we don't know what is size of textView
    self.changeTextObserver = [AIMNotificationObserver observeName:UITextViewTextDidChangeNotification onChange:^(NSNotification *notification) {
        [weakSelf updateTextHeightWithOffset:YES];
    }];
    self.margin = 24.0f;
    return self;
}

- (void)layoutSubviews {
    [self updateTextHeightWithOffset:YES];
    [super layoutSubviews];
}
- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateTextHeightWithOffset:NO];
}

- (CGFloat)heightOfTextView {
    if (self.textHeight < 0) {
        self.textHeight = [self calculatedHeight];
    }
    return self.textHeight;
}

- (void)updateTextHeightWithOffset:(BOOL)updateOffset {
    CGFloat currentTextHeight = [self calculatedHeight];
    if (ABS(currentTextHeight - self.textHeight) > minimalHightDifference) {
        CGPoint scrollOffset = self.scrollView.contentOffset;
        scrollOffset.y +=  (currentTextHeight - self.textHeight);
        self.textHeight = currentTextHeight;
        self.constraint.constant = currentTextHeight;
        [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, currentTextHeight + self.margin)];
        [self layoutIfNeeded];
        
        if (updateOffset) {
            self.scrollView.contentOffset = scrollOffset;
        }
        [self setNeedsDisplay];
        
    }
}


@end
