//
//  JPEmojiManager.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPEmojiMatchingResult.h"
@class  JPEmojiGroupModel;
@class JPEmojiModel;

NS_ASSUME_NONNULL_BEGIN

// 此类用于管理所有的表情包，从plist中取出表情包，同时从给出表情包的总数

@interface JPEmojiManager : NSObject

/**
 *  单例
 */
+ (instancetype)sharedEmojiManager;
/**
 *  @return 获取所有的表情组
 */
- (NSArray <JPEmojiGroupModel *> *)getEmogiGroupArr;

/**
 *  根据位置获取相应的模型数组
 *  @param group : 选择了哪一组表情
 *  @param page : 页码
 *  @return 根据前面两个参数从所有数据中根据对应的位置和大小取出表情模型(<= 20个)
 */
- (NSArray <JPEmojiModel *> *)getEmojiArrGroup:(NSInteger)group page:(NSInteger)page;

@end

NS_ASSUME_NONNULL_END
