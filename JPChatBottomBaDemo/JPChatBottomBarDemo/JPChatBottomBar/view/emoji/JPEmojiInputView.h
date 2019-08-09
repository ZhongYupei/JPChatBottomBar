//
//  JPEmojoInputView.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JPEmojiInputView,JPEmojiModel;
@protocol JPEmojiInputViewDelegate <NSObject>
@optional

/**
 *  点击了表情包页面的发送按钮
 */
- (void)clickSendBtnInputView:(JPEmojiInputView *)inputView ;
/**
 *  点击了表情包键盘的小表情包
 *  @param model : 小表情包模型
 */
- (void)inputView:(JPEmojiInputView *)inputView clickSmallEmoji:(JPEmojiModel *)model;
/**
 *  点击了表情包键盘的大表情包
 *  @param model : 大表情包模型
 */
- (void)inputView:(JPEmojiInputView *)inputView clickLargeEmoji:(JPEmojiModel *)model;
/**
 *  点击了删除按钮
 */
- (void)clickDeleteBtnInputView:(JPEmojiInputView *)inputView;

@end
// 自定义表情包键盘
@interface JPEmojiInputView : UIView
@property (assign, nonatomic) id <JPEmojiInputViewDelegate> delegate;


- (instancetype)initWithTextView:(UITextView *)textView;


- (void)setEmojiSendBtnEnabledOrNot:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
