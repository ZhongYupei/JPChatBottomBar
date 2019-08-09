//
//  JPInputPageView.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JPEmojiModel;

@protocol JPInputPageViewDelegate <NSObject>

@optional

/**
 *  点击请求按钮
 */
- (void)clickDeleteBtn;

/**
 *  点击小表情
 *  @param  model ： 单个小表情的模型
 */
- (void)clickSmallEmoji:(JPEmojiModel *)model;

/**
 *  点击大表情（gif或者图片等）
 *  @param model : 单个表情(gif或者图片)的模型
 */
- (void)clickLargeEmoji:(JPEmojiModel *)model;



@end

@interface JPInputPageView : UIView


@property (strong, nonatomic) id <JPInputPageViewDelegate>delegate;

/**
 *  初始化操作
 *  @param  emojiArr : 一页的表情（作为内置CollectionView的数据
 */
- (instancetype)initWithEmojiArr:(nullable NSArray *)emojiArr;

/**
 *  赋予新的数组，重新刷新数据源
 *  @param  emojiArr : 一页的表情（作为内置CollectionView的数据
 */
- (void)setEmojiArr:(NSArray <JPEmojiModel *> *)emojiArr isShowLargeImage:(BOOL)value;
@end

NS_ASSUME_NONNULL_END
