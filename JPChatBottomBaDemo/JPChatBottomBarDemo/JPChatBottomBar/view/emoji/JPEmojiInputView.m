//
//  JPEmojoInputView.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiInputView.h"
#import "JPInputPageView.h"
#import "UIView+JPExtension.h"
#import "JPEmojiManager.h"
#import "JPEmojiGroupModel.h"
#import "JPEmojiModel.h"
#import "JPEmojiBottomBar.h"




#define SingleEmojiWH   10

#define TabBarHeight     (IS_IPHONE_X?64:44)
#define ScrollViewHeight


@interface JPEmojiInputView () <UIScrollViewDelegate,JPEmojiBottomBarDelegate,JPInputPageViewDelegate>{
    NSInteger _currentGroup;         // 当前的表情包组
    NSInteger _pastPage;          // 当前的页数
    NSInteger _nextGroup;           // 下一组表情包所在的索引
}
@property (strong, nonatomic) UITextView * textView;        /// textView
@property (strong, nonatomic) UIScrollView * scrollView;    // 表情包底部视图
@property (strong, nonatomic) UIPageControl * pg;           // 分页控制器
@property (strong, nonatomic) JPEmojiBottomBar * tabBar;            //  底部横条
@property (strong, nonatomic) JPEmojiManager * emojiManager;
#pragma mark 三个view复用
@property (strong, nonatomic) JPInputPageView * leftPV;
@property (strong, nonatomic) JPInputPageView * currentPV;
@property (strong, nonatomic) JPInputPageView * rightPV;

