//
//  TKPageControl.h
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/22.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPageControl : UIControl

@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;

@property(nonatomic) BOOL hidesForSinglePage;

@property(nonatomic) BOOL defersCurrentPageDisplay;

- (void)updateCurrentPageDisplay;


@property(nullable, nonatomic,strong) UIColor *pageIndicatorTintColor;
@property(nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor;

@end
