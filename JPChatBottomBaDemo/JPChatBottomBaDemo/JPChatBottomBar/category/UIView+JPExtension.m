//
//  UIView+JPExtension.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "UIView+JPExtension.h"

@implementation UIView (JPExtension)
#pragma setter
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}
- (CGFloat)x {
    return  self.frame.origin.x;
}
- (CGFloat)y {
    return  self.frame.origin.y;
}
- (CGFloat)height{
    return self.frame.size.height;
}
- (CGFloat)width {
    return self.frame.size.width;
}
- (CGFloat)centerX {
    return self.center.x;
}
- (CGFloat)centerY {
    return self.center.y;
}
- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
- (CGSize)size
{
    return self.frame.size;
}
- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

+ (CGFloat)jpDefaultKeyboardHeight {
    if(IS_IPHONE_X) {
         return 346;
    }
    else if (IS_IPHONE_6P){
        return 271;
    }else {
        return 258;
    }
}

+ (CGFloat)jpEmojiIVKeyboardHeight {
    if(IS_IPHONE_X) {
        return 300;
    }
    else if (IS_IPHONE_6P){
        return 240;
    }else {
        return 227;
    }
}

//+ (CGFloat)jpEmojiIVKeyboardHeight {
//
//}

@end
