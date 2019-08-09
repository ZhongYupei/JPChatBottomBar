//
//  JPMoreInputView.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPMoreInputView.h"
#import "JPMoreCVCell.h"
#import "UIView+JPExtension.h"


@interface JPMoreInputView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSInteger _perRowNumber;         // 每一行item的数量
    CGFloat _itemSpacing;           // item之间的间距
    CGFloat _lineSpacing;           // 每一行之间的间距
    CGFloat _itemWidth;
    CGFloat _itemHeight;
    
    CGFloat _collectionViewHeight;
    CGFloat _contentInsetX;         // 左右内容视图偏移量
    CGFloat _contentInsetY;         // 上下内容视图偏移量
}
@property (strong, nonatomic) UICollectionView * cv;

@property (strong, nonatomic) NSArray * dataArr;
@end


@implementation JPMoreInputView
NSString * kJPMoreItemImageKey = @"image";
NSString * kJPMoreItemImageStrKey = @"imageStr";
NSString * kJPMoreItemNameKey = @"name";
#pragma mark publickMethod
- (instancetype)init {
    self = [super init];
    if(self){
        // 从plist 文件中加载图片数据
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPMoreBundle" ofType:@"bundle"];
        NSBundle * bundle = [NSBundle bundleWithPath:path];
        NSString * plistPath = [bundle pathForResource:@"JPMorePackageList" ofType:@"plist"];
        NSArray * arr = [NSArray arrayWithContentsOfFile:plistPath];
        NSMutableArray * tmpArr = [NSMutableArray array];
        for (NSDictionary * dict in arr) {
            NSMutableDictionary * tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            NSString * imagePath = [[bundle bundlePath] stringByAppendingPathComponent:dict[kJPMoreItemImageStrKey]];
            UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
            [tmpDict setValue:image forKey:kJPMoreItemImageKey];
            [tmpArr addObject:tmpDict];
        }
        
        _dataArr = tmpArr;
        [self setUpDefaultDataAboutUI];
        self.height = _collectionViewHeight;
        self.backgroundColor = RGB(240, 240, 240);
    }
    return self;
}
// 设置与UI相关的数据
- (void)setUpDefaultDataAboutUI {
    // 设置默认数据
    _perRowNumber = 4;
    self.width = SCREEN_WIDTH;
    _itemWidth = 60;
    _itemHeight = 85;
    _itemSpacing = (self.width - _perRowNumber * _itemWidth)/5;
    _lineSpacing = 10;
    _contentInsetX  = _itemSpacing;
    _contentInsetY = _lineSpacing;
    NSInteger totalRow ;
    totalRow = (int)_dataArr.count / _perRowNumber;
    if(totalRow * _perRowNumber < _dataArr.count) {
        totalRow ++;
    }
    _collectionViewHeight = totalRow * _itemHeight + (totalRow -1 )*_lineSpacing + 2 * _contentInsetY;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置UI
    [self addSubview:self.cv];
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickItemOnMoreIVWithInfo:)]){
        NSDictionary * dict = [self.dataArr objectAtIndex:indexPath.row];
        [self.delegate clickItemOnMoreIVWithInfo:dict];
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPMoreCVCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPMoreCVCEll_ID forIndexPath:indexPath];
    NSDictionary * dict = [self.dataArr objectAtIndex:indexPath.row];
    [cell setInfoWithDict:dict];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemHeight);
}
#pragma mark getter
- (UICollectionView *)cv{
    if(!_cv){
        UICollectionViewFlowLayout * flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowlayout.minimumLineSpacing = _lineSpacing;
        flowlayout.minimumInteritemSpacing = _itemSpacing;
        UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _cv = collectionView;
        collectionView.x = collectionView.y = 0;
        collectionView.width = self.width;
        collectionView.height = self.height;
        collectionView.backgroundColor = RGB(246,246, 246);
        collectionView.contentInset = UIEdgeInsetsMake(_contentInsetY, _contentInsetX, _contentInsetY, _contentInsetX);
        [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JPMoreCVCell class]) bundle:nil] forCellWithReuseIdentifier:JPMoreCVCEll_ID];
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    return _cv;
}
@end
