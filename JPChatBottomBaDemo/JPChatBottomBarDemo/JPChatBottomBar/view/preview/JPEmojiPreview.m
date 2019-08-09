//
//  JPEmojiPreview.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/8.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiPreview.h"
#import "UIView+JPExtension.h"

@interface JPEmojiPreview () {
    CGFloat _previewImageWH;
    CGFloat _margin;
}
@property (strong, nonatomic) UIImageView * emojiImageView;
@property (strong, nonatomic) UILabel * emojiDescLabel;
@end



@implementation JPEmojiPreview

- (instancetype)init  {
    self = [super init];
    if(self) {
        _previewImageWH = 50;
        self.image = [UIImage imageNamed:@"emoji-preview-bg"];
//        self.backgroundColor = [UIColor blueColor];
        
        
        [self addSubview:self.emojiImageView];
        [self addSubview:self.emojiDescLabel];
    }
    return self;
}
#pragma mark selfMethod
- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.model == nil){
        return;
    }
    _margin = 10;
    self.emojiImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.emojiImageView.image = self.model.emojiImage;
    self.emojiImageView.width = _previewImageWH;
    self.emojiImageView.height = self.emojiImageView.width;
    self.emojiImageView.centerX = self.width /2;;
    self.emojiImageView.y = _margin;;

    self.emojiDescLabel.text = [[self.model.emojiDesc substringFromIndex:1] substringToIndex:self.model.emojiDesc.length -2];
    [self reloadTextLabel];
}
- (void)reloadTextLabel {
    [self.emojiDescLabel sizeToFit];
    self.emojiDescLabel.centerX = self.emojiImageView.centerX;
    self.emojiDescLabel.y = CGRectGetMaxY(self.emojiImageView.frame) + _margin;
}
#pragma mark setter
- (void)setModel:(JPEmojiModel *)model {
    _model = model;
    self.emojiImageView.image = model.emojiImage;
    self.emojiDescLabel.text = [[model.emojiDesc substringFromIndex:1] substringToIndex:model.emojiDesc.length -2];
    [self reloadTextLabel];
    
}
#pragma mark getter
- (UIImageView *)emojiImageView {
    if(!_emojiImageView) {
        _emojiImageView = [[UIImageView alloc] init];
    }
    return _emojiImageView;
}
- (UILabel *)emojiDescLabel {
    if(!_emojiDescLabel) {
        _emojiDescLabel = [[UILabel alloc] init];
        _emojiDescLabel.font = [UIFont systemFontOfSize:13.0];;
        _emojiDescLabel.textColor = RGBA(51, 51,51, 1);
        _emojiDescLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _emojiDescLabel;
}

@end
