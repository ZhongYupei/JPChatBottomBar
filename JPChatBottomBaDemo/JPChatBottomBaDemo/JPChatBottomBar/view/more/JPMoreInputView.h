//
//  JPMoreInputView.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/********item信息字典的键值*********/
/// item的图片字符串 键
extern NSString * kJPMoreItemImageStrKey;
/// item图片 键
extern NSString * kJPMoreItemImageKey;
/// item名字 键
extern NSString * kJPMoreItemNameKey;
/********************************/

@protocol JPMoreInputViewDelegate <NSObject> 

@optional

/**
 *  点击了moreInputView上面的某一个item
 *  @param  dict : 关于这个item的信息(键值写在上面)
 */
- (void)clickItemOnMoreIVWithInfo:(NSDictionary *)dict;

@end
//自定义更多键盘
@interface JPMoreInputView : UIView

@property (assign, nonatomic) id <JPMoreInputViewDelegate> delegate;

/// 通过这个方法来初始化
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
