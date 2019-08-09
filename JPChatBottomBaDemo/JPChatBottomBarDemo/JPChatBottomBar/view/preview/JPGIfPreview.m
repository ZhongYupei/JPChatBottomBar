//
//  JPGIfPreview.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/9.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPGIfPreview.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+JPExtension.h"
#import "UIImageView+GifTool.h"


#define BaseWidth self.frame.size.width
#define BaseHeight self.frame.size.height
@interface JPGIfPreview ()
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UILabel * label;
@end

@implementation JPGIfPreview {
    CGFloat _triangleWdith;         /// 底部尖角的宽度
    CGFloat _triangleHeight;        /// 底部尖角的高度
    
    CGFloat _filletRadius;          /// 圆角半径
    
    CGFloat _squareWidht ;          /// 正方形的宽度
    CGFloat _squareHeight ;         /// 正方形的高度
    
    CGFloat _margin ;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        // 加载默认的数据
        self.backgroundColor = [UIColor clearColor];
        _filletRadius =20;
        _triangleWdith = 10;
        _triangleHeight = 10;
        _squareWidht = BaseWidth;
        _squareHeight = BaseHeight - _triangleHeight;
        _margin = 20;
        [self addSubview:self.imageView];
        [self addSubview:self.label];
    }
    return self;
}
- (void) layoutSubviews {
    [super layoutSubviews];
    /// 设置两个子view的frame
    self.imageView.frame = CGRectMake(_margin, _margin, BaseWidth - 2 * _margin, _squareHeight - 2* _margin);
    self.label.text = [[self.model.emojiDesc substringFromIndex:1] substringToIndex:self.model.emojiDesc.length -2];
    [self reloadTextLabel];
}
- (void)reloadTextLabel {
    [self.label sizeToFit];
    self.label.centerX = BaseWidth /2;
    self.label.centerY = (CGRectGetMaxY(self.imageView.frame) + _squareHeight)/2 ;
}
/// 描边
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //1.添加绘图路径
    CGContextMoveToPoint(context,0,_filletRadius);
    CGContextAddLineToPoint(context, 0, _squareHeight - _filletRadius);
    CGContextAddQuadCurveToPoint(context, 0, _squareHeight ,_filletRadius, _squareHeight);
    CGContextAddLineToPoint(context, (_squareWidht - _triangleWdith )/2,_squareHeight);
    CGContextAddLineToPoint(context,BaseWidth /2 , BaseHeight);
    CGContextAddLineToPoint(context, (_squareWidht + _triangleWdith )/2,_squareHeight);
    CGContextAddLineToPoint(context, _squareWidht - _filletRadius,_squareHeight);
    CGContextAddQuadCurveToPoint(context, _squareWidht, _squareHeight ,_squareWidht, _squareHeight - _filletRadius);
    CGContextAddLineToPoint(context, _squareWidht ,_filletRadius);
    CGContextAddQuadCurveToPoint(context, _squareWidht, 0 ,_squareWidht - _filletRadius, 0);
    CGContextAddLineToPoint(context,_filletRadius ,0);
    CGContextAddQuadCurveToPoint(context, 0, 0 ,0, _filletRadius);
    //2.设置颜色属性
    CGFloat backColor[4] = {1,1,1, 0.86};
    CGFloat layerColor[4] = {0.9,0.9,0.9,0};
    
    //3.设置描边颜色，填充颜色
    CGContextSetFillColor(context, backColor);
    CGContextSetStrokeColor(context, layerColor);
    
    //4.绘图
    CGContextDrawPath(context, kCGPathFillStroke);
}
#pragma mark getter
- (UIImageView *)imageView {
    if(_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
- (UILabel *)label {
    if(!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = RGB(51, 51, 51);
        _label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    }
    return _label;
}
#pragma mark publicMethod
- (void)setModel:(JPEmojiModel *)model {
    _model = model;
    NSLog(@"%@",model.imageFullPath);
    [self.imageView jp_setImage:[NSURL fileURLWithPath:model.imageFullPath]];
    self.label.text = [[model.emojiDesc substringFromIndex:1] substringToIndex:model.emojiDesc.length -2];
    [self reloadTextLabel];
}
@end
