//
//  JPEmojiMatchingResult.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiMatchingResult.h"
#import "JPAttributedStringHelper.h"

@implementation JPEmojiMatchingResult
- (instancetype)initWithOriginStr:(NSString *)str textResult:(NSTextCheckingResult *)checkResult{
    self = [super init];
    if(self) {
        self.emojiDescription = [str substringWithRange:checkResult.range];
        self.range = checkResult.range;
    }
    return self;
}
- (void)setEmojiImage:(UIImage *)emojiImage {
    _emojiImage = emojiImage;
    _textAttachment = [[NSTextAttachment alloc] init];
    _textAttachment.image = emojiImage;
    _textAttachment.bounds = CGRectMake(0,  [JPAttributedStringConfig sharedConfig].font.descender, [JPAttributedStringConfig sharedConfig].font.lineHeight,[JPAttributedStringConfig sharedConfig].font.lineHeight );
    
    
    
}
@end
