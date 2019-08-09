//
//  JPEmojiGroupModel.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPEmojiModel.h"

NS_ASSUME_NONNULL_BEGIN

// 一组表情包model
@interface JPEmojiGroupModel : NSObject
@property (strong, nonatomic) NSString * cover_picStr;          /// 表情包的封面，用于底部tabbar
@property (strong, nonatomic) NSArray <JPEmojiModel *> * emojiArr;  /// 表情包数组，每一组表情包有多少个
@property (strong, nonatomic) NSString * folderName;            /// 每一组表情包所储存的文件名
@property (strong, nonatomic) NSString * title;                  /// 该组表情包的标题
@property (assign, nonatomic) BOOL isLargeEmoji;                 /// 是否为大图？是得话一般为image或者gif
@property (assign, nonatomic) NSInteger indexAtTotalArr;        ///  该数组在整个数组的位置
@property (assign, nonatomic) NSInteger totalPages;             /// 该组表情包所包括的所有页数


/**
 *  初始化模型，将字典转化为model
 *  @param dict : 字典
 */
- (instancetype)initWithDataDict:(NSDictionary *)dict withIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
