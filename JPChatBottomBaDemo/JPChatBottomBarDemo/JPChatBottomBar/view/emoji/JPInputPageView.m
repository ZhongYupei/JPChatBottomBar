//
//  JPInputPageView.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPInputPageView.h"
#import "UIView+JPExtension.h"
#import "JPEmojiCVCell.h"
#import "JPLargeEmojiCVCell.h"
#import "JPEmojiPreview.h"
#import "JPGifPreview.h"

#define PreviewWidth 100
#define PreviewHeight 140

#define GIFPreviewWidht 120
#define GIFPreviewHeight 120
@interface JPInputPageView ()  <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    CGFloat _smallItemWH;                          /// 小表情item的宽高
    NSInteger _smallEmojiPerRowNumber;             ///小表情每行 的数量
    CGFloat _smallMargin;                          /// 小表情每个item之间的间距
    
    CGFloat _largeItemW;                           /// 大表情item的宽
    CGFloat _largeItemH;                           /// 大表情item的高
    NSInteger _largeEmojiPerRowNumber;             ///大表情每行 的数量
    CGFloat _largeMargin;                         /// 大表情每个item之间的间距
    CGFloat _largeLineMargin;                      /// 大表情中每一行的行间距
    UIColor * _longPressOnItemColor;                /// 正在处于按压状态的cell的背景颜色
    
    CGFloat _offsetY ;                              /// 边距
}
@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) NSBundle * emojiBundle;
@property (strong, nonatomic) NSArray <JPEmojiModel *> * emojiArr;
@property (assign, nonatomic) BOOL isShowLargeImage;
@property (strong, nonatomic) JPEmojiPreview * preview;
@property (strong, nonatomic) JPEmojiModel * currentModel;
@property (strong, nonatomic) UICollectionViewCell * currentCell;
@property (strong, nonatomic) JPGIfPreview * gifPreview;
@end
@implementation JPInputPageView
- (instancetype)initWithEmojiArr:(nullable NSArray *)emojiArr; {
    self = [super init];
    if(self){
        _smallEmojiPerRowNumber = 7;
        _largeEmojiPerRowNumber = IS_IPHONE_X ? 5:4;
        // 计算相关frame
        /// 小表情
        _smallItemWH = 35;
        _smallMargin = (SCREEN_WIDTH - _smallEmojiPerRowNumber *_smallItemWH) / (_smallEmojiPerRowNumber +1);
        /// 大表情
        _largeItemW = 60;
        _largeItemH = 70;
        _largeMargin = (SCREEN_WIDTH - _largeEmojiPerRowNumber * _largeItemW) / (_largeEmojiPerRowNumber +1);
        _offsetY = 10;
        _longPressOnItemColor = RGB(200, 200, 200);
        
        _isShowLargeImage = NO;
        _emojiArr = emojiArr;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self addCollectionView];
}
- (void)addCollectionView {
    UICollectionViewFlowLayout * flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowlayout.minimumLineSpacing = _smallMargin;
    flowlayout.minimumInteritemSpacing = _smallMargin;
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
    _collectionView = collectionView;
    collectionView.backgroundColor = RGB(230, 230, 230);
    collectionView.x = collectionView.y = 0;
    collectionView.width = self.width;
    collectionView.height = self.height;
    collectionView.contentInset = UIEdgeInsetsMake(_offsetY, _smallMargin, _offsetY, _smallMargin);
    collectionView.scrollEnabled = NO;
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JPEmojiCVCell class]) bundle:nil] forCellWithReuseIdentifier:JPEMOJICELL_ID];
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JPLargeEmojiCVCell class]) bundle:nil] forCellWithReuseIdentifier:JPLargeEmojiCVCell_ID];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self addSubview:collectionView];
    UILongPressGestureRecognizer * longGs = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [collectionView addGestureRecognizer:longGs];
}
- (void)longPressAction:(UILongPressGestureRecognizer *)longGs {
    CGPoint pointTouch = [longGs locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointTouch];
    if(!self.isShowLargeImage) {
        /// 加载小表情的表情包
        if(indexPath.row == 20 && !self.isShowLargeImage) {return;}
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        JPEmojiModel * model  =[self.emojiArr objectAtIndex:indexPath.row];
        if (longGs.state == UIGestureRecognizerStateBegan) {
            if (indexPath == nil) {
                NSLog(@"空");
            }else{
                CGRect  rect = [[UIApplication sharedApplication].windows.lastObject convertRect:cell.frame fromView:self.collectionView];
                rect.origin.x = cell.centerX - self.preview.width/2 + _smallMargin;
                rect.origin.y -= (self.preview.height - _smallItemWH - _offsetY);
                [self previewBeginWithModel:model withFrame:rect];
                self.currentModel = model;
            }
        }else if (longGs.state == UIGestureRecognizerStateChanged) {
            if(indexPath == nil) {return;}
            if([self.currentModel.emojiDesc isEqualToString:model.emojiDesc]) {
                return;
            }else {
                CGRect  rect = [[UIApplication sharedApplication].windows.lastObject convertRect:cell.frame fromView:self.collectionView];
                rect.origin.x = cell.centerX - self.preview.width/2 + _smallMargin;
                rect.origin.y -= (self.preview.height - _smallItemWH - _offsetY);
                [self previewBeginWithModel:model withFrame:rect];
                self.currentModel = model;
            }
        }else if (longGs.state == UIGestureRecognizerStateEnded) {
            [self.preview removeFromSuperview];
        }
    }else {
        /// 加载gif表情包
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        JPEmojiModel * model  =[self.emojiArr objectAtIndex:indexPath.row];
        if (longGs.state == UIGestureRecognizerStateBegan) {
            if (indexPath == nil) {
                NSLog(@"空");
            }else{
                cell.backgroundColor = _longPressOnItemColor;
                CGRect  rect = [[UIApplication sharedApplication].windows.lastObject convertRect:cell.frame fromView:self.collectionView];
                rect.origin.x = cell.centerX - self.gifPreview.width /2 + _largeMargin;
                rect.origin.y -= (self.gifPreview.height);
                rect.size.width = self.gifPreview.width;
                rect.size.height = self.gifPreview.height;
                [self gifPreviewWithModel:model withFrame:rect];
                self.currentModel = model;
                self.currentCell = cell;
            }
        }else if (longGs.state == UIGestureRecognizerStateChanged) {
            if(indexPath == nil) {return;}
            if([self.currentModel.emojiDesc isEqualToString:model.emojiDesc]) {
                return;
            }else {
                CGRect  rect = [[UIApplication sharedApplication].windows.lastObject convertRect:cell.frame fromView:self.collectionView];
                rect.origin.x = cell.centerX - self.gifPreview.width /2 + _largeMargin;
                rect.origin.y -= (self.gifPreview.height);
                rect.size.width = self.gifPreview.width;
                rect.size.height = self.gifPreview.height;
                cell.backgroundColor = _longPressOnItemColor;
                [self gifPreviewWithModel:model withFrame:rect];
                self.currentModel  = model;
                self.currentCell.backgroundColor = [UIColor clearColor];
                self.currentCell = cell;
            }
        }else if (longGs.state == UIGestureRecognizerStateEnded) {
            self.currentCell.backgroundColor = [UIColor clearColor];
            [self.gifPreview removeFromSuperview];
        }
    }
}
- (void)gifPreviewWithModel:(JPEmojiModel *)model withFrame:(CGRect)frame {
    if(!model){
        [self.preview removeFromSuperview];
        return;
    }
    self.gifPreview.frame = frame;
    self.gifPreview.model = model;
    [[[UIApplication sharedApplication] windows].lastObject addSubview:self.gifPreview];
}
- (void)previewBeginWithModel:(JPEmojiModel *)model withFrame:(CGRect)frame{
    // 预览开始
    if (!model) {
        [self.preview removeFromSuperview];
        return;
    }
    self.preview.frame = CGRectMake(frame.origin.x, frame.origin.y, PreviewWidth, PreviewHeight);
    self.preview.model = model;
    [[[UIApplication sharedApplication] windows].lastObject addSubview:self.preview];
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_isShowLargeImage ){
        if(indexPath.row <self.emojiArr.count) {
             JPEmojiModel * model = [self.emojiArr objectAtIndex:indexPath.row];
            if(self.delegate && [self.delegate respondsToSelector:@selector(clickLargeEmoji:)]){
                [self.delegate clickLargeEmoji:model];
            }
        }
    }else {
        if(indexPath.row == 20){
            // 点击了删除按钮
            if([self.delegate respondsToSelector:@selector(clickDeleteBtn)] && self.delegate){
                [self.delegate clickDeleteBtn];
            }
        }else if(indexPath.row < _emojiArr.count){
            JPEmojiModel * model = [self.emojiArr objectAtIndex:indexPath.row];
            if(self.delegate && [self.delegate respondsToSelector:@selector(clickSmallEmoji:)]){
                [self.delegate clickSmallEmoji:model];
            }
        }
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if(self.isShowLargeImage) {
        return _largeLineMargin;
    }else {
        return _smallMargin;
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if(self.isShowLargeImage) {
        return _largeMargin;
    }else {
        return _smallMargin;
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_isShowLargeImage) {
        return 2 * _largeEmojiPerRowNumber;
    }else {
        return 21;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isShowLargeImage) {
        JPLargeEmojiCVCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPLargeEmojiCVCell_ID forIndexPath:indexPath];
        if(indexPath.row < _emojiArr.count) {
            JPEmojiModel * model = [_emojiArr objectAtIndex:indexPath.row];
            cell.model = model;
        }else {
            cell.model = nil;
        }
        return cell;
    }else {
        JPEmojiCVCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPEMOJICELL_ID forIndexPath:indexPath];
        if(indexPath.row == 20){
            //  删除按钮
            UIImage * image = [UIImage imageWithContentsOfFile: [[self.emojiBundle bundlePath] stringByAppendingPathComponent:@"delete-emoji"]];
            cell.emojiImage = image;
        }else if (indexPath.row < _emojiArr.count) {
            JPEmojiModel * emojiModel = [_emojiArr objectAtIndex:indexPath.row];
            cell.model = emojiModel;
        }else {
            cell.emojiImage = nil;
        }
        return cell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isShowLargeImage ){
        return CGSizeMake(_largeItemW, _largeItemH);
    }else {
        return CGSizeMake(_smallItemWH, _smallItemWH);
    }
}

