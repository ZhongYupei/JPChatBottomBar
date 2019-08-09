//
//  JPEmojiCVCell.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/28.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiCVCell.h"
#import "JPEmojiModel.h"
#import "JPEmojiManager.h"
@interface JPEmojiCVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *emojiImageView;

@end


@implementation JPEmojiCVCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.emojiImageView.image = [UIImage imageNamed:@"gengduo_normal"];
}
- (void)setModel:(JPEmojiModel *)model {
    _model = model;
    self.emojiImageView.image = model.emojiImage;
}
- (void)setEmojiImage:(nullable UIImage *)emojiImage {
    _emojiImage = emojiImage;
    self.emojiImageView.image = emojiImage;
}


@end
