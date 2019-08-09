//
//  UIView+JPExtension.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>



#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define RGB(r, g, b) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
// 机型

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X ((SCREEN_WIDTH == 375.f && SCREEN_HEIGHT == 812.f ? YES : NO) || (SCREEN_WIDTH == 414.f && SCREEN_HEIGHT == 896.f ? YES : NO))
// 机型的比例因子
#define IPHONE_X_FACTOR (812/667)
#define IPHONE_6P_FACTOR (736/667)
#define IPHONE_XS_FACTOR (896/667)
// 根据机型各系统视图的高度
#define kStatusBarAndNavigationBarHeight (IS_IPHONE_X ? 88.f : 64.f)
#define kStatusBarHeight (IS_IPHONE_X ? 44.f : 20.f)
#define kNavgationBarHeight 44.f
#define kTabBarHeight (IS_IPHONE_X ? 83.f : 49.f)

#ifdef DEBUG
#define JPLog(fmt, ...) NSLog((fmt),##__VA_ARGS__)
#else
#define YXYLog(...)
#endif




NS_ASSUME_NONNULL_BEGIN

@interface UIView (JPExtension)
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;



/**
 *  @return 底层根据机型返回键盘的高度
 */
+ (CGFloat)jpDefaultKeyboardHeight;
/**
 *  @return 底层开发者根据各个机型设置的表情包键盘高度
 */
+ (CGFloat)jpEmojiIVKeyboardHeight;

/**
 *  @return 底层开发者根据各个机型设置的更多键盘高度
 */
+ (CGFloat)jpMoreIVKeyboardHeight;



@end

NS_ASSUME_NONNULL_END
