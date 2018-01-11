//
//  AIMTextView.m
//  SwiftSampleCode
//
//  Created by Maciej Gad on 20.10.2015.
//  Copyright © 2015 All in Mobile. All rights reserved.
//

#import "AIMTextView.h"
#import "UIView+draw.h"
#import "AIMNotificationObserver.h"
#import "SwiftProjectSample-Swift.h"

@interface AIMTextView ()
@property (strong, nonatomic) AIMNotificationObserver *changeEditingObserver;
@property(nonatomic, strong) UILabel *placeholderLabel;
@end

const CGFloat magicNumberToFixSizing = 10.0f;
CGFloat textViewLineWidth = 1.0f;
CGFloat activeTextViewLineWidth = 2.0f;

@implementation AIMTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.textContainer.lineFragmentPadding = 0;
    self.tintColor = [UIColor blackColor];
    [self setupObserver];
    return self;
}


- (void)setStringTrasform:(NSString *)stringTrasform {
    _stringTrasform = stringTrasform;
    self.placeholder = self.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
    NSString *localizedPlaceholder = NSLocalizedString(placeholder, nil);
    _placeholder = localizedPlaceholder;
    self.placeholderLabel.text = localizedPlaceholder;
    [self setNeedsDisplay];
}

- (void)setupObserver {
    __weak __typeof(self) weakSelf = self;
    self.changeEditingObserver = [AIMNotificationObserver observeName:UITextViewTextDidChangeNotification onChange:^(NSNotification *notification) {
        [weakSelf togglePlaceholder:notification];
    }];
}

- (void)togglePlaceholder:(NSNotification *)notification {
    AIMTextView *textView = notification.object;
    if (![self validateTextView:textView]) {
        return;
    }
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (BOOL)validateTextView:(UITextView *)textView {
    if (![textView isKindOfClass:[AIMTextView class]]) {
        return NO;
    }
    if (textView != self) {
        return NO;
    }
    return YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ([self.text length] == 0) {
        CGSize placeHoledrSize = [self.placeholderLabel sizeThatFits:self.frame.size];
        CGRect placeHolderFrame = self.placeholderLabel.frame;
        placeHolderFrame.size = placeHoledrSize;
        self.placeholderLabel.frame = placeHolderFrame;
        [self.placeholderLabel drawTextInRect:self.placeholderLabel.frame];
    } else {
        self.underlineColor = [UIColor projectTomatoColor];
        textViewLineWidth = activeTextViewLineWidth;
    }
    CGPoint startPoint = (CGPoint){0, rect.size.height - 1};
    CGPoint endPoint = (CGPoint){rect.size.width, rect.size.height - 1};
    [UIView drawLineFromPoint:startPoint toPoint:endPoint width:textViewLineWidth color:self.underlineColor];
}

- (UIColor *)underlineColor {
    if (_underlineColor) {
        return _underlineColor;
    }
    _underlineColor = [UIColor projectPinkishGreyColor];
    return _underlineColor;
}

- (CGFloat)calculatedHeight {
    CGSize contentSize;
    if (self.text.length > 0) {
        contentSize = [self sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    } else {
        contentSize = [self.placeholderLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
        contentSize.height += 4;
    }
    return  ceil(contentSize.height + magicNumberToFixSizing);
    
}

- (BOOL)validate {
    return self.text.length > 0;
}

- (UILabel *)placeholderLabel {
    if (_placeholderLabel) {
        return _placeholderLabel;
    }
    _placeholderLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 8, 100, 50}];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.textColor = [UIColor projectPinkishGreyColor];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.font = self.font;
    return _placeholderLabel;
}

@end
