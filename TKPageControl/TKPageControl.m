//
//  TKPageControl.m
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/22.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import "TKPageControl.h"

#define AnimationDuration 0.3

@interface TKPageControl()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *pageLabel;

@property (nonatomic, assign) BOOL isToNext;

@end

@implementation TKPageControl

#pragma mark - 初始化

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    _hidesForSinglePage = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [UIView new];
    _contentView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _pageLabel = [UILabel new];
    _pageLabel.adjustsFontSizeToFitWidth = YES;
    self.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.font = [UIFont systemFontOfSize:15];
    _pageLabel.text = @"0/0";
    _pageLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:_contentView];
    [_contentView addSubview:_pageLabel];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    _pageLabel.textColor = currentPageIndicatorTintColor;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage{
    _hidesForSinglePage = hidesForSinglePage;
    
    if (_hidesForSinglePage && _numberOfPages < 2) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages{
    _numberOfPages = numberOfPages;
    
    if (_hidesForSinglePage && numberOfPages < 2) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }
    
    [self updateCurrentPageDisplay];
}

- (void)setCurrentPage:(NSInteger)currentPage{
    if (_currentPage == currentPage) {
        return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.duration = AnimationDuration/2;
    animation.fromValue = @0;
    if (_currentPage < currentPage) {
        animation.toValue = @M_PI_2;
        _isToNext = YES;
    }else{
        animation.toValue = @-M_PI_2;
        _isToNext = NO;
    }
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [_contentView.layer addAnimation:animation forKey:@"firstPart"];
    
    _currentPage = currentPage;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isEqual:[_contentView.layer animationForKey:@"firstPart"]]) {
        [self updateCurrentPageDisplay];
        
        [_contentView.layer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        animation.duration = AnimationDuration/2;
        if (_isToNext) {
            animation.fromValue = @-M_PI_2;
            animation.toValue = @0;
        }else{
            animation.fromValue = @M_PI_2;
            animation.toValue = @0;
        }
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [_contentView.layer addAnimation:animation forKey:@"secondPart"];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.width)];
    
    [_contentView setFrame:self.bounds];
    [_pageLabel setFrame:self.bounds];
}

- (void)drawRect:(CGRect)rect{
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.cornerRadius = rect.size.width/2;
}

- (void)updateCurrentPageDisplay{
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentPage+1,_numberOfPages];
}

@end
