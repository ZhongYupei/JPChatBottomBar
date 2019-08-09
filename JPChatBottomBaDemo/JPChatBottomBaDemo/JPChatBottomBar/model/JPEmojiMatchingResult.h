//
//  JPEmojiMatchingResult.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 这个类用于封装正则表达式检测字符串之后所得结果的信息
@interface JPEmojiMatchingResult : NSObject

// 匹配到表情包文本的range
@property (assign, nonatomic) NSRange range;                           
// 表情包图片
@property (strong, nonatomic) UIImage * emojiImage;
// 表情包文本的描述如'[哈哈]'
@property (strong, nonatomic) NSString * emojiDescription;
// 图片的插件
@property (strong, nonatomic, readonly) NSTextAttachment * textAttachment;
/**
 *  将NSTextCheckingResult 转化成表情包查询结果的模型
 *  @param str : 表情包文本所在的字符串
 *  @param checkResult  :   正则表达式查询的结果
 */
- (instancetype)initWithOriginStr:(NSString *)str textResult:(NSTextCheckingResult *)checkResult;
@end

NS_ASSUME_NONNULL_END
