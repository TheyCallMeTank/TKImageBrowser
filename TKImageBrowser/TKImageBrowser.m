//
//  TKImageBrowser.m
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/16.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import "TKImageBrowser.h"
#import "YYWebImage.h"
#import "TKPageControl.h"

#define AnimationDuration 0.2

@interface UIView (TKAdd)

@property (nonatomic, readonly) UIViewController *viewController;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

@end

@implementation UIView (TKAdd)

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

@interface TKImageItem()

@property (nonatomic, readonly) UIImage *thumbImage;

@end

@implementation TKImageItem

- (UIView *)thumbView{
    if (!_thumbView) {
        return [UIView new];
    }
    return _thumbView;
}

- (UIImage *)thumbImage{
    if ([self.thumbView respondsToSelector:@selector(image)]) {
        return [self.thumbView performSelector:@selector(image) withObject:nil];
    }
    return nil;
}

@end

@class TKImageBrowserCell;
@protocol TKImageBrowserCellDelegate <NSObject>

@optional
- (void)imageBrowserCellDidZoom:(TKImageBrowserCell *)imageBrowserCell;
- (void)imageBrowserCellWillBeginZooming:(TKImageBrowserCell *)imageBrowserCell withView:(UIView *)view;
- (void)imageBrowserCellDidEndZooming:(TKImageBrowserCell *)imageBrowserCell withView:(UIView *)view atScale:(CGFloat)scale;

@end

@interface TKImageBrowserCell : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<TKImageBrowserCellDelegate> imageBrowserCellDelegate;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) TKImageItem *item;
@property (nonatomic, assign) NSInteger page;

@end

@implementation TKImageBrowserCell

- (instancetype)init{
    self = [super init];
    
    if (!self) return nil;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.multipleTouchEnabled = YES;
    self.maximumZoomScale = 3.0;
    self.minimumZoomScale = 1.0;
    [self setFrame:[UIScreen mainScreen].bounds];
    
    _contentView = [UIView new];
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    
    _imageView = [YYAnimatedImageView new];
    _imageView.clipsToBounds = YES;
    
    [_contentView setFrame:self.bounds];
    [_imageView setFrame:self.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:_imageView];
    
    //加载进度
    CGFloat progressWidth = 40;
    _progressLayer = [CAShapeLayer layer];
    [_progressLayer setFrame:CGRectMake(self.width/2 - progressWidth/2, self.height/2 - progressWidth/2, progressWidth, progressWidth)];
    _progressLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, progressWidth, progressWidth)];
    _progressLayer.path = path.CGPath;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    
    return self;
}

- (void)setItem:(TKImageItem *)item{
    _item = item;
    
    if (item.image) {
        [_imageView setImage:item.image];
    }else{
        __weak __typeof(self) weakSelf = self;
        [_imageView yy_setImageWithURL:item.imageUrl placeholder:item.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            _progressLayer.hidden = NO;
            CGFloat progress = receivedSize*1.0/expectedSize;
            progress = progress == 0 ? 0.1 : progress > 1 ? 1 : progress;
            weakSelf.progressLayer.strokeEnd = progress;
        } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            _progressLayer.hidden = YES;
            if (stage == YYWebImageStageFinished) {
                if (image) {
                    [self resizeSubviewSize];
                }
            }
        }];
    }
    
    [self resizeSubviewSize];
}

- (void)resizeSubviewSize{
    [_contentView setFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    
    UIImage *image = _imageView.image;
    if (image) {
        _contentView.height = image.size.height * (self.width / image.size.width);
        if (image.size.height / image.size.width > self.bounds.size.height / self.bounds.size.width) {
        }else{
            _contentView.centerY = self.height/2;
        }
    }
    
    [self setContentSize:CGSizeMake(self.width, MAX(_contentView.height, self.height))];
    [self scrollRectToVisible:self.bounds animated:NO];
    
    self.alwaysBounceVertical = _contentView.height > self.height;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _contentView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellWillBeginZooming:withView:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellWillBeginZooming:self withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidEndZooming:withView:atScale:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellDidEndZooming:self withView:view atScale:scale];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if ([self.imageBrowserCellDelegate respondsToSelector:@selector(imageBrowserCellDidZoom:)]) {
        [self.imageBrowserCellDelegate imageBrowserCellDidZoom:self];
    }
    
    UIView *subView = _contentView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@interface TKImageBrowser()<UIScrollViewDelegate,TKImageBrowserCellDelegate>

@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) TKPageControl *pageControl;

