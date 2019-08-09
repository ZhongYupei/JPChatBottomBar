//
//  JPAudioView.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,JPPressingState) {
    JPPressingStateUp          =1,          // 向上状态
    JPPressingStateDown          ,          // 向下状态
};

@interface JPAudioView : UIView

@property (copy, nonatomic) void (^pressBegin)(void);           // 开始按压
@property (copy, nonatomic) void (^pressingUp)(void);           // 向上滑动
@property (copy, nonatomic) void (^pressingDown)(void);         // 向下滑动
@property (copy, nonatomic) void (^pressEnd)(void);             // 结束按压

@property (assign, nonatomic) JPPressingState state;                       // 表示手指按压的状态

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setAudioingImage:(UIImage *)image text:(NSString *)text;
- (void)setAudioViewHidden;

@end

NS_ASSUME_NONNULL_END
