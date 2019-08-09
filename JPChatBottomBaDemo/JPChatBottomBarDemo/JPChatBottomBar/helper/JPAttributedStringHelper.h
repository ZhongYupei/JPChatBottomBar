//
//  JPAttributedStringHelper.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 这个类用于设置字体的样式
/**********Config*************/
@interface JPAttributedStringConfig : NSObject
@property (strong, nonatomic) UIFont * font;            // 字体样式
@property (strong, nonatomic) UIColor * color;          // 字体的颜色
@property (assign, nonatomic) CGFloat charSpace;        // 字体间距
@property (assign, nonatomic) CGFloat lineSpace;        // 行间距
/**
 *  单例
 */
+ (instancetype)sharedConfig;
/**
 *  设置字体的样式
 *  @param font : 字体的样式
 */
+ (void)setTextFont:(UIFont *)font;
/**
 *  设置字体的颜色
 *  @param color : 字体统一的颜色
 */
+ (void)setTextColor:(UIColor *)color;
/**
 *  设置字体的字间距
 *  @param space : 字体字间距
 */
+ (void)setCharSpace:(CGFloat)space;
/**
 *  设置字体的行间距
 *  @param space : 字体行间距
 */
+ (void)setLineSpace:(CGFloat)space;
/**
 *  获取AttDict字典
 */
+ (NSDictionary <NSAttributedStringKey,id> *)getAttDict;



@end



// 这个类用于设置字符串的字体，并且对文本进行 转换
/**********Helper*************/
@interface JPAttributedStringHelper : NSObject

/**
 *  初始化
 */
- (instancetype)init;
/**
 *  解析字符串，获取其中含有的表情包'[字符]'
 *  @param str : 需要解析的字符串
 */
- (NSArray *)analysisStrWithStr:(NSString *)str;


/**
 *  解析字符串，获取将表情包文本变化成表情包的图文混编字符串
 *  @param str : 需要解析的字符串
 */
- (NSAttributedString *)getTextViewArrtibuteFromStr:(NSString *)str;


@end

NS_ASSUME_NONNULL_END
