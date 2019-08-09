//
//  JPEmojiGroupModel.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/29.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPEmojiGroupModel.h"
#import "UIView+JPExtension.h"
@interface JPEmojiGroupModel ()
@property (strong, nonatomic) NSBundle * emojiBundle;       
@end
@implementation JPEmojiGroupModel
- (instancetype)initWithDataDict:(NSDictionary *)dict withIndex:(NSInteger)index{
    self = [super init];
    if(self){
        _cover_picStr = dict[@"cover_pic"];
        _folderName = dict[@"folderName"];
        _isLargeEmoji =   [dict[@"isLargeEmoji"] integerValue] == 1? YES : NO;
        _title = dict[@"title"];
        _indexAtTotalArr = index;
        NSArray * dictArr = dict[@"emojis"];
        NSMutableArray * tmpArr = [NSMutableArray array];
        if(dict!=nil){
            NSString * rootPath = [self.emojiBundle pathForResource:_folderName ofType:nil];
            for (NSInteger i=0;i<dictArr.count;i++) {
                NSDictionary * dict = [dictArr objectAtIndex:i];
                JPEmojiModel * model = [[JPEmojiModel alloc] initWithDict:dict];
                model.indexAtGroup = i;
                model.groupIndex = _indexAtTotalArr;
                [tmpArr addObject:model];
                // 将所有图片一次性加载到所有的内存中，避免反复读写文件
                NSString * fullPath = [rootPath stringByAppendingPathComponent:model.imageStr];
                model.imageFullPath = fullPath;
                
                model.emojiImage = [UIImage imageWithContentsOfFile:fullPath];
            }
            if(_isLargeEmoji) {
                _emojiArr = [NSMutableArray arrayWithArray:tmpArr];
                NSInteger number = IS_IPHONE_X ? 10:8;
                int total = (int)_emojiArr.count / number;
                if(total * number < _emojiArr.count){
                    total ++;
                }
                self.totalPages = total;
            }else {
                _emojiArr = [NSMutableArray arrayWithArray:tmpArr];
                int total = (int)_emojiArr.count / 20;
                if(total * 20 < _emojiArr.count){
                    total ++;
                }
                self.totalPages = total;
            }
            
        }
    }
    return self;
}
- (NSBundle *)emojiBundle {
    if(!_emojiBundle) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"JPEmojiBundle" ofType:@"bundle"];
        _emojiBundle = [NSBundle bundleWithPath:path];
    }
    return _emojiBundle;
}
@end
