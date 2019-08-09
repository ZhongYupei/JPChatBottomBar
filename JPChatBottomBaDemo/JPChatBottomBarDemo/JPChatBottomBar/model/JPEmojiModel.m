//
//  JPEmojiModel.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiModel.h"


@implementation JPEmojiModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if(self){
        _emojiDesc = dict[@"desc"];
        _imageStr = dict[@"image"];
        
        
        
        
        
    }
    return self;
}

@end