@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic, strong) NSMutableArray *cells;

@end

@implementation TKImageBrowser{
    BOOL _fromStatusHidden;
}

- (instancetype)initWithImageItems:(NSArray *)items{
    self = [super init];
    
    if (!items.count) return nil;
    _imageItems = [items copy];
    _cells = @[].mutableCopy;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    _backgroundView = [UIImageView new];
    _backgroundView.frame = self.bounds;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _blurBackground = [UIImageView new];
    _blurBackground.frame = self.bounds;
    _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = [UIView new];
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _scrollView = [UIScrollView new];
    _scrollView.frame = self.bounds;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.alwaysBounceHorizontal = items.count > 1;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _pageControl = [[TKPageControl alloc] init];
    _pageControl.numberOfPages = items.count;
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGFloat pageWidth = 50;
    [_pageControl setFrame:CGRectMake(self.right - pageWidth - 8, self.bottom - pageWidth - 8, pageWidth, pageWidth)];
    
    [self addSubview:_backgroundView];
    [self addSubview:_blurBackground];
    [self addSubview:_contentView];
    [_contentView addSubview:_scrollView];
    [_contentView addSubview:_pageControl];
    
    
    return self;
}

- (void)presentFromImageView:(UIView *)fromView toContainer:(UIView *)container currentPage:(NSInteger)currentPage animated:(BOOL)animated completion:(void (^)(void))completion{
    if (!container) return;
    
    _isShowed = YES;
    
    _fromView = fromView;
    _toContainerView = container;
    
    BOOL fromViewHidden = fromView.hidden;
    fromView.hidden = YES;
    [_backgroundView setImage:[self snapshotImageWithView:container]];
    fromView.hidden = fromViewHidden;
    
    _blurBackground.backgroundColor = [UIColor blackColor];
    _blurBackground.alpha = 0;
    _pageControl.alpha = 0;
    
    _fromItemIndex = currentPage;
    if (currentPage == 0) {
        for (NSInteger i=0; i<_imageItems.count; i++) {
            TKImageItem *item = _imageItems[i];
            if ([item.thumbView isEqual:fromView]) {
                currentPage = i;
                _fromItemIndex = i;
                break;
            }
        }
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.width*_imageItems.count, 0);
    [_scrollView setContentOffset:CGPointMake(_scrollView.width*currentPage, 0)];
    [self scrollViewDidScroll:_scrollView];
    
    _pageControl.currentPage = currentPage;
    
    TKImageBrowserCell *cell = [self cellForPage:currentPage];
    TKImageItem *item = _imageItems[currentPage];
    
    cell.item = item;
    
    CGRect oldFrame = [_fromView convertRect:_fromView.bounds toView:cell];
    if (CGRectEqualToRect(_fromView.frame, CGRectNull) || CGRectEqualToRect(_fromView.frame, CGRectZero)) {
        oldFrame = CGRectMake(cell.width/2, cell.height/2, 0, 0);
    }
    CGRect newFrame = cell.contentView.frame;
    [cell.contentView setFrame:oldFrame];
    
    CGFloat animationTime = animated ? AnimationDuration : 0;
    [UIView animateWithDuration:animationTime animations:^{
        _blurBackground.alpha = 1;
        _pageControl.alpha = 1;
        [cell.contentView setFrame:newFrame];
    } completion:^(BOOL finished) {
        if (completion) completion();
        _fromStatusHidden = [UIApplication sharedApplication].statusBarHidden;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    }];
    
    [self setFrame:container.bounds];
    [container addSubview:self];
}

