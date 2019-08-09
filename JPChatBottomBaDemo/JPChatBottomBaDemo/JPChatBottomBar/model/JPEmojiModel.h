//
//  JPEmojiModel.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 单个表情包
@interface JPEmojiModel : NSObject

/// 表情包的描述文字，可以通过正则匹配这个来获取相应的表情包图片
@property (strong, nonatomic) NSString * emojiDesc;
/// 表情包的图片名字
@property (strong, nonatomic) NSString * imageStr;
/// 表情包的路径资源
@property (strong, nonatomic) NSString * imageFullPath;
/// 先一次性将图片都加载到内存当中，避免对文件反复的读写操作
@property (strong, nonatomic) UIImage * emojiImage;
/// 模型所在数组在整个资源图片中的位置
@property (assign, nonatomic) NSInteger groupIndex;
/// 该模型在所在数组的位置
@property (assign, nonatomic) NSInteger indexAtGroup;


/**
 *  初始化模型，将字典转化为model
 *  @param dict : 字典
 */
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
