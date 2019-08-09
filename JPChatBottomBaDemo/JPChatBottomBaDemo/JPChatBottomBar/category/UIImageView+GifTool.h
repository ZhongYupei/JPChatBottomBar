//
//  UIImageView+GifTool.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/8/9.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (GifTool)

/**
 *  imageView播放gif
 *  @param imageUrl : 本地gif图片的URL
 */
-(void)jp_setImage:(NSURL *)imageUrl;
@end

NS_ASSUME_NONNULL_END
