//
//  JPMsgEditAgentView.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPChatBottomBar.h"
#import "UIView+JPExtension.h"
#import "JPPlayerHelper.h"
#import "JPAudioView.h"
#import "JPEmojiInputView.h"
#import "JPMoreInputView.h"
#import "JPEmojiModel.h"

#define SubView_Margin  12
#define Btn_Width_Height (IS_IPHONE_X?40:35)
#define BottomBarHeight (IS_IPHONE_X?83:55)
#define TextViewFont [UIFont fontWithName:@"Arial" size:(IS_IPHONE_X?20.0:15)]
#define MaxTextViewHeight (IS_IPHONE_X? 135:110 )
//#define KeyBoardHeight
@interface JPChatBottomBar ()<UITextViewDelegate,JPPlayerHelperDelegate,JPMoreInputViewDelegate,JPEmojiInputViewDelegate> {
    CGFloat _bottomHeight ;
    CGFloat _btnWH;
    CGFloat _subViewMarginToTop;
    CGFloat _currentTextViewHeight ;
    CGFloat _currentTextViewContentHeight;
//
//    CGRect _oldRect;
//    CGRect _newRect;
}
@property (assign, nonatomic) CGRect oldRect;
@property (assign, nonatomic) CGRect newRect;
@property (strong, nonatomic) UIButton * changeStateBtn;      // 切换键盘状态（语音、文本）
@property (assign, nonatomic) BOOL isAudioState;

@property (strong, nonatomic) JPAudioView * audioView;        // 语音按钮
@property (strong ,nonatomic) UIButton * moreBtn;             // 更多视图按钮
@property (strong, nonatomic) UITextView * textView;          // 文本输入框
@property (strong, nonatomic) UIButton * emojiBtn;            // emoji按钮

@property (strong, nonatomic) JPPlayerHelper * helper;          /// 负责音频的播放和录音
@property (strong, nonatomic) NSString * audioPowerStr;         /// 音频文件所存放的本地路径

@property (strong, nonatomic) JPEmojiInputView * emojiIV;       //   表情包inputView
@property (strong, nonatomic) JPMoreInputView * moreIV;         //   更多 inputView
@end