@property (strong, nonatomic) NSArray <JPEmojiGroupModel *> * emojiGroupArr;
@property (strong, nonatomic) JPEmojiGroupModel * currentEmojiGroup;
@property (strong, nonatomic) JPEmojiGroupModel * nextEmojiGroup;
@end
@implementation JPEmojiInputView
#pragma mark publickMethod
- (void)setEmojiSendBtnEnabledOrNot:(BOOL)enabled {
    [self.tabBar setUpSendBtnEnabled:enabled];
}
- (instancetype)init{
    self = [super init];
    if(self){

        _pastPage = 0;
        _currentGroup = 0;
        self.width = SCREEN_WIDTH;
        self.height = IS_IPHONE_X?240:220;
        self.backgroundColor = RGB(230, 230, 230);
        self.emojiGroupArr = [self.emojiManager getEmogiGroupArr];
        [self.scrollView addSubview:self.leftPV];
        [self.scrollView addSubview:self.currentPV];
        [self.scrollView addSubview:self.rightPV];
        [self addSubview:self.pg];
        [self addSubview:self.tabBar];
    }
    return self;
}
#pragma mark getter
- (JPEmojiGroupModel *)currentEmojiGroup {
    if(_currentGroup <= self.emojiGroupArr.count -1){
        return [self.emojiGroupArr objectAtIndex:_currentGroup];
    }else {
        return nil;
    }
}
- (UIScrollView *)scrollView {
    if(!_scrollView) {
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.width = self.width;
        scrollView.height = self.height - TabBarHeight - self.pg.height;
        scrollView.x = 0;
        scrollView.y = 0;
        scrollView.pagingEnabled = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView = scrollView;
        [self addSubview:scrollView];
        scrollView.backgroundColor = self.backgroundColor;
        NSInteger totlaPages = 0;
        for(JPEmojiGroupModel * groupModel in self.emojiGroupArr) {
            totlaPages += groupModel.totalPages;
        }
        scrollView.contentSize = CGSizeMake(self.width * totlaPages, scrollView.height);
        scrollView.delegate = self;
    }
    return _scrollView;
}
- (JPInputPageView *)leftPV {
    if(!_leftPV) {
        NSArray * emojiArr =  [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage];
        _leftPV = [[JPInputPageView alloc] initWithEmojiArr:emojiArr];
        _leftPV.x = _leftPV.y = 0;
        _leftPV.width = self.width;
        _leftPV.height = self.height - self.tabBar.height - self.pg.height;
        _leftPV.delegate = self;
    }
    return _leftPV;
}
- (JPInputPageView *)currentPV {
    if(!_currentPV){
         NSArray * emojiArr =  [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage + 1];
        _currentPV = [[JPInputPageView alloc] initWithEmojiArr:emojiArr];
        _currentPV.x = CGRectGetMaxX(self.leftPV.frame);
        _currentPV.y = self.leftPV.y;
        _currentPV.height = self.leftPV.height;
        _currentPV.width = self.leftPV.width;
        _currentPV.delegate = self;
    }
    return _currentPV;
}
- (JPInputPageView *)rightPV {
    if(!_rightPV) {
        NSArray * emojiArr =  [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage + 2];
        _rightPV = [[JPInputPageView alloc] initWithEmojiArr:emojiArr];
        _rightPV.x = CGRectGetMaxX(self.currentPV.frame);
        _rightPV.y = self.leftPV.y;
        _rightPV.height = self.leftPV.height;
        _rightPV.width = self.leftPV.width;
        _rightPV.delegate = self;
    }
    return _rightPV;
}
- (JPEmojiManager *)emojiManager {
    return [JPEmojiManager sharedEmojiManager];
}
- (JPEmojiBottomBar *)tabBar {
    if(!_tabBar){
        _tabBar = [[JPEmojiBottomBar alloc] initWithGroupArr:self.emojiGroupArr];
        _tabBar.x = 0;
        _tabBar.y = self.height - _tabBar.height;
        _tabBar.backgroundColor = RGB(230, 230, 230);
        _tabBar.delegate = self;
    }
    return _tabBar;
}
- (UIPageControl *)pg {
    if(!_pg){
        _pg = [[UIPageControl alloc] init];
        _pg.pageIndicatorTintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        _pg.currentPageIndicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        
        _pg.height = 20;
        _pg.y = self.height - self.tabBar.height - _pg.height;
        _pg.centerX = self.width / 2;
        JPEmojiGroupModel * groupModel = [self.emojiGroupArr objectAtIndex:_currentGroup];
        _pg.numberOfPages = groupModel.totalPages;
        if(_pg.numberOfPages == 1){
            [_pg setHidden:YES];
        }else {
            [_pg setHidden:NO];
        }
    }
    return _pg;
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = scrollView.contentOffset.x/ self.width;
    NSInteger  currentIndexAtGroup = currentIndex;
    for(int i=0;i<_currentGroup;i++){
        JPEmojiGroupModel * model = [self.emojiGroupArr objectAtIndex:i];
        currentIndexAtGroup -= model.totalPages;
    }
    // 复用三个view
    if(currentIndexAtGroup != _pastPage){
        // 通过滑动来实现的
        JPInputPageView * tmpView ;
        self.pg.currentPage = currentIndexAtGroup;
        if(currentIndexAtGroup > _pastPage) {
            // 向右滑动
            if(currentIndexAtGroup == self.currentEmojiGroup.totalPages-1){
                // 加载到了该组表情包的最后一页
                if(_currentGroup < self.emojiGroupArr.count-1 ){
                    NSLog(@"不是最后一组表情包");
                    _nextGroup =  _currentGroup + 1;
                    self.nextEmojiGroup = [self.emojiGroupArr objectAtIndex:_nextGroup];
                    NSArray * arr = [self.emojiManager getEmojiArrGroup:_nextGroup page:0];
                    
                    [self.leftPV setEmojiArr:arr isShowLargeImage:self.nextEmojiGroup.isLargeEmoji];
                }else {
                    NSLog(@"是最后一组表情包");
                    // 不能再滑动
                    _pastPage = currentIndexAtGroup;
                    return;
                }
            }else if(currentIndexAtGroup > self.currentEmojiGroup.totalPages -1){
                // 滑倒了下一组表情包的首页
                _currentGroup ++;
                currentIndexAtGroup = 0;
                _pastPage = currentIndexAtGroup;
                self.currentEmojiGroup = [self.emojiGroupArr objectAtIndex:_currentGroup];
                NSArray * arr = [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage +1];
                [self.leftPV setEmojiArr:arr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
                self.pg.numberOfPages = self.currentEmojiGroup.totalPages;
                self.pg.currentPage = 0;
                
                [self.tabBar setUpBottomBarCurrentIndex:_currentGroup];
                
            }else{
                if(currentIndexAtGroup == 1 && _currentGroup == 0) {
                    // 第一页
                    _pastPage = currentIndexAtGroup;;
                    
                    return;
                }
                NSArray * arr = [self.emojiManager getEmojiArrGroup:_currentGroup page: currentIndexAtGroup + 1];
                [self.leftPV setEmojiArr:arr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
            }
            
            tmpView = self.leftPV;
            self.leftPV = self.currentPV;
            self.currentPV = self.rightPV;
            self.rightPV = tmpView;
            self.leftPV.x = (currentIndex -1)* scrollView.width;
            self.currentPV.x = CGRectGetMaxX(self.leftPV.frame);
            self.rightPV.x = CGRectGetMaxX(self.currentPV.frame);
            _pastPage = currentIndexAtGroup;
            
        }else {
            // 向左滑动
            if(currentIndexAtGroup == 0) {
                // 滑倒这个表情包的首页
                if(_currentGroup == 0) {
                    NSLog(@"第一组第一页的表情包");
                    _pastPage = 0;
                    return;
                }else {
                    NSLog(@"非第一组 第一页的表情包");
                    // 准备加载上一组
                    _nextGroup = _currentGroup - 1;
                    self.nextEmojiGroup = [self.emojiGroupArr objectAtIndex:_nextGroup];
                    NSArray * arr = [self.emojiManager getEmojiArrGroup:_nextGroup page:self.nextEmojiGroup.totalPages -1];
                    
                    [self.rightPV setEmojiArr:arr isShowLargeImage:self.nextEmojiGroup.isLargeEmoji];
                }
            }else if(currentIndexAtGroup < 0){
                NSLog(@"进入下一组表情包的最后一页");
                _currentGroup -- ;
                self.currentEmojiGroup = self.nextEmojiGroup;
                currentIndexAtGroup = self.currentEmojiGroup.totalPages -1 ;
                _pastPage = currentIndexAtGroup;
                NSArray * arr = [self.emojiManager getEmojiArrGroup:_currentGroup page: _pastPage -1];
                [self.rightPV setEmojiArr:arr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
                self.pg.numberOfPages = self.currentEmojiGroup.totalPages;
                self.pg.currentPage = self.currentEmojiGroup.totalPages-1;
                
                [self.tabBar setUpBottomBarCurrentIndex:_currentGroup];
                
            }else {
                // 加载组内的表情包
                NSLog(@"加载组内的表情包");
                if(_pastPage == self.currentEmojiGroup.totalPages -1 && _currentGroup == self.emojiGroupArr.count -1){
                    // 最右边的位置，不需要加载
                    _pastPage = currentIndexAtGroup;
                    return;
                }
                NSArray * arr = [self.emojiManager getEmojiArrGroup:_currentGroup page:currentIndexAtGroup-1];
                [self.rightPV setEmojiArr:arr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
            }
            tmpView = self.rightPV;
            self.rightPV = self.currentPV;
            self.currentPV = self.leftPV;
            self.leftPV = tmpView;
            self.leftPV.x = (currentIndex -1) *scrollView.width;
            self.currentPV.x = CGRectGetMaxX(self.leftPV.frame);
            self.rightPV.x = CGRectGetMaxX(self.currentPV.frame);
            _pastPage = currentIndexAtGroup;
        }
    }
}
- (void)selectEmojiGroup:(NSInteger)index {
    JPLog(@"切换表情");
    if(index == _currentGroup ) {
        // 用户正在使用这一组表情，什么都不做
        return;
    }
    _currentGroup = index;
    _pastPage = 0;
    JPEmojiGroupModel * groupModel = [self.emojiGroupArr objectAtIndex:index];
    self.currentEmojiGroup = groupModel;
    
    _pg.numberOfPages = groupModel.totalPages;
    _pg.currentPage = _pastPage;
    
    NSInteger offsetPages = 0;
    for (NSInteger i =0;i < index ;i++) {
        JPEmojiGroupModel * group = [self.emojiGroupArr objectAtIndex:i];
        offsetPages += group.totalPages;
    }
    // 改变scrollView的contentOffset会调用scrollView的代理方法,先取消代理
    self.scrollView.delegate = nil;
    self.scrollView.contentOffset = CGPointMake(offsetPages * self.scrollView.width , 0);
    self.scrollView.delegate = self;
    // 通过点击切换表情组来实现的
    if(index == 0) {
        NSArray * leftArr =  [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage];
        [self.leftPV setEmojiArr:leftArr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
        
        NSArray * currentArr = [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage +1];
        [self.currentPV setEmojiArr:currentArr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
        
        NSArray * rightArr = [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage +2];
        [self.rightPV setEmojiArr:rightArr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
        
        self.leftPV.x = 0;
        self.currentPV.x = CGRectGetMaxX(self.leftPV.frame);
        self.rightPV.x = CGRectGetMaxX(self.currentPV.frame);
    }else {
        JPEmojiGroupModel * groupModel = [self.emojiGroupArr objectAtIndex:_currentGroup -1];
        NSArray * leftArr =  [self.emojiManager getEmojiArrGroup:_currentGroup - 1 page:groupModel.totalPages -1];
        [self.leftPV setEmojiArr:leftArr isShowLargeImage:groupModel.isLargeEmoji];
        NSArray * currentArr = [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage ];
        [self.currentPV setEmojiArr:currentArr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
        NSArray * rightArr = [self.emojiManager getEmojiArrGroup:_currentGroup page:_pastPage +1];
        [self.rightPV setEmojiArr:rightArr isShowLargeImage:self.currentEmojiGroup.isLargeEmoji];
        self.currentPV.x = self.scrollView.contentOffset.x;
        self.rightPV.x = CGRectGetMaxX(self.currentPV.frame);
        self.leftPV.x = self.currentPV.x - self.scrollView.width;
    }
}
#pragma mark JPEmojiBottomBarDelegate
- (void)emojiBottomBarSendTextMsg {
    JPLog(@"点击发送表情");
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickSendBtnInputView:)]){
        [self.delegate clickSendBtnInputView:self];
    }
}
#pragma mark JPInputPageViewDelegate
- (void)clickLargeEmoji:(JPEmojiModel *)model {
    NSLog(@"点击了大表情");
    if(self.delegate && [self.delegate respondsToSelector:@selector(inputView:clickLargeEmoji:)]){
        [self.delegate inputView:self clickLargeEmoji:model];
    }
}
- (void)clickSmallEmoji:(JPEmojiModel *)model {
    NSLog(@"点击了小表情");
    if(self.delegate && [self.delegate respondsToSelector:@selector(inputView:clickSmallEmoji:)]) {
        [self.delegate inputView:self clickSmallEmoji:model];
    }
}
- (void)clickDeleteBtn {
   
    NSLog(@"点击了删除按钮");
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickDeleteBtnInputView:)]) {
        [self.delegate clickDeleteBtnInputView:self];
    }
    
}
@end