- (void)presentToContainer:(UIView *)container currentPage:(NSInteger)currentPage animated:(BOOL)animated completion:(void (^)(void))completion{
    [self presentFromImageView:nil toContainer:container currentPage:currentPage animated:animated completion:completion];
}

- (void)presentFromImageView:(UIView *)fromView toContainer:(UIView *)container animated:(BOOL)animated completion:(void (^)(void))completion{
    [self presentFromImageView:fromView toContainer:container currentPage:0 animated:animated completion:completion];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion{
    if (!_isShowed) return;
    
    [[UIApplication sharedApplication] setStatusBarHidden:_fromStatusHidden withAnimation:NO];
    
    TKImageBrowserCell *cell = [self cellForPage:self.currentPage];
    TKImageItem *item = _imageItems[self.currentPage];
    
    BOOL fromViewHidden = item.thumbView.hidden;
    item.thumbView.hidden = YES;
    self.hidden = YES;
    [_backgroundView setImage:[self snapshotImageWithView:_toContainerView]];
    item.thumbView.hidden = fromViewHidden;
    self.hidden = NO;
    
    CGRect targetFrame = [item.thumbView convertRect:item.thumbView.bounds toView:cell];
    if (CGRectEqualToRect(item.thumbView.frame, CGRectNull) || CGRectEqualToRect(item.thumbView.frame, CGRectZero)) {
        targetFrame = CGRectMake(cell.width/2, cell.height/2, 0, 0);
    }
    
    CGFloat animationTime = animated ? AnimationDuration : 0;
    [UIView animateWithDuration:animationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.blurBackground.alpha = 0;
        self.pageControl.alpha = 0;
        [cell.contentView setFrame:targetFrame];
    } completion:^(BOOL finished) {
        if(completion) completion();
        [self removeFromSuperview];
        _isShowed = NO;
    }];
}

- (void)dismiss{
    [self dismissAnimated:YES completion:nil];
}

#pragma mark - 手势

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if (!_isShowed) return;
    
    TKImageBrowserCell *cell = [self cellForPage:self.currentPage];
    if (cell) {
        if (cell.zoomScale != 1) {
            [cell setZoomScale:1.0 animated:YES];
        }else{
            if (cell.contentView.height/cell.contentView.width <= cell.height/cell.width) {
                CGFloat zoomScale = cell.height/cell.contentView.height;
                
                CGPoint tapPoint = [tap locationInView:cell.imageView];
                CGFloat xsize = self.width/zoomScale;
                CGFloat ysize = self.height/zoomScale;
                [cell zoomToRect:CGRectMake(tapPoint.x - xsize/2, tapPoint.y - ysize/2, xsize, ysize) animated:YES];
            }else{
                CGPoint tapPoint = [tap locationInView:cell.imageView];
                CGFloat xsize = self.width/cell.maximumZoomScale;
                CGFloat ysize = self.height/cell.maximumZoomScale;
                [cell zoomToRect:CGRectMake(tapPoint.x - xsize/2, tapPoint.y - ysize/2, xsize, ysize) animated:YES];
            }
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    if (!_isShowed) return;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        TKImageBrowserCell *cell = [self cellForPage:self.currentPage];
        if (cell.imageView.image) {
            UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:@[cell.imageView.image] applicationActivities:nil];
            
            UIViewController *toVC = self.toContainerView.viewController;
            if (!toVC) toVC = self.viewController;
            if (!toVC) toVC = self.fromView.viewController;
            [toVC presentViewController:activityViewController animated:YES completion:nil];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan{
    static CGFloat originY = 0;
    static CGFloat originX = 0;
    
    CGPoint offset = [pan translationInView:self];
    CGFloat progress = offset.y / (self.height/2);
    progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
    progress = 1 - progress;
    
    TKImageBrowserCell *cell = [self cellForPage:self.currentPage];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            TKImageItem *item = _imageItems[self.currentPage];
            BOOL fromViewHidden = item.thumbView.hidden;
            item.thumbView.hidden = YES;
            self.hidden = YES;
            [_backgroundView setImage:[self snapshotImageWithView:_toContainerView]];
            item.thumbView.hidden = fromViewHidden;
            self.hidden = NO;
            
            originY = cell.contentView.top;
            originX = cell.contentView.left;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (offset.y >= 0) {
                _blurBackground.alpha = progress;
                _pageControl.alpha = progress;
            }
            
            cell.contentView.top = originY + offset.y;
            cell.contentView.left = originX + offset.x;
        }
            
            break;
        case UIGestureRecognizerStateEnded:
            if (progress < 0.8) {
                [self dismiss];
            }else if (progress >= 0.8 && progress <= 1){
                [UIView animateWithDuration:AnimationDuration animations:^{
                    _blurBackground.alpha = 1;
                    _pageControl.alpha = 1;
                    cell.contentView.top = originY;
                    cell.contentView.left = originX;
                }];
            }
            break;
            
        default:
            break;
    }
}

