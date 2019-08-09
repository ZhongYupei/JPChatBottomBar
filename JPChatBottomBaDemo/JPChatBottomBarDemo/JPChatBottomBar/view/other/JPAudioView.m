//
//  JPAudioView.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPAudioView.h"
#import "UIView+JPExtension.h"
#define JPKeyWindow [UIApplication sharedApplication].keyWindow
@interface JPAudioView ()

@property (strong, nonatomic) UIButton * button;
@property (strong, nonatomic) UILabel * label;

@property (assign, nonatomic) BOOL isPressing;

@property (strong, nonatomic) UIView * voiceView;
@property (strong, nonatomic) UIImageView * voiceImageView;
@property (strong, nonatomic) UILabel * voiceLabel;
@end

@implementation JPAudioView

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = RGB(255, 255, 255);
        [self setUpSubViews];
        self.layer.cornerRadius = 7;
        self.isPressing = NO;
    }
    return self;
}
- (void)setAudioingImage:(UIImage *)image text:(NSString *)text {
    self.voiceView.hidden = NO;
    self.voiceImageView.image = image;
    self.voiceLabel.text = text;
}
- (void)setAudioViewHidden {
    self.voiceView.hidden = YES;
}
#pragma mark selfMethod
- (void)setUpSubViews {
    UILabel * label = [[UILabel alloc] init];
    _label = label;
    label.text = @"按住 说话";
    label.textColor = RGB(51, 51, 51);
    label.font = [UIFont fontWithName:@"PingFang-Bold" size:20];
    [label sizeToFit];
    label.centerX = self.width /2;
    label.centerY = self.height /2;
    [self addSubview:label];
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.button.isSelected){
        return YES;
    }else {
        return [super pointInside:point withEvent:event];
    }
}
#pragma mark touchAction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.pressBegin) {
        self.pressBegin();
        self.state = JPPressingStateDown;
    }
    self.isPressing = YES;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.isPressing){
        UITouch * anyTouch = [touches anyObject];
        CGPoint point = [anyTouch locationInView:self];
        if(point.y < -50){
            if(self.pressingUp){
                self.pressingUp();
                self.state = JPPressingStateUp;
            }
        }else {
            if(self.pressingDown){
                self.pressingDown();
                self.state = JPPressingStateDown;
            }
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.isPressing){
        if(self.pressEnd) {
            self.pressEnd();
        }
    }
    self.isPressing = NO;
}


#pragma mark getter
- (UIView *) voiceView {
    if(!_voiceView) {
        UIView *voiceImageSuperView = [[UIView alloc] init];
        voiceImageSuperView.backgroundColor = RGBA(0, 0, 0, 0.6);
        [JPKeyWindow addSubview:voiceImageSuperView];
        _voiceView = voiceImageSuperView;
        _voiceView.width = 140;
        _voiceView.height = 140;
        _voiceView.centerX = SCREEN_WIDTH/2;
        _voiceView.centerY = SCREEN_HEIGHT/2;
        _voiceView.layer.cornerRadius = 10;
        
    }
    return _voiceView;
}
- (UILabel *)voiceLabel {
    if(!_voiceLabel) {
        UILabel *voiceIocnTitleLable = [[UILabel alloc] init];
        _voiceLabel = voiceIocnTitleLable;
        voiceIocnTitleLable.textColor = [UIColor whiteColor];
        voiceIocnTitleLable.font = [UIFont systemFontOfSize:12];
        voiceIocnTitleLable.text = @"松开发送，上滑取消";
        [_voiceLabel sizeToFit];
        [self.voiceView addSubview:_voiceLabel];
        _voiceLabel.centerX = self.voiceView.width /2;
        _voiceLabel.centerY = self.voiceView.height -_voiceLabel.height-5;
    }
    return _voiceLabel;
}
- (UIImageView *)voiceImageView {
    if(!_voiceImageView){
        UIImageView *voiceIconImage = [[UIImageView alloc] init];
        _voiceImageView = voiceIconImage;
        
        [self.voiceView addSubview:_voiceImageView];
        _voiceImageView.width = 70;
        _voiceImageView.height = 70;
        _voiceImageView.centerX = self.voiceView.width /2;
        _voiceImageView.y = 25;
        _voiceImageView.image = [UIImage imageNamed:@"zhengzaiyuyin_1"];
        
    }
    return _voiceImageView;
}

- (void)dellow{
    self.voiceLabel = nil;
    self.voiceImageView = nil;
    [self.voiceView removeFromSuperview];
}
@end
