//
//  JPMoreCVCell.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPMoreCVCell.h"
#define RGBA(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface  JPMoreCVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end



@implementation JPMoreCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = RGBA(246, 246, 246, 1);
    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.bottomView.layer.cornerRadius = 13;
}

- (void)setInfoWithDict:(NSDictionary *)dict {
    
    self.cellLabel.text = dict[kJPMoreItemNameKey];
    self.cellImageView.image = dict[kJPMoreItemImageKey];
    
}
@end
