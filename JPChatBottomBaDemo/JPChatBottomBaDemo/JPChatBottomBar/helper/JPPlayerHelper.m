//
//  JPPlayerHelper.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "JPPlayerHelper.h"

@interface JPPlayerHelper ()<AVAudioPlayerDelegate>

@property (strong, nonatomic) NSString * filePath;
@property (strong, nonatomic) AVAudioRecorder * recorder;
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (strong, nonatomic) NSTimer *  sourceTime;


@end

@implementation JPPlayerHelper
#pragma mark getter
- (AVAudioRecorder *)recorder {
    if(!_recorder) {
        //设置参数
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                       [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                       // 音频格式
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                       //采样位数  8、16、24、32 默认为16
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                       // 音频通道数 1 或 2
                                       [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                       //录音质量
                                       [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                       nil];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.filePath] settings:recordSetting error:nil];
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}


-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(doOutsideStuff) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)doOutsideStuff {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderStuffWhenRecordWithAudioPower:)]){
        [self.delegate jpHelperRecorderStuffWhenRecordWithAudioPower:[self audioPower]];
    }
}

#pragma mark publicMethod
- (instancetype)initWithRecorderPath:(nullable NSString *)filePath {
    self = [super init];
    if(self){
        if(filePath != nil) self.filePath = filePath;
        else self.filePath = JPRecordFilePath;
        
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    return self;
}
- (CGFloat)audioPower {
    [self.recorder updateMeters];           // 更新测量值
    float power = [self.recorder averagePowerForChannel:0];     // 平均值 取得第一个通道的音频，注意音频的强度为[-160,0],0最大
//    float powerMax = [self.recorder peakPowerForChannel:0];
//    CGFloat progress = (1.0/160.0) * (power + 160);
    
    power = power + 160 - 50;
    int dB = 0;
    if (power < 0.f) {
        dB = 0;
    } else if (power < 40.f) {
        dB = (int)(power * 0.875);
    } else if (power < 100.f) {
        dB = (int)(power - 15);
    } else if (power < 110.f) {
        dB = (int)(power * 2.5 - 165);
    } else {
        dB = 110;
    }
    return dB;
}
#pragma mark 录音
// 开始录音
- (void)jp_recorderStart {
    if(![self.recorder isRecording]){
        [self.recorder record];
        self.timer.fireDate = [NSDate distantPast];     // 启动定时器
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderBeginRecording)]){
            [self.delegate jpHelperRecorderBeginRecording];
        }
    }
}
// 暂停录音（暂停后还可以重新继续录音）
- (void)jp_recorderPause {
    if([self.recorder isRecording]){
        [self.recorder pause];
        self.timer.fireDate = [NSDate distantFuture];       // 停止计时器
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderPauseRecord)]){
            [self.delegate jpHelperRecorderPauseRecord];
        }
    }
}
// 重新启动，继续录音
- (void)jp_recorderResume {
    if(![self.recorder isRecording]){
        [self.recorder record];
        self.timer.fireDate = [NSDate distantPast];     // 启动定时器
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderResumeRecord)]){
            [self.delegate jpHelperRecorderResumeRecord];
        }
    }
}
- (void)jp_recorderStop {
    [self.recorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderFinishRecording)]){
        [self.delegate jpHelperRecorderFinishRecording];
    }
}

- (NSString *)getfilePath{
    return self.filePath;
}
#pragma mark  播音
- (void)jp_playerPalyWithUrl:(NSURL *)url {
    NSError *error=nil;
    _audioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    if(error){
        NSLog(@"%@",error.localizedDescription);
    }else {
        NSTimer * sourceTime = [NSTimer timerWithTimeInterval:0.05f repeats:NO block:^(NSTimer * _Nonnull timer) {
            NSLog(@"timer");
        }];
        _sourceTime = sourceTime;
        sourceTime.fireDate = [NSDate distantPast];
        [[NSRunLoop mainRunLoop] addTimer:sourceTime forMode:NSDefaultRunLoopMode];
        
        [_audioPlayer play];
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperPlayerStartPlay)]){
            [self.delegate jpHelperPlayerStartPlay];
        }
    }
    
}
- (void)jp_playerPalyWithData:(NSData *)data {
    NSError *error=nil;
    _audioPlayer= [[AVAudioPlayer alloc] initWithData:data error:&error];
    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    if(error){
        NSLog(@"%@",error.localizedDescription);
    }else {
        NSTimer * sourceTime = [NSTimer timerWithTimeInterval:0.05f repeats:NO block:^(NSTimer * _Nonnull timer) {
            NSLog(@"timer");
        }];
        _sourceTime = sourceTime;
        sourceTime.fireDate = [NSDate distantPast];
        [[NSRunLoop mainRunLoop] addTimer:sourceTime forMode:NSDefaultRunLoopMode];
        
        [_audioPlayer play];
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperPlayerStartPlay)]){
            [self.delegate jpHelperPlayerStartPlay];
        }
        
    }
}
- (void)jp_playerPausePlay {
    if(self.audioPlayer && [self.audioPlayer isPlaying]){
        [self.audioPlayer pause];
        
        if(_sourceTime) {
            
            _sourceTime.fireDate = [NSDate distantFuture];
            if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperPlayerPausePlay)]){
                [self.delegate jpHelperPlayerPausePlay];
            }
            
        }
    }
}
- (void)jp_playerResumePlay {
    if(self.audioPlayer && ![self.audioPlayer isPlaying]) {
        if(_sourceTime){
            NSLog(@"%f",_sourceTime.timeInterval);
            [self.audioPlayer playAtTime:_sourceTime.timeInterval];
            _sourceTime.fireDate = [NSDate distantPast];
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperPlayerResumePlay)]){
            [self.delegate jpHelperPlayerResumePlay];
        }
    }
}

- (void)jp_playerFinishPlay {
    if(self.audioPlayer){
        [self.audioPlayer stop];
        self.sourceTime.fireDate = [NSDate distantPast];
        if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperPlayerFinishPlay)]){
            [self.delegate jpHelperPlayerFinishPlay];
        }
    }
}
@end
