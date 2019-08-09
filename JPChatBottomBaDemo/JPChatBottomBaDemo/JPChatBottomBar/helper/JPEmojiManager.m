//
//  JPEmojiManager.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiManager.h"
#import "JPEmojiGroupModel.h"
#import "JPEmojiModel.h"
#import "UIView+JPExtension.h"
#import "JPEmojiMatchingResult.h"

#define SmallEmojiSinglePageSize 20
#define LargeEmojiSinglePageSize (IS_IPHONE_X ? 10:8)

@interface JPEmojiManager ()
@property (strong, nonatomic) NSMutableArray <JPEmojiGroupModel *> * groupArr;
@property (strong, nonatomic) NSArray<JPEmojiModel *> * smallEmojiArr;
@property (strong, nonatomic) NSMutableArray * pagesForGroup;

@property (strong, nonatomic) NSBundle * emojiBundle;
@end

@implementation JPEmojiManager

#pragma mark publicMethod
+ (instancetype)sharedEmojiManager {
    static JPEmojiManager *shareObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[JPEmojiManager alloc] init];
    });
    return shareObj;
}
- (NSArray <JPEmojiGroupModel *> *)getEmogiGroupArr;{
    return self.groupArr;
}
- (NSArray <JPEmojiModel *> *)getEmojiArrGroup:(NSInteger)group page:(NSInteger)page {
    //防止数组越界
    if(group >= self.groupArr.count) {return nil;}
    JPEmojiGroupModel * groupModel = [self.groupArr objectAtIndex:group];
    if(page >= groupModel.totalPages) {return nil;}
    if(groupModel.isLargeEmoji){
        NSInteger beginIndex = page * LargeEmojiSinglePageSize;
        NSInteger length = (groupModel.emojiArr.count - beginIndex) >LargeEmojiSinglePageSize?LargeEmojiSinglePageSize:(groupModel.emojiArr.count - beginIndex);
        return [groupModel.emojiArr subarrayWithRange:NSMakeRange(beginIndex, length)];
    }else {
        NSInteger beginIndex = page * SmallEmojiSinglePageSize;
        NSInteger length = (groupModel.emojiArr.count - beginIndex)>SmallEmojiSinglePageSize? SmallEmojiSinglePageSize:(groupModel.emojiArr.count - beginIndex);
        return [groupModel.emojiArr subarrayWithRange:NSMakeRange(beginIndex, length)];
    }
}
#pragma mark getter
- (NSMutableArray <JPEmojiGroupModel *> *) groupArr{
    if(!_groupArr){
        NSString * emojiBundlePath = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        NSBundle * emojiBundle = [NSBundle bundleWithPath:emojiBundlePath];
        NSString * emojiPathPlist = [emojiBundle pathForResource:@"JPEmojiPackageList" ofType:@"plist"];
        NSArray * dictArr = [NSArray arrayWithContentsOfFile:emojiPathPlist];
        _groupArr = [NSMutableArray array];
        for(NSInteger index =0;index<dictArr.count;index++){
            NSDictionary * subDict = [dictArr objectAtIndex:index];
            JPEmojiGroupModel * groupArr = [[JPEmojiGroupModel alloc] initWithDataDict:subDict withIndex:index];
            [_groupArr addObject:groupArr];
        }
    }
    return _groupArr;
    
}
- (NSBundle *)emojiBundle {
    if(!_emojiBundle) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        _emojiBundle = [NSBundle bundleWithPath:path];
    }
    return _emojiBundle;
}

- (NSArray <JPEmojiModel *> *)smallEmojiArr {
    if(!_smallEmojiArr ) {
        JPEmojiGroupModel * groupModel = [self.groupArr objectAtIndex:0];
        _smallEmojiArr = [groupModel emojiArr];
        
    }
    return _smallEmojiArr;
}

@end
