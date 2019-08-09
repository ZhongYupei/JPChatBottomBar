//
//  JPEmojiPreview.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/8.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPEmojiModel.h"

NS_ASSUME_NONNULL_BEGIN


/// 这个类用来 展示表情包按钮
@interface JPEmojiPreview : UIImageView
@property (strong, nonatomic) JPEmojiModel * model;
/// 初始化方法
- (instancetype)init ;
@end

NS_ASSUME_NONNULL_END