- (NSInteger)currentPage{
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    
    page = page < 0 ? 0 : page;
    page = page >= _imageItems.count ? _imageItems.count - 1 : page;
    
    return page;
}

- (TKImageBrowserCell *)cellForPage:(NSInteger)page{
    for (TKImageBrowserCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - 重用

- (void)updateCellForReuse{
    for (TKImageBrowserCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

- (TKImageBrowserCell *)dequeueReusableCell{
    for (TKImageBrowserCell *cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    TKImageBrowserCell *cell = [TKImageBrowserCell new];
    cell.imageBrowserCellDelegate = self;
    cell.frame = self.bounds;
    cell.page = -1;
    [_cells addObject:cell];
    return cell;
}

#pragma mark - ScrollView代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateCellForReuse];
    
    //准备前一张和后一张图片
    for (NSInteger i=self.currentPage - 1; i<=self.currentPage + 1; i++) {
        if (i >= 0 && i < _imageItems.count) {
            TKImageBrowserCell *cell = [self cellForPage:i];
            if (!cell) {
                cell = [self dequeueReusableCell];
                
                if (_isShowed) {
                    cell.item = _imageItems[i];
                }
                cell.page = i;
                [_scrollView addSubview:cell];
                
                cell.left = _scrollView.width * i;
            }else{
                if (_isShowed && !cell.item) {
                    cell.item = _imageItems[i];
                }
            }
        }
    }
    
    _pageControl.currentPage = self.currentPage;
}

#pragma mark - ImageBrowserCell代理

//- (void)imageBrowserCellWillBeginZooming:(TKImageBrowserCell *)imageBrowserCell withView:(UIView *)view{
//    TKImageItem *item = _imageItems[self.currentPage];
//
//    BOOL fromViewHidden = item.thumbView.hidden;
//    item.thumbView.hidden = YES;
//    self.hidden = YES;
//    [_backgroundView setImage:[self snapshotImageWithView:_toContainerView]];
//    item.thumbView.hidden = fromViewHidden;
//    self.hidden = NO;
//}
//
//- (void)imageBrowserCellDidZoom:(TKImageBrowserCell *)imageBrowserCell{
//    CGFloat progress = imageBrowserCell.zoomScale*2 - 1.0;
//    progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
//
//    _blurBackground.alpha = progress;
//}
//
//- (void)imageBrowserCellDidEndZooming:(TKImageBrowserCell *)imageBrowserCell withView:(UIView *)view atScale:(CGFloat)scale{
//    if (scale < 0.8) {
//        [self dismiss];
//    }else if (scale >= 0.8 && scale < 1){
//        _blurBackground.alpha = 1;
//        [imageBrowserCell setZoomScale:1.0 animated:YES];
//    }
//}

/**
 *  得到一个View的快照
 */
- (UIImage *)snapshotImageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

@end
