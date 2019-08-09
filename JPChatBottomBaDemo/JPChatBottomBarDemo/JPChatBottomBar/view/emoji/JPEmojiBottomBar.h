//
//  JPEmojiBottomBar.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JPEmojiGroupModel;

NS_ASSUME_NONNULL_BEGIN

@protocol JPEmojiBottomBarDelegate <NSObject>

@optional
/**
 *  点击了发送按钮
 */
- (void)emojiBottomBarSendTextMsg;
/**
 *  选择了某一组的表情
 *  @param index  :  某一组表情的索引
 */
- (void)selectEmojiGroup:(NSInteger)index;
@end

@interface JPEmojiBottomBar : UIView
@property (assign, nonatomic) id <JPEmojiBottomBarDelegate>delegate;

/**
 *  根据表情包组 的数组来初始化底部横条
 *  @param  arr : 表情包组 的数组
 */
- (instancetype)initWithGroupArr:(nullable NSArray <JPEmojiGroupModel *> *)arr;
/**
 *  根据index 来切换当前的表情包组合
 *  @param  index :  设置当前所选择的 表情包集合
 */
- (void)setUpBottomBarCurrentIndex:(NSInteger)index;

/**
 *  切换发送按钮的点击状态
 *  @param enabled : 是否可以进行点击
 */
- (void)setUpSendBtnEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
