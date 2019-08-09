//
//  JPMoreCVCell.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPMoreInputView.h"
NS_ASSUME_NONNULL_BEGIN

#define JPMoreCVCEll_ID @"JPMoreCVCell"

// 更多输入框页面的cell
@interface JPMoreCVCell : UICollectionViewCell
/**
 *  设置cell的内容信息
 *  @param dict : 字典
 */
- (void)setInfoWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