#pragma mark publicMethod
- (void)setEmojiArr:(NSArray <JPEmojiModel *> *)emojiArr isShowLargeImage:(BOOL)value{
    self.isShowLargeImage = value;
    _emojiArr = emojiArr;
    [self.collectionView reloadData];
    if(self.isShowLargeImage) {
        self.collectionView.contentInset = UIEdgeInsetsMake(_offsetY, _largeMargin, _offsetY, _largeMargin);
    }else {
        self.collectionView.contentInset = UIEdgeInsetsMake(_offsetY, _smallMargin, _offsetY, _smallMargin);
    }
}
#pragma mark getter
- (NSBundle *)emojiBundle {
    if(!_emojiBundle) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        _emojiBundle = [NSBundle bundleWithPath:path];
    }
    return _emojiBundle;
}
- (JPEmojiPreview *)preview {
    if(!_preview) {
        _preview = [[JPEmojiPreview alloc] init];
        _preview.x = 0;
        _preview.y = 0;
        _preview.width = PreviewWidth;
        _preview.height = PreviewHeight;
    }
    return _preview;
}
- (JPGIfPreview *)gifPreview {
    if(!_gifPreview) {
        _gifPreview = [[JPGIfPreview alloc] initWithFrame:CGRectMake(0, 0, GIFPreviewWidht, GIFPreviewHeight + 10 )];
    }
    return _gifPreview;
}
@end
