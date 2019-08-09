//
//  JPPlayerHelper.h
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef void (^TtransactionWhenRecord)(void);

#define JPRecordFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"jpRecordFile.wav"]


@protocol JPPlayerHelperDelegate <NSObject>

@optional
#pragma mark 录音
/**
 *  开始录音
 */
- (void)jpHelperRecorderBeginRecording;
/**
 *  录音中执行的事情，power获取语音的强度，可以在这个方法来执行UI刷新追踪语音的强度
 *  @param power    :   语音强度
 */
- (void)jpHelperRecorderStuffWhenRecordWithAudioPower:(CGFloat)power;
/**
 *  暂停录音
 */
- (void)jpHelperRecorderPauseRecord;
/**
 *  恢复录音
 */
- (void)jpHelperRecorderResumeRecord;
/**
 *  结束录音
 */
- (void)jpHelperRecorderFinishRecording;

#pragma mark 播音
/**
 *  开始播放
 */
- (void)jpHelperPlayerStartPlay;
/**
 *  停止播放
 */
- (void)jpHelperPlayerPausePlay;
/**
 *  正在播放
 */
- (void)jpHelperPlayerWilePlaying;
/**
 *  继续播放
 */
- (void)jpHelperPlayerResumePlay;

/**
 *  用户结束播放
 */
- (void)jpHelperPlayerFinishPlay;

/**
 *  播放自动结束
 */
- (void)jpHelperPlayerAutoFinishPlay;

@end


NS_ASSUME_NONNULL_BEGIN

@interface JPPlayerHelper : NSObject
@property (assign, nonatomic) id <JPPlayerHelperDelegate> delegate;

/**
 *  初始化
 *  @param filePath : 录音文件的地址（为空的话则采用`JPRecordFilePath`）
 */
- (instancetype)initWithRecorderPath:(nullable NSString *)filePath ;
#pragma mark Recorder
/**
 *  开始录音
 */
- (void)jp_recorderStart;

/**
 *  暂停录音（暂停后可以重新开始录音）
 */
- (void)jp_recorderPause ;

/**
 *  重新启动继续录音
 */
- (void)jp_recorderResume;

/**
 *  停止录音（不能启动继续录音）
 */
- (void)jp_recorderStop;

/**
 *  @return     录音时候的语音强度，返回值在0~1之间
 */
- (CGFloat)audioPower;

/**
 *  @return     录音音频的文件地址
 */
- (NSString *)getfilePath;
#pragma mark Player
/**
 *  根据url播放 音频
 *  @param url :    音频文件url
 */
- (void)jp_playerPalyWithUrl:(NSURL *)url;

/**
 *  根据音频文件二进制序列 播放 音频
 *  @param data :    音频文件data
 */
- (void)jp_playerPalyWithData:(NSData *)data;


/**
 *  停止播放 音频（可以重新启动继续播放）
 */
- (void)jp_playerPausePlay;

/**
 *  继续播放音频
 */
- (void)jp_playerResumePlay;

/**
 *  取消播放音频
 */
- (void)jp_playerFinishPlay;

@end

NS_ASSUME_NONNULL_END
