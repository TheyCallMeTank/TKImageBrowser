//
//  ImageCVC.m
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/17.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import "ImageCVC.h"

@implementation ImageCVC

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    _imageView = [YYAnimatedImageView new];
    _imageView.layer.masksToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_imageView setFrame:self.bounds];
}

@end
