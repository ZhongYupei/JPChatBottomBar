//
//  JPGIfPreview.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/9.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPEmojiModel.h"
NS_ASSUME_NONNULL_BEGIN


/// GIF预览
@interface JPGIfPreview : UIView
@property (strong, nonatomic) JPEmojiModel * model;


/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
