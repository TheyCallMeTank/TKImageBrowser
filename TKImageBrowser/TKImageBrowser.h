//
//  TKImageBrowser.h
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/16.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  一张图片的信息
 */
@interface TKImageItem : NSObject

@property (nonatomic, weak) UIView *thumbView;
@property (nonatomic, weak) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;

@end

/**
 *  图片浏览器
 */
@interface TKImageBrowser : UIView

@property (nonatomic, readonly) NSArray<TKImageItem *> *imageItems;
@property (nonatomic, readonly) NSInteger currentPage;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImageItems:(NSArray *)items;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)presentToContainer:(UIView *)container
                 currentPage:(NSInteger)currentPage
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end
