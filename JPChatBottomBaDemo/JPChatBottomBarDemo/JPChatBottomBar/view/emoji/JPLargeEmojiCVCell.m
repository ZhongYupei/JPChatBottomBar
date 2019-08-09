//
//  JPLargeEmojiCVCell.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/30.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPLargeEmojiCVCell.h"
#import "JPEmojiModel.h"
@interface JPLargeEmojiCVCell ()
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property (weak, nonatomic) IBOutlet UILabel *imageTitle;
@end
@implementation JPLargeEmojiCVCell
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(nullable JPEmojiModel *)model {
    _model = model;
    if(model == nil) {
        self.largeImageView.image = nil;
        self.imageTitle.text = @"";
    }else {
        self.largeImageView.image = model.emojiImage;
        NSString * titleStr = [[model.emojiDesc substringFromIndex:1] substringToIndex:model.emojiDesc.length -2];
        self.imageTitle.text = titleStr;
    }
}


@end
