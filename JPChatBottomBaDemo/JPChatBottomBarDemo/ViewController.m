//
//  ViewController.m
//  JPMsgEditAgentViewDemo
//
//  Created by JonPai on 2019/7/26.
//  Copyright © 2019 JonPai. All rights reserved.
//

#import "ViewController.h"
#import "UIView+JPExtension.h"
#import "JPChatBottomBar.h"
#import "JPAttributedStringHelper.h"


#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)

@interface ViewController () <JPChatBottomBarDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSMutableArray * selectedAssets ;
    NSMutableArray * selectedPhotos ;
}
@property (weak, nonatomic) JPChatBottomBar * msgEditView;

@property (strong, nonatomic) UILabel * textLabel;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].keyWindow.backgroundColor = RGB(230, 230, 230);
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(touch)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.view.backgroundColor = [UIColor yellowColor];
    UIView * view = [[UIView alloc] init];
    view.x = 100;
    view.y = 250;
    view.width = 50;
    view.height = 50;
    view.backgroundColor = RGB(200, 200, 200);
    [self.view addSubview:view];
    UILabel * label = [[UILabel alloc] init];;
    _textLabel = label;
    label.width = SCREEN_WIDTH;
    label.numberOfLines = 1;
    label.height = 40;
    label.x = 0;
    label.y = 500;
    [self.view addSubview:label];
    label.text = @"文本展示在这里";
    label.layer.borderWidth = 1;
    label.layer.borderColor = [UIColor whiteColor].CGColor;
    label.textAlignment = NSTextAlignmentCenter;
#pragma mark 使用方式
    JPChatBottomBar * msgEditView = [[JPChatBottomBar alloc] initWithBarHeight:0 btnHeight:0];
    _msgEditView = msgEditView;
    msgEditView.agent= self;
    [self.view addSubview:msgEditView];
#pragma mark 另一种获取系统自带表情包的方式
//    int sym = EMOJI_CODE_TO_SYMBOL(0x1F600);
//    NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
//    NSLog(@"arr==%@",emoT);
//    
//    //获取数组
//    NSArray *arrEmotion = [self defaultEmoticons];
//    for (NSString *str in arrEmotion) {
//        NSLog(@"===%@",str);
//        
//    }
}
//- (NSArray *)defaultEmoticons {
//    NSMutableArray *array = [NSMutableArray new];
//    for (int i=0x1F600; i<=0x1F64F; i++) {
//        if (i < 0x1F641 || i > 0x1F644) {
//            int sym = EMOJI_CODE_TO_SYMBOL(i);
//            NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
//            [array addObject:emoT];
//        }
//    }
//    return array;
//}
- (void)touch {
    [self.msgEditView resignFirstResponder];
}

#pragma mark JPMsgEditAgentDelegate
- (void)msgEditAgentSendText:(NSString *)text {
    NSLog(@"%@",@"发送文本消息");
    JPAttributedStringHelper * helper = [[JPAttributedStringHelper alloc] init];
    self.textLabel.attributedText = [helper getTextViewArrtibuteFromStr:text];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"在这里完成im业务");
}
- (void)msgEditAgentAudio:(NSData *)audioData {
    NSLog(@"发送语音消息---在这里完成im业务");
}
- (void)msgEditAgentSendBigEmoji:(NSData *)bigEmojiData {
    NSLog(@"发送大表情包---在这里完成im业务");
}

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
#pragma mark MoreInputView中点击item后实现的方法
- (void)turnOnCamera {
    NSLog(@"打开摄像头");
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        //        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

@end