@implementation JPChatBottomBar
static int imageIndex = 1;
NSString * const MsgAgentViewWillChangeNoti = @"TextViewWillChangeNoti";
NSString * const MsgAgentViewHeightInfoKey = @"TextViewContentHeightInfoKey";
#pragma mark getter
- (JPMoreInputView *)moreIV {
    if(!_moreIV){
        _moreIV = [[JPMoreInputView alloc] init];
        _moreIV.delegate = self;
    }
    return _moreIV;
}
- (JPEmojiInputView *)emojiIV {
    if(!_emojiIV){
        _emojiIV = [[JPEmojiInputView alloc] init];
        _emojiIV.delegate = self;
        [_emojiIV setEmojiSendBtnEnabledOrNot:NO];
    }
    return _emojiIV;
}
- (JPPlayerHelper *)helper {
    if(!_helper){
        _helper = [[JPPlayerHelper alloc] initWithRecorderPath:nil];
        _helper.delegate = self;
    }
    return _helper;
}
- (JPAudioView *)audioView {
    if(!_audioView) {
        JPAudioView * tmpView = [[JPAudioView alloc] initWithFrame:CGRectMake(self.textView.x, self.textView.y, self.textView.width,  _btnWH )];
        [self addSubview:tmpView];
        _audioView = tmpView;
        // 实现audioView的方法
        __weak typeof (self) wSelf = self;
        _audioView.pressBegin = ^{
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:@"zhengzaiyuyin_1"] text:@"松开手指，上滑取消"];
            // 开始录音
            [wSelf.helper jp_recorderStart];
        };
        _audioView.pressingUp = ^{
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:@"songkai"] text:@"松开手指，取消发送"];
        };
        _audioView.pressingDown = ^{
            NSString * imgStr = [NSString stringWithFormat:@"zhengzaiyuyin_%d",imageIndex];
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:imgStr] text:@"松开发送，上滑取消"];
        };
        _audioView.pressEnd = ^{
            [wSelf.audioView setAudioViewHidden];
            [wSelf.helper jp_recorderStop];
            NSString * filePath = [wSelf.helper getfilePath];
            NSData * audioData = [NSData dataWithContentsOfFile:filePath];
            if(wSelf.agent && [wSelf.agent respondsToSelector:@selector(msgEditAgentAudio:)]){
                [wSelf.agent msgEditAgentAudio:audioData];
            }
        };
        /// 语音的强度
        self.audioPowerStr = @"";
    }
    return _audioView;
}
- (UIButton *)changeStateBtn {
    if(!_changeStateBtn) {
        UIButton * btn = [self btnWithNorImage:@"yuyin_normal" selectedImage:@"yuyin_press" btnAction:@selector(changeAgentState:) x:12];
        _changeStateBtn = btn;
    }
    return _changeStateBtn;
}
- (void)changeAgentState:(UIButton *)button {
    _isAudioState = !_isAudioState;
    [self resignFirstResponder];
    if(_isAudioState) {
        JPLog(@"切换语音状态");
        _keyBoardState = JPKeyBoardStateAudio;
        [button setImage:[UIImage imageNamed:@"jianpan_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"jianpan_press"] forState:UIControlStateHighlighted];
        self.audioView.hidden = NO;
        self.textView.hidden = YES;
        self.height =  _bottomHeight;
        self.y = SCREEN_HEIGHT - self.height;
        [self reloadSubView];
    }else {
        JPLog(@"切换键盘状态");
        [button setImage:[UIImage imageNamed:@"yuyin_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"yuyin_press"] forState:UIControlStateHighlighted];
        self.audioView.hidden = YES;
        self.textView.hidden = NO;
        [self textViewTapAction:nil];
        [self textViewDidChange:self.textView];
        self.height = self.textView.height + 2 * _subViewMarginToTop;
        self.y = SCREEN_HEIGHT -self.height;
        [self reloadSubView];
    }
    [self postNotiWithMsgAgentViewHeight];
}
- (UITextView *)textView {
    if(!_textView) {
        UITextView * textView = [[UITextView alloc] init];
        // frame 设
        textView.x = CGRectGetMaxX(self.changeStateBtn.frame) + SubView_Margin;
        textView.height =  _btnWH ;
        textView.centerY = self.height / 2  ;
        textView.width = self.emojiBtn.x - SubView_Margin - textView.x;
        _textView = textView;
        // 配置
        textView.enablesReturnKeyAutomatically = YES;
        textView.font = TextViewFont ;
        textView.layer.cornerRadius = 7;
        _textView.delegate = self;
        textView.showsVerticalScrollIndicator = NO;
        textView.scrollEnabled = NO;
        textView.returnKeyType = UIReturnKeySend;
        // 添加点击手势来使得从其他状态切换惠
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapAction:)];
        [_textView addGestureRecognizer:tap];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeRect:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
    }
    return _textView;
}
- (void)keyboardWillChangeRect:(NSNotification *)noti {
    NSValue * aValue =  noti.userInfo[UIKeyboardFrameBeginUserInfoKey];
    self.oldRect = [aValue CGRectValue];
    NSValue * newValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
    self.newRect = [newValue CGRectValue];
   
    
    [UIView animateWithDuration:0.3 animations:^{
        if(self.superview.y == 0) {
            self.superview.y -= self.newRect.size.height;
        }else {
            self.superview.y -=(self.newRect.size.height - self.oldRect.size.height);
        }
    } completion:^(BOOL finished) {
    }];
}
- (void)textViewTapAction:(UITapGestureRecognizer *)tap{
    [self.textView becomeFirstResponder];
    if([self.textView isFirstResponder] && [self.textView isEditable])    return;
    _keyBoardState = JPKeyBoardStateTextView;
    self.textView.inputView = nil;
    self.textView.editable = YES;
    [self.textView becomeFirstResponder];

}
- (UIButton *)emojiBtn {
    if(!_emojiBtn) {
        UIButton * btn = [self btnWithNorImage:@"biaoqing_normal" selectedImage:@"biaoqing_press" btnAction:@selector(emojiViewPop:) x:self.moreBtn.x - SubView_Margin -  _btnWH ];
        _emojiBtn = btn;
    }
    return _emojiBtn;
}
- (void)emojiViewPop:(UIButton *)button {
    JPLog(@"选择表情");
    
    if(_keyBoardState == JPKeyBoardStateEmoji)      return;
    [self.textView resignFirstResponder];
    _keyBoardState = JPKeyBoardStateEmoji;
    if(_isAudioState) {
        [self emojiAndMoreStateToTextViewState];
    }
    self.textView.editable = NO;
    self.textView.inputView = self.emojiIV;
    
    [self.textView becomeFirstResponder];
}
// 切换成文本框输入模式
- (void)emojiAndMoreStateToTextViewState {
    _isAudioState = !_isAudioState;
    [UIView animateWithDuration:0.25 animations:^{
        [self.changeStateBtn setImage:[UIImage imageNamed:@"yuyin_normal"] forState:UIControlStateNormal];
        [self.changeStateBtn setImage:[UIImage imageNamed:@"yuyin_press"] forState:UIControlStateHighlighted];
        self.audioView.hidden = YES;
        self.textView.hidden = NO;
    }];
    self.textView.inputView = nil;
    [self.textView resignFirstResponder];
    [self textViewDidChange:self.textView];
    self.height = self.textView.height + 2 * _subViewMarginToTop;
    self.y = SCREEN_HEIGHT -self.height;
    [self reloadSubView];
}
- (UIButton *)moreBtn {
    if(!_moreBtn) {
        UIButton * btn = [self btnWithNorImage:@"gengduo_normal" selectedImage:@"gengduo_press" btnAction:@selector(moreViewAction:) x:SCREEN_WIDTH - SubView_Margin -  _btnWH ];
        _moreBtn = btn;
    }
    return _moreBtn;
}
- (void)moreViewAction:(UIButton *)button {
    JPLog(@"点击更多按钮");
    if(_keyBoardState == JPKeyBoardStateMore)   return;
    [self.textView resignFirstResponder];
    _keyBoardState = JPKeyBoardStateMore;
    if(_isAudioState){
        [self emojiAndMoreStateToTextViewState];
    }
    self.textView.editable = NO;
    self.textView.inputView = self.moreIV;
    [self.textView becomeFirstResponder];
}
#pragma mark JPMoreInputViewDelegate
- (void)clickItemOnMoreIVWithInfo:(NSDictionary *)dict {
    if(self.agent && [self.agent respondsToSelector:@selector(msgEditAgentClickMoreIVItem:)]) {
        [self resignFirstResponder];
        [self.agent msgEditAgentClickMoreIVItem:dict];
    }
}

#pragma makr JPEmojiInputViewDelegate
- (void)inputView:(JPEmojiInputView *)inputView clickSmallEmoji:(JPEmojiModel *)model {
    // 点击小表情并且嵌入表情
    NSRange oldRange = self.textView.selectedRange;
    NSMutableString * str = [NSMutableString stringWithString:self.textView.text];
    [str insertString:model.emojiDesc atIndex:self.textView.selectedRange.location];
    self.textView.text = str;
    self.textView.selectedRange = NSMakeRange(oldRange.location + model.emojiDesc.length, 0);
    [self textViewDidChange:self.textView];
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}
- (void)inputView:(JPEmojiInputView *)inputView clickLargeEmoji:(JPEmojiModel *)model {
    // 点击大表情包 提供给外部
    if(self.agent && [self.agent respondsToSelector:@selector(msgEditAgentSendBigEmoji:)]){
        NSData * imageData = [NSData dataWithContentsOfFile:model.imageFullPath];
        [self.agent msgEditAgentSendBigEmoji:imageData];
    }
}
// 点击了发送文本消息的按钮
- (void)clickSendBtnInputView:(JPEmojiInputView *)inputView {
    if(self.agent && [self.agent respondsToSelector:@selector(msgEditAgentSendText:)]){
        [self.agent msgEditAgentSendText:self.textView.text];
    }
 
    self.textView.text = @"";
    [self textViewDidChange:self.textView];
}
// 点击了文本消息和活着表情包键盘的删除按钮
- (void)clickDeleteBtnInputView:(JPEmojiInputView *)inputView {
    NSString * souceText = [self.textView.text substringToIndex:self.textView.selectedRange.location];
    
    if(souceText.length == 0) {
        return;
    }
    NSRange  range = self.textView.selectedRange;
    NSLog(@"%@",NSStringFromRange(range));
    
    if(range.location == NSNotFound) {
        range.location = self.textView.text.length;
    }
    if(range.length > 0) {
        [self.textView deleteBackward];
        return;
    }else {
        // 正则表达式匹配要替换的文字的范围
        if([souceText hasSuffix:@"]"]){
            // 表示该选取字段最后一个是表情包
            if([[souceText substringWithRange:NSMakeRange(souceText.length-2, 1)] isEqualToString:@"]"]) {
                // 表示这只是一个单独的字符@"]"
                [self.textView deleteBackward];
                return;
            }
            // 正则表达式
            NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            NSError *error = nil;
            NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];if (!re) {NSLog(@"%@", [error localizedDescription]);}
            NSArray *resultArray = [re matchesInString:souceText options:0 range:NSMakeRange(0, souceText.length)];
            if(resultArray.count != 0) {
                /// 表情最后一段存在表情包字符串
                NSTextCheckingResult *checkingResult = resultArray.lastObject;
                NSString * resultStr = [souceText substringWithRange:NSMakeRange(0, souceText.length - checkingResult.range.length)];
                self.textView.text = [self.textView.text stringByReplacingCharactersInRange:NSMakeRange(0, souceText.length) withString:resultStr];
                self.textView.selectedRange = NSMakeRange(resultStr.length , 0);
            }else {
                [self.textView deleteBackward];
            }
        }else {
            // 表示最后一个不是表情包
            [self.textView deleteBackward];
        }
    }
    [self textViewDidChange:self.textView];
}

#pragma mark textViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    textView.scrollEnabled = YES;
    if(_currentTextViewContentHeight != textView.contentSize.height && textView.contentSize.height < MaxTextViewHeight ){
        // 表示内容视图发生变化
        CGFloat diff = textView.contentSize.height - _currentTextViewContentHeight;
        [UIView animateWithDuration:0.25f animations:^{
            textView.height += diff;
            self.height += diff;
            self.y -= diff;
            textView.contentOffset = CGPointZero;
            [self reloadSubView];
        } completion:^(BOOL finished) {
            textView.scrollEnabled = NO;
        }];
        _currentTextViewContentHeight = textView.contentSize.height;
        [self postNotiWithMsgAgentViewHeight];
    }else if(textView.contentSize.height >= MaxTextViewHeight) {
        textView.showsVerticalScrollIndicator = YES;
        textView.scrollEnabled = YES;
    }else {
        textView.scrollEnabled = NO;
        [textView setContentOffset:CGPointZero animated:NO];
    }
    // 设置表情包键盘的发送按钮 
    if(textView.text.length > 0){
        [self.emojiIV setEmojiSendBtnEnabledOrNot:YES];
    }else {
        [self.emojiIV setEmojiSendBtnEnabledOrNot:NO];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        // 换行
        [self clickSendBtnInputView:self.emojiIV];
        [self textViewDidChange:textView];
        return NO;
    }else if ([text isEqualToString:@""]){
        // 删除字符
        if(textView.text.length == 0 ){
            return YES;
        }
        [self clickDeleteBtnInputView:self.emojiIV];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark selfMethod
- (void)setUpSubView {
    [self addSubview:self.changeStateBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.emojiBtn];
    [self addSubview:self.textView];
}
- (UIButton *)btnWithNorImage:(NSString *)normalImage selectedImage:(NSString *)selectImage btnAction:(SEL)action x:(CGFloat)x{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width = button.height =  _btnWH ;
    button.x = x;
    button.centerY = self.height /2;
    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateHighlighted];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    return button;
}
// 重布局子视图
- (void)reloadSubView {
    CGFloat centerY = self.height  - _subViewMarginToTop -  _btnWH /2;
    self.changeStateBtn.centerY = centerY;
    self.emojiBtn.centerY = centerY;
    self.moreBtn.centerY = centerY;
    self.textView.centerY = self.height /2;
}
// 发送通知，通知外界自己的的高度变化
- (void)postNotiWithMsgAgentViewHeight{
    [[NSNotificationCenter defaultCenter] postNotificationName:MsgAgentViewWillChangeNoti object:nil userInfo:@{MsgAgentViewHeightInfoKey:[NSString stringWithFormat:@"%f",self.height],}];
}
#pragma mark publicMethod
- (instancetype)initWithBarHeight:(CGFloat)barHeight btnHeight:(CGFloat)btnWH{
    self = [super init];;
    if(self) {
        _bottomHeight = barHeight==0? BottomBarHeight:barHeight;
        _btnWH = btnWH==0? Btn_Width_Height:btnWH;
        _subViewMarginToTop  = (_bottomHeight - _btnWH) /2;
        self.backgroundColor = RGB(240, 240, 240);
        self.frame = CGRectMake(0, SCREEN_HEIGHT - _bottomHeight, SCREEN_WIDTH, _bottomHeight );
        [self setUpSubView];        // 初始化视图
        _currentTextViewHeight =  _btnWH ;
        _currentTextViewContentHeight = self.textView.contentSize.height;
        _keyBoardState = JPKeyBoardStateNone;

    }
    return self;
}
- (void)resignFirstResponder {
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.3 animations:^{
        self.superview.height = SCREEN_HEIGHT;
        self.superview.y = 0;
    }] ;
    _keyBoardState = JPKeyBoardStateNone;
}
- (void)moreIVBecomeFirstResponder  {
    [self moreViewAction:self.moreBtn];
}
- (void)emojiIVBecomeFirstResponder {
    [self emojiViewPop:self.emojiBtn];
}
#pragma mark Other
- (void) jpHelperRecorderStuffWhenRecordWithAudioPower:(CGFloat)power{
    NSLog(@"%f",power);
    NSString * newPowerStr =[NSString stringWithFormat:@"%f",[self.helper audioPower]];
    if([newPowerStr floatValue] > [self.audioPowerStr floatValue]) {
        if(imageIndex == 6){
            return;
        }
        imageIndex ++;
    }else {
        if(imageIndex == 1){
            return;
        }
        imageIndex --;
    }
    if(self.audioView.state == JPPressingStateUp) {
        self.audioView.pressingDown();
    }
    
    self.audioPowerStr =  newPowerStr;;
}
// kvo: audioPower 值发送变化的时候调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"inputView"] && object == self.textView ){
        UIView * freshView = [change objectForKey:@"new"];
        if(![freshView isKindOfClass:[NSNull class]] && self.keyBoardState != JPKeyBoardStateTextView) {
            // 切换成了非textView的模式
            self.textView.editable = YES;
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.3 animations:^{
                self.superview.y =  - freshView.height;
            } completion:^(BOOL finished) {
                [self.textView reloadInputViews];
                [self.textView becomeFirstResponder];
                self.textView.editable = NO;
            }];
        }else if([freshView isKindOfClass:[NSNull class]] && self.keyBoardState == JPKeyBoardStateTextView){
            self.textView.editable = YES;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.3 animations:^{
                self.superview.y = - [UIView jpDefaultKeyboardHeight];
            } completion:^(BOOL finished) {
                [self.textView reloadInputViews];
                [self.textView becomeFirstResponder];
            }];
        }
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"audioPowerStr" context:nil];
}

@end
