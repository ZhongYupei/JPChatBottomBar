//
//  JPAttributedStringHelper.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/7.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPAttributedStringHelper.h"
#import "JPEmojiModel.h"
#import "JPEmojiMatchingResult.h"
#import "JPEmojiGroupmodel.h"
#import "JPEmojiManager.h"
/**********Config*************/
@interface JPAttributedStringConfig ()
@property (strong, nonatomic) NSMutableParagraphStyle * paraStyle;
@end
@implementation JPAttributedStringConfig
static JPAttributedStringConfig *shareObj = nil;
+ (instancetype) sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[JPAttributedStringConfig alloc] init];
        // 设置默认的数据
        shareObj.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        shareObj.color = [UIColor colorWithRed:55/255.0f green:55/255.0f blue:55/255.0f alpha:1];
        shareObj.charSpace = 1;
        shareObj.lineSpace = 5;
        
        NSMutableParagraphStyle * paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = shareObj.lineSpace;
        shareObj.paraStyle = paraStyle;
        
    });
    return shareObj;
}
#pragma mark publicMethod
+ (void)setTextFont:(UIFont *)font {
    if(shareObj == nil) {
        shareObj = [JPAttributedStringConfig sharedConfig];
    }
    shareObj.font = font;
}
+ (void)setTextColor:(UIColor *)color {
    if(shareObj == nil) {
        shareObj = [JPAttributedStringConfig sharedConfig];
    }
    shareObj.color = color;
}
+ (void)setCharSpace:(CGFloat)space {
    if(shareObj == nil) {
        shareObj = [JPAttributedStringConfig sharedConfig];
    }
    shareObj.charSpace = space;
}
+ (void)setLineSpace:(CGFloat)space {
    if(shareObj == nil) {
        shareObj = [JPAttributedStringConfig sharedConfig];
    }
    shareObj.lineSpace = space;
}

+ (NSDictionary<NSAttributedStringKey,id> *)getAttDict {
    if(shareObj == nil) {
        shareObj = [JPAttributedStringConfig sharedConfig];
    }
    return  @{
              NSFontAttributeName               :[JPAttributedStringConfig sharedConfig].font,
              NSForegroundColorAttributeName    :[JPAttributedStringConfig sharedConfig].color,
              NSKernAttributeName               :@(shareObj.charSpace),
              NSParagraphStyleAttributeName     :shareObj.paraStyle,
    };
    
}
@end

/**********Helper*************/
@interface JPAttributedStringHelper ()
@property (strong, nonatomic) NSBundle * emojiBundle;
@property (strong, nonatomic) NSArray <JPEmojiModel *> * smallEmojiArr;
@property (strong, nonatomic) JPEmojiManager * manager;
@end
@implementation JPAttributedStringHelper
#pragma mark getter

- (NSBundle *)emojiBundle {
    if(!_emojiBundle) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        _emojiBundle = [NSBundle bundleWithPath:path];
    }
    return _emojiBundle;
}
- (NSArray<JPEmojiModel *> *)smallEmojiArr {
    if(!_smallEmojiArr) {
        JPEmojiGroupModel * groupModel = [[self.manager getEmogiGroupArr] objectAtIndex:0];;
        _smallEmojiArr = groupModel.emojiArr;
    }
    return _smallEmojiArr;
}
- (JPEmojiManager *)manager {
    return [JPEmojiManager sharedEmojiManager];
}
#pragma mark publicMethod

- (instancetype)init {
    self = [super init];if(self){} return self;
}
- (NSArray<JPEmojiMatchingResult *> *)analysisStrWithStr:(NSString *)str {
    if(str.length == 0) {
        return nil;
    }
    // 使用正则表达式来检测字符串
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\]" options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if(results && results.count != 0) {
        NSMutableArray <JPEmojiMatchingResult *> * tmpArr = [NSMutableArray array];
        for (NSTextCheckingResult * result in results) {
            JPEmojiMatchingResult * matchingResult = [[JPEmojiMatchingResult alloc] initWithOriginStr:str textResult:result];
            // 从小表情包数组中检索出符合表情包文本的model
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.emojiDesc == %@",matchingResult.emojiDescription];
            NSArray * arr = [self.smallEmojiArr filteredArrayUsingPredicate:predicate];
            JPEmojiModel * model = [arr firstObject];
            matchingResult.emojiImage = model.emojiImage;
            [tmpArr addObject:matchingResult];
        }
        return tmpArr;
    }
    return nil;
}
- (NSAttributedString *)getTextViewArrtibuteFromStr:(NSString *)str {
    if(str.length == 0) {
        return nil;
    }
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]  initWithString:str
                                                                                 attributes:[JPAttributedStringConfig getAttDict]];
    
    NSMutableParagraphStyle * paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 5;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attStr.length)];
    
    NSArray<JPEmojiMatchingResult *> * emojiStrArr = [self analysisStrWithStr:str];
    if(emojiStrArr && emojiStrArr.count != 0) {
        NSInteger offset = 0;           // 表情包文本的偏移量
        for(JPEmojiMatchingResult * result in emojiStrArr ){
            if(result.emojiImage ){
                // 表情的特殊字符
                NSMutableAttributedString * emojiAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:result.textAttachment]];
                if(!emojiAttStr) {
                    continue;
                }
                NSRange actualRange = NSMakeRange(result.range.location - offset, result.range.length);
                [attStr replaceCharactersInRange:actualRange withAttributedString:emojiAttStr];
                // 一个表情占一个长度
                offset += (result.range.length-1);
            }
        }
        return attStr;
    }else {
        return [[NSAttributedString alloc] initWithString:str attributes:[JPAttributedStringConfig getAttDict]];;
    }
}

@end

