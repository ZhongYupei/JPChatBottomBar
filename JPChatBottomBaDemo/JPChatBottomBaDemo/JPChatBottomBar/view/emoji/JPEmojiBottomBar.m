//
//  JPEmojiBottomBar.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiBottomBar.h"
#import "UIView+JPExtension.h"
#import "JPEmojiGroupModel.h"



#define TabBarHeight     (IS_IPHONE_X?64:44)
#define SendBtnHeight    (IS_IPHONE_X?70:55)
#define SendBtnWidth     (IS_IPHONE_X?80:70)

#define CVItemSpacing 10
#define CVItemLineSpacing 10

#define CurrentBtnColor      RGB(230, 230, 230);
#define NoCurrentBtnColor    RGB(240, 240, 240);

#define ImageFromGroupModel(a)  [UIImage imageWithContentsOfFile:[[self.emojiBundle pathForResource:a.folderName ofType:nil] stringByAppendingPathComponent:a.cover_picStr]]

@interface JPEmojiBottomBar ()<UIScrollViewDelegate> {
    NSInteger  _currentIndex;
}
@property (strong, nonatomic) NSArray <JPEmojiGroupModel *> * groupArr;
@property (strong, nonatomic) UIButton * sendBtn;

@property (strong, nonatomic) UIScrollView * scrollView;

@property (strong, nonatomic) NSBundle * emojiBundle;

@property (strong, nonatomic) NSMutableArray <UIButton *> * btnArr;



@end
@implementation JPEmojiBottomBar

- (instancetype)initWithGroupArr:(NSArray <JPEmojiGroupModel *> *)arr{
    self = [super init];
    if(self){
        _currentIndex = 0;
        _groupArr = arr;
        self.width = SCREEN_WIDTH;
        self.height = TabBarHeight;
        [self setUpSendBtn];
        [self setUpScrollView];
    }
    return  self;
}
#pragma mark publicMethod
- (void)setUpBottomBarCurrentIndex:(NSInteger)index {
    UIButton * selectedButton = [self.btnArr objectAtIndex:_currentIndex];
    selectedButton.backgroundColor = NoCurrentBtnColor;
    _currentIndex = index;
    UIButton * selectingButton = [self.btnArr objectAtIndex:index];
    selectingButton.backgroundColor = CurrentBtnColor;
}

- (void)setUpSendBtnEnabled:(BOOL)enabled {
    if(enabled) {
        // 可以点击的状态
        self.sendBtn.backgroundColor = [UIColor blueColor];
        [self.sendBtn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        self.sendBtn.enabled = YES;
        
    }else {
        // 不可以点击的状态
        self.sendBtn.backgroundColor = [UIColor whiteColor];
        [self.sendBtn setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        self.sendBtn.enabled = NO;
    }
}


#pragma mark selfMethod
- (void)setUpSendBtn {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor blueColor];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTitle:@"发送" forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.height = IS_IPHONE_X?60:self.height;
    button.width = 60;
    button.y = 0;
    button.x = self.width - button.width;
    [self addSubview:button];
    [button addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchDown];
    _sendBtn = button;
}
- (void)setUpScrollView{
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = RGB(240, 240, 240);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO ;
    scrollView.delegate = self;
    scrollView.x = 0;
    scrollView.y = 0;
    scrollView.width = self.width - _sendBtn.width;
    scrollView.height = _sendBtn.height;
    _scrollView = scrollView;
    [self addSubview:scrollView];
    [self addBtnToScrollView];
}
- (void)addBtnToScrollView {
    CGFloat btnWidth =IS_IPHONE_X?60:self.height;
    for(int index = 0 ;index<self.groupArr.count;index++){
        JPEmojiGroupModel * groupModel = [self.groupArr objectAtIndex:index];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.height = button.width = btnWidth;
        [button setImage:ImageFromGroupModel(groupModel) forState:UIControlStateNormal];
        [button setImage:ImageFromGroupModel(groupModel) forState:UIControlStateHighlighted];
        [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        button.y = 0;
        button.tag = index;
        [button addTarget:self action:@selector(emojiGroupBtnAction:) forControlEvents:UIControlEventTouchDown];
        button.x = index * button.width;
        [_scrollView addSubview:button];
        
        [self.btnArr addObject:button];
    }
    _scrollView.contentSize = CGSizeMake(self.groupArr.count * btnWidth, self.height);
    [self setUpBottomBarCurrentIndex:0];
}

#pragma mark JPEmojiBottomBarDelegate
- (void)emojiGroupBtnAction:(UIButton *)btn {
    [self setUpBottomBarCurrentIndex:btn.tag];
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectEmojiGroup:)]){
        [self.delegate selectEmojiGroup:btn.tag];
    }
}
- (void)sendAction:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(emojiBottomBarSendTextMsg)]){
        [self.delegate emojiBottomBarSendTextMsg];
    }
}
#pragma mark getter
- (NSMutableArray <UIButton *> * )btnArr {
    if(!_btnArr) {
        _btnArr = [NSMutableArray array];
        
    }
    return _btnArr;
}
- (NSBundle *)emojiBundle {
    if(!_emojiBundle) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        _emojiBundle = [NSBundle bundleWithPath:path];
    }
    return _emojiBundle;
}
@end
