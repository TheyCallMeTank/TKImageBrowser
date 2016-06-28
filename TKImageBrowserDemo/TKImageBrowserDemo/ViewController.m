//
//  ViewController.m
//  TKImageBrowserDemo
//
//  Created by 谭柯 on 16/6/16.
//  Copyright © 2016年 Tank. All rights reserved.
//

#import "ViewController.h"
#import "ImageCVC.h"
#import "TKImageBrowser.h"
#import "TKPageControl.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

static const NSString *CellIdenfier = @"CellIdenfier";

@implementation ViewController{
    NSArray *_images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _images = @[[UIImage imageNamed:@"先知维纶"],
                [UIImage imageNamed:@"加拉克苏斯"],
                [UIImage imageNamed:@"塞纳留斯"],
                [UIImage imageNamed:@"安东尼达斯"],
                [UIImage imageNamed:@"提里奥佛丁"],
                @"http://ww4.sinaimg.cn/mw690/b1072857gw1f5ad3yjikkj20hs9u1x6q.jpg",
                @"http://ww1.sinaimg.cn/mw690/79a00895jw1f5apau40xhg207805vx6p.gif",
                @"http://ww3.sinaimg.cn/mw690/e3a6dd5egw1f5aqhf1c4tj209m086758.jpg",
                @"https://github.com/TheyCallMeTank/TKCardDeckView/blob/master/TKCardDeckViewDemo/demo.gif?raw=true",
                [UIImage imageNamed:@"格罗玛什·地狱咆哮"],
                [UIImage imageNamed:@"爱德温范克里夫"],
                [UIImage imageNamed:@"霸王龙"]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[ImageCVC class] forCellWithReuseIdentifier:[CellIdenfier copy]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CellIdenfier copy] forIndexPath:indexPath];
    id image = _images[indexPath.row];
    if ([image isKindOfClass:[NSString class]]) {
        [cell.imageView setYy_imageURL:[NSURL URLWithString:image]];
    }else{
        [cell.imageView setImage:image];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.bounds.size.width/4 - 10, self.view.bounds.size.width/4 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIView *fromView = nil;
    
    NSMutableArray *items = [NSMutableArray new];
    for (NSInteger i=0; i<_images.count; i++) {
        UIImageView *imageView = [(ImageCVC *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] imageView];
        TKImageItem *item = [TKImageItem new];
        item.thumbView = imageView;
        id image = _images[i];
        if ([image isKindOfClass:[NSString class]]) {
            item.imageUrl = [NSURL URLWithString:image];
        }
        [items addObject:item];
        if (i == indexPath.row) {
            fromView = imageView;
        }
    }
    
    TKImageBrowser *imageBrowser = [[TKImageBrowser alloc] initWithImageItems:items];
    [imageBrowser presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
}

@end
