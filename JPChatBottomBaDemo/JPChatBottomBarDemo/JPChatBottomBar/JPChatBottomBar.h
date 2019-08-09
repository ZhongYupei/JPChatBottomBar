//
//  JPMsgEditAgentView.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger,JPKeyBoardState) {
    JPKeyBoardStateNone         =   1<<0,         // 无状态  default
    JPKeyBoardStateTextView     =   1<<1,           // 文本框输入状态
    JPKeyBoardStateAudio        =   1<<2,         // 语音状态
    JPKeyBoardStateEmoji        =   1<<3,         // 表情状态
    JPKeyBoardStateMore         =   1<<4,         // 更多状态
};

OBJC_EXTERN NSString * const MsgAgentViewWillChangeNoti;
OBJC_EXTERN NSString * const MsgAgentViewHeightInfoKey;

@protocol JPChatBottomBarDelegate <NSObject>

@optional
/**
 *  获取用户标记的文本消息
 *  @param text : 用户输入的文本消息
 */
- (void)msgEditAgentSendText:(NSString *)text;

/**
 *  用户点击了键盘的表情包按钮
 *  @param bigEmojiData :   大表情包的data
 */
- (void)msgEditAgentSendBigEmoji:(NSData *)bigEmojiData;

/**
 *  用户点击了‘更多’键盘的某个item
 *  @param dict ： 用户点击了‘更多’键盘的某个item的信息
 */
- (void)msgEditAgentClickMoreIVItem:(NSDictionary *)dict;

/**
 *  获取用户的语音消息
 *  @param  audioData : 用户的语音消息
 */
- (void)msgEditAgentAudio:(NSData *)audioData;

@end


@interface JPChatBottomBar : UIView

@property (assign, nonatomic) JPKeyBoardState keyBoardState;



@property (assign, nonatomic) id <JPChatBottomBarDelegate> agent;

/**
 *  初始化底部输入横条
 *  @param barHeight :  底部横条的高度(如果传入为0，则默认采用内部的高度（iPhoneX及以上机型：83；iPhone8及以下机型：55))
 *  @param btnWH    :   (横条上按钮的高度如果传入为0，则默认采用内部的高度（iPhoneX及以上机型：40；iPhone8及以下机型：35))
 *  @return 底部输入横条,直接添加至底部，获取用户消息可以通过msgEidtAgent代理，或者block快
 */
- (instancetype)initWithBarHeight:(CGFloat)barHeight btnHeight:(CGFloat)btnWH;

/**
 *  令整个输入框取消第一相应
 */
- (void)resignFirstResponder;

/**
 *  令‘更多’键盘成为第一响应
 */
- (void)moreIVBecomeFirstResponder ;

/**
 *  令‘表情包’键盘成为第一响应
 */
- (void)emojiIVBecomeFirstResponder;
@end

NS_ASSUME_NONNULL_END
