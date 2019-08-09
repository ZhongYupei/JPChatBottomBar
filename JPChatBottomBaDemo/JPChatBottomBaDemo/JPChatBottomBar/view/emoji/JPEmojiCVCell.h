//
//  JPEmojiCVCell.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPEMOJICELL_ID @"JPEmojiCVCell"

@class JPEmojiModel;

NS_ASSUME_NONNULL_BEGIN



@interface JPEmojiCVCell : UICollectionViewCell

@property (strong, nonatomic) JPEmojiModel  * model;

@property (strong, nonatomic, nullable) UIImage * emojiImage;



@end

NS_ASSUME_NONNULL_END
