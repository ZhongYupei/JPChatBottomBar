# JPChatBottomBar


> 今天，我终于更更更更博了。
> 接着上一篇[聊天界面从0到1的实现 (一)](https://zhongyupei.github.io/2019/07/30/%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2%E4%BB%8E0%E5%88%B01%E7%9A%84%E5%AE%9E%E7%8E%B0-%E4%B8%80/#more)，
> 今天来聊一聊 聊天页面的底部横条。

原文地址 ： [聊天界面从0到1的实现 (二)](https://zhongyupei.github.io/2019/08/09/%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2%E4%BB%8E0%E5%88%B01%E7%9A%84%E5%AE%9E%E7%8E%B0-%E4%BA%8C/#more)
demo 地址： [JPChatBottomBar](https://github.com/ZhongYupei/JPChatBottomBar)

<!--more-->

## 写在前面

`JPChatBottomBar ` 与现在主流的聊天页面的底部横条页面相似。
类似于微信中的：

![微信底部横条](https://user-gold-cdn.xitu.io/2019/8/10/16c7a28046b8d96e?w=750&h=120&f=jpeg&s=5044)

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
效果可以到我的博客或者下载demo中查看。
<!--{% asset_img jianpantanchu.gif  键盘弹出,上面的视图向上滑动%}-->

可以看到，在键盘弹出的过程中，`controller.view`要向上滑动，避免弹出的键盘遮挡住了用户的聊天页面。这也是非常基础的功能。

但是这里有个**细节**的地方：

这一块一开始我是想通过写死系统键盘的高度，通过监听`textView.inputView`新旧值的变化（kvo实现参考demo里面）：
从demo中的代码可以看出，在等到`chatBottomBar`到达了该到的位置之后，再调用`-textView reloadInputView`来唤醒键盘。如此就可以达到键盘从下弹出并且不会有小部分覆盖的效果。

但是发现，系统键盘的高度不是都一样的，例如汉语拼音的九宫格键盘要比26键高，而日语九宫格键盘要比26键低，所以不是很全。

于是最后还是采用了监听键盘弹出的通知来实现 :

![jianpanbeifugai.gif](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2aa80644ae9?w=274&h=290&f=gif&s=7943217)

而微信在这一块的实现就没有这种覆盖效果，微信等到`viewController.view`来到该到的位置之后，再让键盘从下面弹出。

监听键盘弹出的通知：

```
// JPChatBottomBar.m
// 监听textView.inputView属性新旧值的变化

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeRect:) name:UIKeyboardWillChangeFrameNotification object:nil];

- (void)keyboardWillChangeRect:(NSNotification *)noti {
NSValue * aValue =  noti.userInfo[UIKeyboardFrameBeginUserInfoKey];
self.oldRect = [aValue CGRectValue];
NSValue * newValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
self.newRect = [newValue CGRectValue];
[UIView animateWithDuration:0.3 animations:^{
if(self.superview.y == 0) {
self.superview.y -= self.newRect.size.height;
}else {
self.superview.y -=(self.newRect.size.height - self.oldRect.size.height);
}
} completion:^(BOOL finished) {
}];
}
```

路过的读者如果有更好的改进方法，能在切换键盘的时候避免这种覆盖，欢迎提出，我也是正在学习iOS 的小白😂。谢谢🙏🙏🙏 

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

效果可以到博客或者下载demo查看。
<!--{% asset_img yuyinshuaxin.gif 分贝强度UI的刷新%}-->

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
![‘更多’键盘](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2b7d2f472b6?w=368&h=148&f=png&s=12917)
开发者在使用的时候如果想要键入不同的功能实现，只要在`/ImageResource/JPMoreBundle.bundle` 的`JPMorePackageList.plist`文件中添加相应的item

![JPMorePackageList.plist展示](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2bd1bad1cab?w=792&h=301&f=png&s=32112)

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

一开始没有想着将用户点击哪个item暴露在外面，但后来想了开发者面临的业务多种多样，为了更好的扩展，简化`JPChatBottomBar`的结构，就将这部分也通过代理写出来。

## 文本消息的编辑（发送、删除、嵌入表情包文本）
> 我花了比较多的时间在这一部分上面，之前没有真正的做嵌入表情包的方法，只是通过调用原生的表情来实现表情的编辑

这一部分主要思考 当用户点击表情包的时候我们要做哪些处理。
先讲我们的问题化简一下。


### 表情包分两种
观察微信，表情包主要分两大种，一种是可以嵌入文本框的表情，而另一种是当用户点击了该表情之后直接就发送给聊天对象，下面我们称这两种表情分别为SmallEmoji（前者）和LargeEmoji（后者）。

后者的实现方式可以通过每一层间代理将其暴露在外。
```
// JPChatBottomBar.h
/**
*  用户点击了键盘的表情包按钮
*  @param bigEmojiData :   大表情包的data
*/
- (void)msgEditAgentSendBigEmoji:(NSData *)bigEmojiData;
```

关于“点击SmallEmoji嵌入文本”，我放后谈谈。

### 表情包的加载
这里我通过`JPEmojiManager` 将表情包从`/ImageResource/JPEmojiBundle.bundle`中加载出来，为一个表情包在`JPEmojiPackageList.plist`中都有对应的item进行绑定，因此，如果后期我们有新的表情包，只要把图片存进去，并且在plist文件中增加新的item即可以，代码实现用户动态添加表情包的方式也是一样的。

而为了避免重复地读取文件，我将`JPEmojiManager`写成了单例。

```
// JPEmojiManager.h

/**
*  @return 获取所有的表情组
*/
- (NSArray <JPEmojiGroupModel *> *)getEmogiGroupArr;

/**
*  根据位置获取相应的模型数组
*  @param group : 选择了哪一组表情
*  @param page : 页码
*  @return 根据前面两个参数从所有数据中根据对应的位置和大小取出表情模型(<= 20个)
*/
- (NSArray <JPEmojiModel *> *)getEmojiArrGroup:(NSInteger)group page:(NSInteger)page;
```
这里可以看到两个类
- `JPEmojiModel`用于绑定单独一个表情包，
- `JPEmojiGroupModel`用于绑定一整组的表情包

`JPEmojiManager`中的这两个方法更多是服务于分页表情包的效果（下面我将要谈到）

### 表情包的分页效果
在看过github上面别人表情包demo之后，有一些并没有实现滑动切换表情包组，于是自己实现了一个，效果可以到博客或者demo查看。


分也效果的实现方式：通过三个view去复用，在`ScrollView`中去轮流展示。

```
// JPEmojiInputView.m
#pragma mark 三个view复用
@property (strong, nonatomic) JPInputPageView * leftPV;
@property (strong, nonatomic) JPInputPageView * currentPV;
@property (strong, nonatomic) JPInputPageView * rightPV;
```
通过前面`JPEmojiManager`中取出对应页数的表情包之后，然后调用下面的方法讲每一页的表情包传入每一个分页
```
// JPInputPageView.h
/**
*  赋予新的数组，重新刷新数据源
*  @param  emojiArr : 一页的表情（作为内置CollectionView的数据
*/
- (void)setEmojiArr:(NSArray <JPEmojiModel *> *)emojiArr isShowLargeImage:(BOOL)value;
```
先来讲讲三个分页实现展示所有表情的效果：
- 1.首先将ScrollView的contentSize扩大到能容纳表情包总共页数的大小
- 2.除了第一组表情包的第一页和最后一组表情包的最后一页（什么都不用做），其他时刻，展示在用户面前的那一页始终是：`self.currentPV`。
- 3.当手指向左滑去展示下一页表情时候，`leftPv`移动到了最右边，同时去除该页的表情包，做好展示的准备。完成这一步之后，就是更换杯子中的水的问题了，将三个复用view的相互赋值：

```
// JPEmojiInputView.m
JPInputPageView * tmpView ;
tmpView = self.leftPV;
self.leftPV = self.currentPV;
self.currentPV = self.rightPV;
self.rightPV = tmpView;
```

我通过下面的图片来展示这一块底层的实现，可能可以方便大家理解：
<!--{% asset_img tupianzhenshifenye.jpg 解释分页效果的底层 %}-->

![解释分页效果的底层](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2cfa13f9f1a?w=704&h=531&f=png&s=45931)

当用户手指向右滑展示上一页的时候，底部实现的方式也是类似，以此类推。
更多细节（如何计算当前页对应哪一组表情包的哪一页等）可以参考我写在`JPEmojiInputView.m`里的`- (void)scrollViewDidScroll:(UIScrollView *)scrollView `。

### 点击SmallEmoji嵌入文本
iOS 中textView和textField可以自动识别系统原生的表情：
<!--{% asset_img xitongyuanshengbiaoqing.jpg 系统原生的表情 %}-->

![系统原生的表情](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2d34cbcafc3?w=382&h=383&f=png&s=114611)

而针对我们开发者另外添加的小表情，textView和textField不能直接识别。

这里可以参考了几个主流app的实现方式，
- 1.微博： 点击表情包嵌入表情图片；
- 2.微信：点击非原生表情包嵌入该表情包描述文本。

而要注意的是，当我们将‘图文混编’的文本消息发送出去经过我们服务器的时候，一般是不对字符串中的图片信息进行解析，因此，底层依旧是向服务器传递纯文本消息，而对里面的图片信息做了处理转换成了表情包的描述文本，下面我用一张图片解释这个问题：
<!--{% asset_img biaoqingbaofasongliucheng.jpg 收发流程 %}-->

![](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2d608af4633?w=898&h=686&f=png&s=57672)

可以看到我们本地需要对这些“图文混编”的文本转换成纯文本才能发送至服务端。这里主要通过两个系统的类来进行表情包和其描述文本的匹配。
- 1.`NSTextAttachment` : 文本中的‘插件’，我们通过这个类来插入图片。
- 2.`NSRegularExpression` : 使用正则表达式来匹配字符串中的表情包描述文本。

关于正则表达式，这里有一篇比较全的语法:[正则表达式](https://www.jianshu.com/p/ea10003d224a)。

这里我的正则匹配的字符如下：

`NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\]" options:0 error:NULL];`

在匹配出每一个表情包描述文本之后，会生成一个数组存放这些匹配结果(描述文本、图片资源、描述文本在原字符串的位置)，然后遍历这个数组，将这些描述文本通过插入图片插件`textAttachment`来替换，***这里注意***，每次替换，后面还没有被替换的表情包文本的range就会发送变化，我们需要递减他们原来的位置`range.location`。
具体实现的方式可参考下面代码:

```
// JPAttributedStringHelper.m
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
```
实现的效果可以到博客或者下载demo查看。
<!--{% asset_img biaoqingbaofasong.gif 发送'图文混编'文本 %}-->

而在按下删除键，要实现删除表情包描述文本，我们需要判断`textView.selectedRange`所在的位置是否为表情描述文本，代码参考如下：

```
// 点击了文本消息和或者表情包键盘的删除按钮
- (void)clickDeleteBtnInputView:(JPEmojiInputView *)inputView {
NSString * souceText = [self.textView.text substringToIndex:self.textView.selectedRange.location];
if(souceText.length == 0) {
return;
}
NSRange  range = self.textView.selectedRange;
if(range.location == NSNotFound) {
range.location = self.textView.text.length;
}
if(range.length > 0) {
[self.textView deleteBackward];
return;
}else {
// 正则表达式匹配要替换的文字的范围
if([souceText hasSuffix:@"]"]){
// 表示该选取字段最后一个是表情包
if([[souceText substringWithRange:NSMakeRange(souceText.length-2, 1)] isEqualToString:@"]"]) {
// 表示这只是一个单独的字符@"]"
[self.textView deleteBackward];
return;
}
// 正则表达式
NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
NSError *error = nil;
NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];if (!re) {NSLog(@"%@", [error localizedDescription]);}
NSArray *resultArray = [re matchesInString:souceText options:0 range:NSMakeRange(0, souceText.length)];
if(resultArray.count != 0) {
/// 表情最后一段存在表情包字符串
NSTextCheckingResult *checkingResult = resultArray.lastObject;
NSString * resultStr = [souceText substringWithRange:NSMakeRange(0, souceText.length - checkingResult.range.length)];
self.textView.text = [self.textView.text stringByReplacingCharactersInRange:NSMakeRange(0, souceText.length) withString:resultStr];
self.textView.selectedRange = NSMakeRange(resultStr.length , 0);
}else {
[self.textView deleteBackward];
}
}else {
// 表示最后一个不是表情包
[self.textView deleteBackward];
}
}
// textView自适应
[self textViewDidChange:self.textView];
}

```
实现效果大家可以看看demo🤓。

> 看到这里，我已经写了近5k字了😂
### 表情包的预览

表情包的预览效果分为
- 1.小表情的预览
- 2.大表情的预览（gif播放）

#### 展示
前者的底部视图是一张已经画好的图片，
<!--{% asset_img xiaobiaoqingdibushitu.jpg 小表情包的底部视图 %}-->
![小表情包的底部视图](https://user-gold-cdn.xitu.io/2019/8/10/16c7a2f241b975e4?w=186&h=221&f=png&s=5221)

后者的底部视图我通过重绘机制(`QuartzCore`框架并且重写`-drawRect: `方法)来进行描边以及视图颜色的填充(关于重绘制:[iOS开发之drawRect的作用和调用机制](https://blog.csdn.net/xiaoxiaobukuang/article/details/51594157))，代码:

```
// JPGIfPreview.m
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
```
#### 坐标换算
在完成了布局之后，接下来就是要将我们的预览视图添加到界面上。

在collectionView上面添加长按收拾`longPress`，监听手势的状态，并且计算手势所在位置对应的cell，对其内容进行预览效果的展示。

这里我选择了`[UIApplication sharedApplication].windows.lastobject`作为superView，即`emojiInputView`所在的window。

**这里有个要注意的点**，上面的window`CGPointZero`是从手机左上角开始算起，因此换算坐标(cell是每一个表情包，补充一下我是用collectionView来展示每一个分页上的表情包)时，我将cell.frame转换成了在window上的frame：
```
CGRect  rect = [[UIApplication sharedApplication].windows.lastObject convertRect:cell.frame fromView:self.collectionView];
```

坐标换算完成之后，剩下的就是添加上去。

#### gif播放
gif的播放效果，我也是第一次接触，这里看到一篇不错的文章：[iOS-Gif图片展示N种方式(原生+第三方)](https://blog.csdn.net/qxuewei/article/details/50782855)，里面有介绍原生和第三方的实现。
考虑到减少项目的依赖库，这里我就采用了里面原生方式的代码，具体可以点开链接看内部代码，这里不做过多叙述了（5.3k字了😂😂😂）。

## 参考
这些文章对我提供了一定的帮助，也希望对你有用

[iOS-Gif图片展示N种方式(原生+第三方)](https://blog.csdn.net/qxuewei/article/details/50782855)

[WWDC 2017 - 优化输入体验的关键：keyboard技巧全介绍](https://kemchenj.github.io/2017-08-07/)

[OC实现ios类似微信输入框跟随键盘弹出的效果](https://www.jianshu.com/p/f7198ee11572)

## 写在最后
在完成`JPChatBottomBar`之后，整个框架访问用户编辑的消息或者是用户的其他操作都可以通过`JPChatBottomBarDelegate`获取。

`JPChatBottomBar` 部分就先到这里，完成这部分内容，从demo到文章落笔完成之间，遇到了挺多问题😂。
例如‘切换键盘覆盖的问题’那一块自己就用了两种方法来实现，亦或者是‘表情包组别的切换’，自己都花了有些时间。

针对我的文章和demo中技术的实现，如果读者有更好的方法，欢迎提出🙏，谢谢🙏。

也希望我的文章能够给你带来帮助。

如果对你有所帮助，请给我个Star吧✨。谢谢！







































































