# JPChatBottomBar


> 今天，我终于更更更更博了。
> 接着上一篇[聊天界面从0到1的实现 (一)](https://zhongyupei.github.io/2019/07/30/%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2%E4%BB%8E0%E5%88%B01%E7%9A%84%E5%AE%9E%E7%8E%B0-%E4%B8%80/#more)，
> 首先我们聊一聊 聊天页面的底部横条。

<!--more-->

## 写在前面

`JPChatBottomBar ` 与现在主流的聊天页面的底部横条页面相似。
类似于微信中的：
{% asset_img wechatBottomBar.jpg 底部横条 %}

之所以先从这个横条来折腾，个人想法：从功能上来说，这个模块可以从Im中独立出来，但又可以屏蔽掉因通信部分第三方服务选择的不同而带来的差异，服务于聊天的整个框架。以后如果框架发生变化，这一模块受到的影响也会是最小的。

`JPChatBottomBar`虽然并不整个框架的核心，但却也提供着基础的服务功能——编辑消息。
自己在模仿实现一个横条的过程中，也遇到了一些麻烦。

碍于篇幅，文章中主要用于记叙一些比较复杂的实现抑或是一些细节的问题，简单的逻辑判断实现就不出现在这里了。

demo的地址放在这里：[JPChatBottomBar--github地址](https://github.com/ZhongYupei/JPChatBottomBar)

## 功能分析 
结合前面的图：可以初步总结出 `JPChatBottomBar` 应该实现的功能，如下：

-  1.键盘的切换；
-  2.用户生成语音消息；
-  3.用户对文本消息的操作（编辑、删除、发送）；
-  4.用户文本消息中嵌入表情包；
-  5.用户点击了‘大’表情包(类似于一些gif图片)；
-  6.用户点击更多按钮，进行选择其他功能实现（类似微信：图库，拍摄，发送地址等等）。

这里，我们通过 一个代理 `JPChatBottomBarDelegate` 来将用户的操作（文本消息、语音消息等等）向外传递，即向聊天框架中的其他模块提供服务。

先来对我所使用到的类来进行说明:

- 1.`JPChatBottomBar ` :  整个横条
- 2.`preview`文件中的类用于实现表情包的预览效果
- 3.`imageResource`文件夹中存放了此demo中所用到的图片资源
- 4.`JPEmojiManager`：这个类用于读取所有的表情包资源
- 5.`JPPlayerHelper`:这个类用于实现录音和播音的效果
- 6.`JPAttributedStringHelper`:实现表情包子符和表情包图片的互转
- 7.关于`model`，`JPEmojiModel`用于绑定单独一个表情包，`JPEmojiGroupModel`用于绑定一整组的表情包。
- 8.`category`中存放了一些常用的工具类

下面，让我就上面所罗列的应该实现的功能，来讲讲各功能我是如何实现或者是在实现的过程中我所遇到的问题。

## 键盘切换
先看一下我所实现的效果。
{% asset_img jianpantanchu.gif  键盘弹出,上面的视图向上滑动%}

可以看到，在键盘弹出的过程中，`controller.view`要向上滑动，避免弹出的键盘遮挡住了用户的聊天页面。这也是非常基础的功能。

而关于键盘的实现我并没有通过以往常用的监听键盘弹出通知后调用方法来进行视图的调整。这里的实现，我采用的是kvo的方式，我监听`textView.inputView`的切换。

之所以不采用`keyboardWillShow:`的方法而是采用KVO的形式，主要原因如下：

在切换键盘的时候，例如从表情包键盘切换到系统键盘的过程中，系统键盘的高度是大于表情包键盘的，这时候系统键盘并不会从底部直接弹出来，而是还没有等到我们的`chatBottomBar`滑上去之前就将其覆盖掉，效果可以参考如下:
{% asset_img jianpanfugai.gif 表情键盘转换成系统键盘时候有一小部分覆盖 %}

而在观察了微信键盘切换的实现效果，是没有这种覆盖效果，有点忍受不了这种覆盖，于是我就采用了kvo的形式来实现，获取`textView.inputView`新旧值的变化，来获取新老View之间高度的差值，从而调整整个视图。实现代码如下

```
// JPChatBottomBar.m
// 监听textView.inputView属性新旧值的变化

[_textView addObserver:self forKeyPath:@"inputView" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
- (void)emojiViewPop:(UIButton *)button {
	///切换成表情包键盘
    if(_keyBoardState == JPKeyBoardStateEmoji)      return;
    _keyBoardState = JPKeyBoardStateEmoji;
    if(_isAudioState) {
        [self emojiAndMoreStateToTextViewState];
    }
    self.textView.inputView = self.emojiIV;	/// 切换键盘
    self.textView.editable = NO;
}
/// 回调方法(KVO)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if([keyPath isEqualToString:@"inputView"] && object == self.textView ){
        UIView * freshView = [change objectForKey:@"new"];
        if(![freshView isKindOfClass:[NSNull class]] && self.keyBoardState != JPKeyBoardStateTextView) {
            // 切换成了非textView的模式
            self.textView.editable = YES;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.3 animations:^{
                self.superview.y =  - freshView.height;
            } completion:^(BOOL finished) {
                [self.textView reloadInputViews];
                [self.textView becomeFirstResponder];
                self.textView.editable = NO;
            }];
        }else if([freshView isKindOfClass:[NSNull class]] && self.keyBoardState == JPKeyBoardStateTextView){
            self.textView.editable = YES;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.3 animations:^{
                self.superview.y = - [UIView jpDefaultKeyboardHeight];
            } completion:^(BOOL finished) {
                [self.textView reloadInputViews];
                [self.textView becomeFirstResponder];
            }];
        }
    }
```
从上面可以看到，在等到`chatBottomBar`到达了该到的位置之后，再调用`-textView reloadInputView`来唤醒键盘。如此就可以达到键盘从下弹出并且不会有小部分覆盖的效果。
**其次有个需要注意的地方**，在切换键盘的时候，需要将`textView.editable`设置为no，否则达不到切换的效果。

关于键盘的切换剩下的就是 根据用户的点击切换键盘的状态（变化相应的视图）。
这一部分就先到此☺️👌🏾。

## 语音消息
在参考了别人的Demo([iOS仿微信录音控件Demo](https://www.jianshu.com/p/37f62d568b71))之后，我也实现了一个。

先给出自己所使用的类的介绍：
- 1.`JPPlayerHelper`  : 实现录音和播音的功能。
- 2.`JPAudioView`: 展示录音的状态

让我概括一下 实现的大概步骤。
首先两个类之间并不是相互依赖的，两者在`JPChatBottomBar`中产生耦合。

### 上滑取消、下滑继续录音的效果
我在JPAudioView中利用了下面着三个方法来让audioView对用户手势变化进行判断(开始点击、向上向下滑动、手指离开)，并作出相应的处理，代码如下：

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event ;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
```
在上面这三个方面中解决自身的UI问题，再通过block从外部来实现录音以及根据语音强度更新UI的效果：

```
/// AudioView block块的实现(JPChatBottomBar.m)
- (JPAudioView *)audioView {
    if(!_audioView) {
        JPAudioView * tmpView = [[JPAudioView alloc] initWithFrame:CGRectMake(self.textView.x, self.textView.y, self.textView.width,  _btnWH )];
        [self addSubview:tmpView];
        _audioView = tmpView;
        // 实现audioView的方法
        __weak typeof (self) wSelf = self;
        _audioView.pressBegin = ^{
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:@"zhengzaiyuyin_1"] text:@"松开手指，上滑取消"];
            // 开始录音
            [wSelf.recoder jp_recorderStart];
        };
        _audioView.pressingUp = ^{
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:@"songkai"] text:@"松开手指，取消发送"];
        };
        _audioView.pressingDown = ^{
            NSString * imgStr = [NSString stringWithFormat:@"zhengzaiyuyin_%d",imageIndex];
            [wSelf.audioView setAudioingImage:[UIImage imageNamed:imgStr] text:@"松开发送，上滑取消"];
        };
        _audioView.pressEnd = ^{
            [wSelf.audioView setAudioViewHidden];
            [wSelf.recoder jp_recorderStop];
            NSString * filePath = [wSelf.recoder getfilePath];
            NSData * audioData = [NSData dataWithContentsOfFile:filePath];
            /// 将语音消息data通过代理向外传递
            if(wSelf.agent && [wSelf.agent respondsToSelector:@selector(msgEditAgentAudio:)]){
                [wSelf.agent msgEditAgentAudio:audioData];
            }
            if(wSelf.msgEditAgentAudioBlock){
                wSelf.msgEditAgentAudioBlock(audioData);
            }
        };
    }
    return _audioView;
}
```
其次就是这一块比较关键的点：
***根据语音的强度来刷新audioView的UI***

参见效果如下：
{% asset_img yuyinshuaxin.gif 分贝强度UI的刷新%}

我们首先获取语音强度平均值的方法主要通过：

```
/// 更新测量值
- (void)updateMeters; /* call to refresh meter values */
/// 获取峰值
- (float)peakPowerForChannel:(NSUInteger)channelNumber; 
/// 获取平均值
- (float)averagePowerForChannel:(NSUInteger)channelNumber; 
```
***在获取语音强度的时候，需要先`updateMeters`更新一下测量值。***
然后我们可以通过测量值 、 峰峰值之后，根据一定的算法来计算出此时声音的相对大小强度。这里，算法很垃圾的我简单的设计了一个:

```
// JPPlayerHelper.m
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
```
> 关于这一块的算法，如果各位读者有更好的方法，欢迎提出，我也是个渴望知识的小白。

通过上面的方法可以获取相应的声音的分贝强度，我们外部可以做一些处理：例如我做了，当新测量值比旧的测量值大一定值的时候，就做提高分贝的UI刷新操作，低的时候就做降低分贝UI的操作，具体可以看下面的代码：

```
// JPChatbottomBar.m
- (void) jpHelperRecorderStuffWhenRecordWithAudioPower:(CGFloat)power{
    NSLog(@"%f",power);
    NSString * newPowerStr =[NSString stringWithFormat:@"%f",[self.helper audioPower]];
    if([newPowerStr floatValue] > [self.audioPowerStr floatValue]) {
        if(imageIndex == 6){
            return;
        }
        imageIndex ++;
    }else {
        if(imageIndex == 1){
            return;
        }
        imageIndex --;
    }
    if(self.audioView.state == JPPressingStateUp) {
        self.audioView.pressingDown();
    }
    self.audioPowerStr =  newPowerStr;;
}
```

其次，我在`JPPlayerHepler`加了一个计时器来触发反复调用上面的代理方法(` - (void) jpHelperRecorderStuffWhenRecordWithAudioPower:(CGFloat)power `) ，让其可以进行UI的刷新，因为如果不加计时器，我们是没有事件去触发`audioView `UI刷新的操作，计时器相关方法如下:

```
// JPPlayerHelper.m
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(doOutsideStuff) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)doOutsideStuff {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(jpHelperRecorderStuffWhenRecordWithAudioPower:)]){
        [self.delegate jpHelperRecorderStuffWhenRecordWithAudioPower:[self audioPower]];
    }
}
```
完成录音之后，最终我们的语音数据通过`JPChatBottomBarDelegate`的代理方法向外提供。

关于获取语音强度那一块的算法并不是最优，我觉得我的算法也是比较笨拙存在缺点（对用户语音强度的变化不敏感）。如果路过的读者有什么不错的建议，欢迎提出补充，我也会采纳，谢谢🙏🙏🙏。

## '更多' 键盘 上面的Item
`JPChatBottomBar`里面的‘更多’键盘与微信的类似。
{% asset_img gengduojianpan.jpg ‘更多’键盘%}
开发者在使用的时候如果想要键入不同的功能实现，只要在`/ImageResource/JPMoreBundle.bundle` 的`JPMorePackageList.plist`文件中添加相应的item

{% asset_img gengduojianpanplistyemian.jpg JPMorePackageList.plist展示%}

> 内部也已经做好了适配的效果，不过当item数量超过8个时候，没有完成像微信的那种分页效果，后期我会继续完善。

当用户点击了上面的某个item之后，我们就将事件通过`JPChatBottomBarDelegate`向外面传递，开发者可以再最外层做处理，根据点击哪个item响应相应的方法功能，类似如下代码：

```
// ViewController.m
NSString * kJPDictKeyImageStrKey = @"imageStr";
- (void)msgEditAgentClickMoreIVItem:(NSDictionary *)dict {
    NSString * judgeStr = dict[kJPDictKeyImageStrKey];
    if([judgeStr isEqualToString:@"photo"]){
        NSLog(@"点击了图册");
    }else if([judgeStr isEqualToString:@"camera"]){
        NSLog(@"点击了摄像头");
    }else if([judgeStr isEqualToString:@"file"]) {
        NSLog(@"点击了文件");
    }else if([judgeStr isEqualToString:@"location"]) {
        NSLog(@"点击了位置");
    }
}
```

一开始没有想着将用户点击哪个item暴露在外面，但后来想了开发者面临的业务多种多样，item的排布也不一样，为了更好的扩展，简化`JPChatBottomBar`的结构，就将这部分也通过代理写出来。

## 文本消息的编辑（发送、删除、嵌入表情包文本）
> 
> 



## 写在最后
## 参考
































